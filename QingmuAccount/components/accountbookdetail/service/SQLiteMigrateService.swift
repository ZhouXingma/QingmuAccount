//
//  SQLiteMigrateService.swift
//  QingmuAccount
//  一次性数据迁移：把 Documents/account/ 下的旧 JSON 文件导入 SQLite。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

class SQLiteMigrateService {
    static let shared = SQLiteMigrateService()
    private init() {}

    private static let MIGRATION_VERSION_KEY = "migration_version"
    private static let ACCOUNT_DIR = NSHomeDirectory() + "/Documents/account/"
    private static let BOOKS_FILE = ACCOUNT_DIR + "accountbookInfo.json"

    /**
     启动时调用：确保数据库就绪并把旧 JSON 数据导入 SQLite。幂等。
     */
    func ensureMigrated() {
        try? SQLiteManager.shared.open()
        try? SQLiteManager.shared.createTablesIfNeeded()
        guard !isMigrated() else { return }
        guard FilesUtils.isExit(filePath: SQLiteMigrateService.BOOKS_FILE) else {
            // 没有旧数据，直接标记已迁移（数据库为空）
            markMigrated()
            return
        }
        do {
            try migrate()
        } catch {
            print("数据迁移失败：\(error)")
        }
    }

    private func isMigrated() -> Bool {
        let rows = try? SQLiteManager.shared.query("SELECT value FROM schema_meta WHERE key=?", [SQLiteMigrateService.MIGRATION_VERSION_KEY])
        return rows?.first?["value"] != nil
    }

    private func markMigrated() {
        try? SQLiteManager.shared.execute("INSERT OR REPLACE INTO schema_meta(key,value) VALUES(?,?)", [SQLiteMigrateService.MIGRATION_VERSION_KEY, "1"])
    }

    private func decodeJSON<T: Decodable>(_ type: T.Type, fromFile path: String) -> T? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8),
              let data = content.data(using: .utf8) else {
            print("迁移：读取文件失败 \(path)")
            return nil
        }
        do {
            return try JSONUtils.decode(data, type)
        } catch {
            print("迁移：解码失败 type=\(type) path=\(path) error=\(error)")
            return nil
        }
    }

    private func migrate() throws {
        try SQLiteManager.shared.transaction {
            try migrateAccountBooks()
            try migrateAccountBookChildren()
            try SQLiteManager.shared.execute("INSERT OR REPLACE INTO schema_meta(key,value) VALUES(?,?)", [SQLiteMigrateService.MIGRATION_VERSION_KEY, "1"])
        }
        backupOldData()
    }

    // MARK: - 账本

    private func migrateAccountBooks() throws {
        guard let books = decodeJSON(Dictionary<String, AccountBookModel>.self, fromFile: SQLiteMigrateService.BOOKS_FILE) else {
            throw SQLiteError.message("迁移：账本信息解码失败 accountbookInfo.json")
        }
        for (_, book) in books {
            try SQLiteManager.shared.execute(
                "INSERT OR REPLACE INTO account_book(id,name,iconStr,bgColor,description,gmtCreated) VALUES(?,?,?,?,?,?)",
                [book.id.uuidString, book.name, book.iconStr, book.bgColor, book.description, Int64(book.gmtCreated.timeIntervalSince1970)]
            )
        }
    }

    private func migrateAccountBookChildren() throws {
        guard let books = decodeJSON(Dictionary<String, AccountBookModel>.self, fromFile: SQLiteMigrateService.BOOKS_FILE) else {
            throw SQLiteError.message("迁移：账本信息解码失败 accountbookInfo.json")
        }
        for (_, book) in books {
            let bookId = book.id.uuidString
            try migrateAccountBookSetting(bookId)
            try migrateAccountBookRecords(bookId)
        }
    }

    private func migrateAccountBookSetting(_ bookId: String) throws {
        let settingPath = SQLiteMigrateService.ACCOUNT_DIR + bookId + "/accountbookSeting.json"
        guard let setting = decodeJSON(AccountBookSetingModel.self, fromFile: settingPath) else { return }
        // 预算
        for (ym, currencyBudgets) in setting.budget {
            for (currency, amount) in currencyBudgets {
                try SQLiteManager.shared.execute(
                    "INSERT OR REPLACE INTO budget(bookId,ym,currency,budgetCents) VALUES(?,?,?,?)",
                    [bookId, ym, currency, SQLiteManager.cents(fromMoney: "\(amount)")]
                )
            }
        }
        // 图标设置
        for item in setting.inRecordIconSeting {
            try insertIconSetting(bookId, kind: 1, item)
        }
        for item in setting.outRecordIconSeting {
            try insertIconSetting(bookId, kind: 0, item)
        }
    }

    private func insertIconSetting(_ bookId: String, kind: Int, _ item: AccountBookSetingOfIconModel) throws {
        try SQLiteManager.shared.execute(
            "INSERT OR REPLACE INTO icon_setting(bookId,kind,id,iconStr,name,sort) VALUES(?,?,?,?,?,?)",
            [bookId, kind, item.id, item.iconStr, item.name, item.sort]
        )
    }

    private func migrateAccountBookRecords(_ bookId: String) throws {
        let bookDir = SQLiteMigrateService.ACCOUNT_DIR + bookId + "/"
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: bookDir) else { return }
        for file in files {
            guard file.hasPrefix("ac"), file.hasSuffix(".json") else { continue }
            // 只匹配 ac<年份4位>.json
            let yearPart = file.dropFirst(2).dropLast(5)
            guard yearPart.count == 4, yearPart.allSatisfy({ $0.isNumber }) else { continue }
            let yearPath = bookDir + file
            guard let yearData = decodeJSON(AccountBookYearData.self, fromFile: yearPath) else { continue }
            for (_, records) in yearData.data {
                for record in records {
                    try SQLiteManager.shared.execute(
                        "INSERT OR REPLACE INTO record(id,bookId,dateStr,gmtCreated,gmtModfied,type,money,moneyCents,iconStr,title,desc) VALUES(?,?,?,?,?,?,?,?,?,?,?)",
                        [
                            record.id.uuidString, bookId, record.dateStr,
                            Int64(record.gmtCreated.timeIntervalSince1970),
                            Int64(record.gmtModfied.timeIntervalSince1970),
                            record.type, record.money,
                            SQLiteManager.cents(fromMoney: record.money),
                            record.iconStr, record.title, record.desc
                        ]
                    )
                }
            }
        }
    }

    // MARK: - 备份旧 JSON

    private func backupOldData() {
        let base = NSHomeDirectory() + "/Documents/"
        let src = base + "account/"
        let dst = base + "account_backup_" + String(Int(Date().timeIntervalSince1970)) + "/"
        let fm = FileManager.default
        do {
            try fm.createDirectory(atPath: dst, withIntermediateDirectories: true)
            guard let items = try? fm.contentsOfDirectory(atPath: src) else { return }
            for item in items {
                if item.hasPrefix("account.db") { continue }
                let srcPath = src + item
                let dstPath = dst + item
                try? fm.moveItem(atPath: srcPath, toPath: dstPath)
            }
        } catch {
            print("迁移备份失败：\(error)")
        }
    }
}
