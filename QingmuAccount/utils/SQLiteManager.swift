//
//  SQLiteManager.swift
//  QingmuAccount
//  SQLite3 C API 封装：连接、建表、增删改查、事务。金额以分（moneyCents）聚合保证精度。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case openFailed(String)
    case prepareFailed(String)
    case stepFailed(String)
    case bindFailed(String)
    case message(String)
}

class SQLiteManager {
    public static let DB_DIRECTOR = NSHomeDirectory()+"/Documents/account/"
    public static let DB_NAME = "account.db"
    public static let DB_PATH = DB_DIRECTOR + DB_NAME

    static let shared = SQLiteManager()
    private init() {
        queue.setSpecific(key: queueKey, value: queueContext)
    }

    private var db: OpaquePointer?
    private var opened = false
    private var tablesReady = false
    // 串行队列保证线程安全；通过 getSpecific 判断是否已在队列内，避免事务内嵌套 sync 死锁
    private let queue = DispatchQueue(label: "qingmu.sqlite")
    private let queueKey = DispatchSpecificKey<UInt8>()
    private let queueContext: UInt8 = 0

    // 表结构定义，与项目根目录 database_schema.sql 同步维护，修改时两处一起更新
    private static let budgetTableSQL = "CREATE TABLE IF NOT EXISTS budget (bookId TEXT NOT NULL REFERENCES account_book(id) ON DELETE CASCADE, ym TEXT NOT NULL, currency TEXT NOT NULL DEFAULT 'CNY', budgetCents INTEGER NOT NULL, PRIMARY KEY(bookId, ym, currency));"
    private static let ddl: [String] = [
        "CREATE TABLE IF NOT EXISTS schema_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);",
        "CREATE TABLE IF NOT EXISTS account_book (id TEXT PRIMARY KEY, name TEXT NOT NULL UNIQUE, iconStr TEXT NOT NULL, bgColor TEXT NOT NULL, description TEXT, default_asset_account_id TEXT NOT NULL DEFAULT '', default_currency TEXT NOT NULL DEFAULT 'CNY', gmtCreated INTEGER NOT NULL);",
        "CREATE TABLE IF NOT EXISTS record (id TEXT PRIMARY KEY, bookId TEXT NOT NULL REFERENCES account_book(id) ON DELETE CASCADE, dateStr TEXT NOT NULL, gmtCreated INTEGER NOT NULL, gmtModfied INTEGER NOT NULL, type INTEGER NOT NULL, money TEXT NOT NULL, moneyCents INTEGER NOT NULL, iconStr TEXT NOT NULL, title TEXT NOT NULL, desc TEXT NOT NULL DEFAULT '', asset_record_id TEXT NOT NULL DEFAULT '', account_id TEXT NOT NULL DEFAULT '', currency TEXT NOT NULL DEFAULT 'CNY');",
        "CREATE INDEX IF NOT EXISTS idx_record_book_date ON record(bookId, dateStr);",
        "CREATE INDEX IF NOT EXISTS idx_record_book_title ON record(bookId, title);",
        budgetTableSQL,
        "CREATE TABLE IF NOT EXISTS icon_setting (bookId TEXT NOT NULL REFERENCES account_book(id) ON DELETE CASCADE, kind INTEGER NOT NULL, id TEXT NOT NULL, iconStr TEXT NOT NULL, name TEXT NOT NULL, sort INTEGER NOT NULL, PRIMARY KEY(bookId, kind, id));",
        "CREATE TABLE IF NOT EXISTS asserts_account (kind INTEGER NOT NULL, accountName TEXT NOT NULL, totalCents INTEGER NOT NULL, PRIMARY KEY(kind, accountName));",
        "CREATE TABLE IF NOT EXISTS asserts_item (id TEXT PRIMARY KEY, kind INTEGER NOT NULL, accountName TEXT NOT NULL, itemName TEXT NOT NULL, gmtCreated INTEGER NOT NULL, gmtModfied INTEGER NOT NULL, itemType INTEGER NOT NULL, money TEXT NOT NULL, moneyCents INTEGER NOT NULL, ym TEXT NOT NULL);",
        "CREATE INDEX IF NOT EXISTS idx_asserts_item_group ON asserts_item(kind, accountName, ym);",
        "CREATE TABLE IF NOT EXISTS asset_account (id TEXT PRIMARY KEY, name TEXT NOT NULL, type INTEGER NOT NULL, icon TEXT NOT NULL, currency TEXT NOT NULL DEFAULT 'CNY', totalCents INTEGER NOT NULL DEFAULT 0, sort INTEGER NOT NULL DEFAULT 0, description TEXT NOT NULL DEFAULT '', gmtCreated INTEGER NOT NULL, gmtModfied INTEGER NOT NULL);",
        "CREATE TABLE IF NOT EXISTS asset_account_record (id TEXT PRIMARY KEY, accountId TEXT NOT NULL REFERENCES asset_account(id) ON DELETE CASCADE, changeType INTEGER NOT NULL, money TEXT NOT NULL, moneyCents INTEGER NOT NULL, remark TEXT NOT NULL DEFAULT '', related_account_name TEXT NOT NULL DEFAULT '', currency TEXT NOT NULL DEFAULT 'CNY', gmtCreated INTEGER NOT NULL, gmtModfied INTEGER NOT NULL);",
        "CREATE TABLE IF NOT EXISTS asset_account_balance (accountId TEXT NOT NULL REFERENCES asset_account(id) ON DELETE CASCADE, currency TEXT NOT NULL, totalCents INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (accountId, currency));",
        "CREATE INDEX IF NOT EXISTS idx_asset_record_account ON asset_account_record(accountId, gmtCreated);"
    ]

    /**
     确保数据库已打开并建表。所有写/查操作入口自动调用，幂等。
     */
    func ensureReady() throws {
        try executeSync {
            if tablesReady { return }
            if !opened {
                try _open()
            }
            for sql in SQLiteManager.ddl {
                try _execute(sql)
            }
            tablesReady = true
            try migrateSchema()
        }
    }

    /// 历史库补列迁移（新库已按最新 DDL 建表，无需处理）
    private func migrateSchema() throws {
        try ensureColumn("asset_account_record", "related_account_name", "TEXT NOT NULL DEFAULT ''")
        try ensureColumn("asset_account", "description", "TEXT NOT NULL DEFAULT ''")
        try ensureColumn("account_book", "default_asset_account_id", "TEXT NOT NULL DEFAULT ''")
        try ensureColumn("account_book", "default_currency", "TEXT NOT NULL DEFAULT 'CNY'")
        try ensureColumn("record", "asset_record_id", "TEXT NOT NULL DEFAULT ''")
        try ensureColumn("record", "account_id", "TEXT NOT NULL DEFAULT ''")
        try ensureColumn("record", "currency", "TEXT NOT NULL DEFAULT 'CNY'")
        try ensureColumn("asset_account_record", "currency", "TEXT NOT NULL DEFAULT 'CNY'")
        // 初始化多币种余额表：为每个账户按主币种写入当前总金额（幂等）
        let accounts = try query("SELECT id, currency, totalCents FROM asset_account")
        for row in accounts {
            guard let id = row["id"] as? String,
                  let currency = row["currency"] as? String,
                  let cents = row["totalCents"] as? Int64 else { continue }
            let primary = currency.split(separator: ",").map(String.init).first ?? "CNY"
            try _execute("INSERT OR IGNORE INTO asset_account_balance(accountId,currency,totalCents) VALUES(?,?,?)", [id, primary, cents])
        }
        // 预算表多币种迁移：历史表无 currency 列时重建（单币种预算归为 CNY）
        let budgetCols = try query("PRAGMA table_info(budget)")
        let hasBudgetCurrency = budgetCols.contains { ($0["name"] as? String) == "currency" }
        if !hasBudgetCurrency {
            try rebuildBudgetTable()
        }
    }

    /// 重建 budget 表为多币种结构，历史行归为 CNY。迁移期间关闭外键，避免孤儿数据导致复制失败。
    private func rebuildBudgetTable() throws {
        try _execute("PRAGMA foreign_keys=OFF")
        defer { try? _execute("PRAGMA foreign_keys=ON") }
        if try tableExists("budget_old") {
            try _execute("DROP TABLE budget_old")
        }
        try _execute("ALTER TABLE budget RENAME TO budget_old")
        try _execute(SQLiteManager.budgetTableSQL)
        try _execute("INSERT INTO budget(bookId,ym,currency,budgetCents) SELECT bookId,ym,'CNY',budgetCents FROM budget_old")
        try _execute("DROP TABLE budget_old")
    }

    private func tableExists(_ name: String) throws -> Bool {
        let rows = try query("SELECT name FROM sqlite_master WHERE type='table' AND name=?", [name])
        return rows.count > 0
    }

    private func ensureColumn(_ table: String, _ column: String, _ definition: String) throws {
        let rows = try query("PRAGMA table_info(\(table))")
        let has = rows.contains { ($0["name"] as? String) == column }
        if !has {
            try _execute("ALTER TABLE \(table) ADD COLUMN \(column) \(definition)")
        }
    }

    /**
     打开数据库（含建目录、WAL、外键）。线程安全，可重复调用。
     */
    func open() throws {
        try ensureReady()
    }

    /**
     建表（幂等）。
     */
    func createTablesIfNeeded() throws {
        try ensureReady()
    }

    /**
     执行写语句（INSERT/UPDATE/DELETE/DDL/PRAGMA）。
     */
    func execute(_ sql: String, _ params: [Any?] = []) throws {
        try ensureReady()
        try executeSync {
            try _execute(sql, params)
        }
    }

    /**
     执行查询，返回按列名组织的字典数组。
     */
    func query(_ sql: String, _ params: [Any?] = []) throws -> [[String: Any?]] {
        try ensureReady()
        return try executeSync {
            guard let stmt = try _prepare(sql) else {
                return []
            }
            defer { sqlite3_finalize(stmt) }
            try _bind(stmt, params)
            var rows: [[String: Any?]] = []
            while true {
                let code = sqlite3_step(stmt)
                if code == SQLITE_ROW {
                    rows.append(convertRow(stmt))
                } else if code == SQLITE_DONE {
                    break
                } else {
                    throw SQLiteError.stepFailed(errorMessage())
                }
            }
            return rows
        }
    }

    /**
     事务。body 内调用的 execute/query 不会死锁。
     */
    func transaction(_ body: () throws -> Void) throws {
        try ensureReady()
        try executeSync {
            try _execute("BEGIN IMMEDIATE TRANSACTION")
            do {
                try body()
                try _execute("COMMIT")
            } catch {
                try? _execute("ROLLBACK")
                throw error
            }
        }
    }

    static func tableExists(_ name: String) -> Bool {
        let sql = "SELECT name FROM sqlite_master WHERE type='table' AND name=?"
        if let rows = try? SQLiteManager.shared.query(sql, [name]), rows.count > 0 {
            return true
        }
        return false
    }

    /**
     金额字符串转分（聚合基准）。
     */
    static func cents(fromMoney money: String) -> Int64 {
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let value = NSDecimalNumber(string: money)
        return value.multiplying(by: NSDecimalNumber(value: 100)).rounding(accordingToBehavior: handler).int64Value
    }

    /**
     分转金额字符串（保留两位小数）。
     */
    static func money(fromCents cents: Int64) -> String {
        return DecimalUtils.trans2StringOfCurrency(Decimal(cents) / 100)
    }

    // MARK: - 内部实现

    private func _open() throws {
        if !FilesUtils.isExit(filePath: SQLiteManager.DB_DIRECTOR) {
            FilesUtils.createDirector(directorPath: SQLiteManager.DB_DIRECTOR)
        }
        var handle: OpaquePointer?
        let result = sqlite3_open_v2(SQLiteManager.DB_PATH, &handle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        guard result == SQLITE_OK, let handle = handle else {
            let msg = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            sqlite3_close(handle)
            throw SQLiteError.openFailed(msg)
        }
        db = handle
        try _execute("PRAGMA journal_mode=WAL")
        try _execute("PRAGMA foreign_keys=ON")
        try _execute("PRAGMA busy_timeout=3000")
        opened = true
    }

    private func executeSync<T>(_ body: () throws -> T) throws -> T {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            return try body()
        }
        var result: T?
        var failure: Error?
        queue.sync {
            do { result = try body() }
            catch { failure = error }
        }
        if let failure = failure {
            throw failure
        }
        return result!
    }

    private func _execute(_ sql: String, _ params: [Any?] = []) throws {
        guard let stmt = try _prepare(sql) else { return }
        defer { sqlite3_finalize(stmt) }
        try _bind(stmt, params)
        let code = sqlite3_step(stmt)
        guard code == SQLITE_DONE || code == SQLITE_ROW else {
            throw SQLiteError.stepFailed(errorMessage())
        }
    }

    private func _prepare(_ sql: String) throws -> OpaquePointer? {
        guard let db = db else {
            throw SQLiteError.message("数据库未打开")
        }
        var stmt: OpaquePointer?
        let code = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        guard code == SQLITE_OK else {
            throw SQLiteError.prepareFailed(errorMessage())
        }
        return stmt
    }

    private func _bind(_ stmt: OpaquePointer, _ params: [Any?]) throws {
        for (index, param) in params.enumerated() {
            let idx = Int32(index + 1)
            var code: Int32 = SQLITE_OK
            switch param {
            case nil, is NSNull:
                code = sqlite3_bind_null(stmt, idx)
            case let value as Int:
                code = sqlite3_bind_int64(stmt, idx, Int64(value))
            case let value as Int64:
                code = sqlite3_bind_int64(stmt, idx, value)
            case let value as Bool:
                code = sqlite3_bind_int64(stmt, idx, value ? 1 : 0)
            case let value as Double:
                code = sqlite3_bind_double(stmt, idx, value)
            case let value as String:
                code = sqlite3_bind_text(stmt, idx, value, -1, SQLITE_TRANSIENT)
            case let value as Date:
                code = sqlite3_bind_int64(stmt, idx, Int64(value.timeIntervalSince1970))
            case let value as UUID:
                code = sqlite3_bind_text(stmt, idx, value.uuidString, -1, SQLITE_TRANSIENT)
            case let value as Decimal:
                code = sqlite3_bind_text(stmt, idx, "\(value)", -1, SQLITE_TRANSIENT)
            default:
                throw SQLiteError.bindFailed("不支持的参数类型: \(type(of: param))")
            }
            guard code == SQLITE_OK else {
                throw SQLiteError.bindFailed(errorMessage())
            }
        }
    }

    private func convertRow(_ stmt: OpaquePointer) -> [String: Any?] {
        var row: [String: Any?] = [:]
        let count = sqlite3_column_count(stmt)
        for i in 0..<count {
            let name = String(cString: sqlite3_column_name(stmt, i))
            let type = sqlite3_column_type(stmt, i)
            switch type {
            case SQLITE_INTEGER:
                row[name] = sqlite3_column_int64(stmt, i)
            case SQLITE_FLOAT:
                row[name] = sqlite3_column_double(stmt, i)
            case SQLITE_TEXT:
                row[name] = String(cString: sqlite3_column_text(stmt, i))
            case SQLITE_NULL:
                row[name] = nil
            default:
                row[name] = nil
            }
        }
        return row
    }

    private func errorMessage() -> String {
        guard let db = db else { return "unknown" }
        return String(cString: sqlite3_errmsg(db))
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
