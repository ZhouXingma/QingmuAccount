//
//  AssetAccountRecordService.swift
//  QingmuAccount
//  资产变更明细读写（SQLite 实现）。新增/删除明细时在同一事务内同步更新账户余额。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

enum AssetAccountRecordError: Error {
    case ISEXIT
    case ISNOTEXIT
    case TAKEHANLE
}

class AssetAccountRecordService {
    private static let table = "asset_account_record"

    /// 某账户的全部变更明细，时间倒序
    static func getRecords(accountId: String) throws -> [AssetAccountRecordModel] {
        let rows = try SQLiteManager.shared.query(
            "SELECT * FROM \(table) WHERE accountId=? ORDER BY gmtCreated DESC", [accountId])
        return rows.compactMap { rowToRecord($0) }
    }

    /// 某账户的变更明细分页查询，时间倒序
    static func getRecords(accountId: String, limit: Int, offset: Int) throws -> [AssetAccountRecordModel] {
        let rows = try SQLiteManager.shared.query(
            "SELECT * FROM \(table) WHERE accountId=? ORDER BY gmtCreated DESC LIMIT ? OFFSET ?",
            [accountId, limit, offset])
        return rows.compactMap { rowToRecord($0) }
    }

    /// 指定月份所有账户的变更明细，时间倒序
    static func getRecords(year: Int, month: Int) throws -> [AssetAccountRecordModel] {
        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = 1
        startComps.hour = 0
        startComps.minute = 0
        startComps.second = 0
        let start = Calendar.current.date(from: startComps) ?? Date()
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? Date()
        let rows = try SQLiteManager.shared.query(
            "SELECT * FROM \(table) WHERE gmtCreated >= ? AND gmtCreated < ? ORDER BY gmtCreated DESC",
            [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        return rows.compactMap { rowToRecord($0) }
    }

    /// 某账户指定月份的变更明细，时间倒序
    static func getRecords(accountId: String, year: Int, month: Int) throws -> [AssetAccountRecordModel] {
        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = 1
        startComps.hour = 0
        startComps.minute = 0
        startComps.second = 0
        let start = Calendar.current.date(from: startComps) ?? Date()
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? Date()
        let rows = try SQLiteManager.shared.query(
            "SELECT * FROM \(table) WHERE accountId=? AND gmtCreated >= ? AND gmtCreated < ? ORDER BY gmtCreated DESC",
            [accountId, Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        return rows.compactMap { rowToRecord($0) }
    }

    /// 新增一条变更明细，并在同一事务内累加对应币种余额。返回新明细 id。
    /// signedMoneyCents 为带符号金额（正=余额增加，负=余额减少）。
    static func addRecord(accountId: String, changeType: Int, signedMoneyCents: Int64,
                          money: String, remark: String, currency: String = "CNY") throws -> String {
        let recordId = UUID()
        try SQLiteManager.shared.transaction {
            let existRows = try SQLiteManager.shared.query(
                "SELECT id FROM asset_account WHERE id=?", [accountId])
            guard existRows.count > 0 else {
                throw AssetAccountRecordError.ISNOTEXIT
            }
            let now = Date()
            let nowTS = Int64(now.timeIntervalSince1970)
            let record = AssetAccountRecordModel(
                id: recordId,
                accountId: accountId,
                changeType: changeType,
                money: money,
                moneyCents: signedMoneyCents,
                remark: remark,
                currency: currency,
                gmtCreated: now,
                gmtModfied: now
            )
            try insertRecord(record)
            try applyBalance(accountId: accountId, currency: currency, delta: signedMoneyCents, nowTS: nowTS)
        }
        return recordId.uuidString
    }

    /// 更新某账户某币种的余额（balance 表 + 若是主币种同步 account.totalCents），事务内调用
    static func applyBalance(accountId: String, currency: String, delta: Int64, nowTS: Int64) throws {
        try SQLiteManager.shared.execute(
            "INSERT INTO asset_account_balance(accountId,currency,totalCents) VALUES(?,?,?) ON CONFLICT(accountId,currency) DO UPDATE SET totalCents=totalCents+excluded.totalCents",
            [accountId, currency, delta]
        )
        let rows = try SQLiteManager.shared.query("SELECT currency FROM asset_account WHERE id=?", [accountId])
        let primary = (rows.first?["currency"] as? String)?.split(separator: ",").map(String.init).first ?? "CNY"
        if currency == primary {
            try SQLiteManager.shared.execute(
                "UPDATE asset_account SET totalCents=totalCents+?, gmtModfied=? WHERE id=?",
                [delta, nowTS, accountId]
            )
        }
    }

    /// 转移：本账户减少 amount，目标账户增加 amount（同事务，各生成一条明细）。
    /// currency 为空时取转出账户主币种。
    static func transferRecord(fromAccountId: String, toAccountId: String,
                               amountCents: Int64, money: String, remark: String, currency: String? = nil) throws {
        guard fromAccountId != toAccountId else {
            throw AssetAccountRecordError.TAKEHANLE
        }
        try SQLiteManager.shared.transaction {
            let accountRows = try SQLiteManager.shared.query(
                "SELECT id, name, currency FROM asset_account WHERE id IN (?,?)", [fromAccountId, toAccountId])
            guard accountRows.count == 2 else {
                throw AssetAccountRecordError.ISNOTEXIT
            }
            var nameMap: [String: String] = [:]
            var currencyMap: [String: String] = [:]
            for row in accountRows {
                if let id = row["id"] as? String, let name = row["name"] as? String {
                    nameMap[id] = name
                }
                if let id = row["id"] as? String, let currency = row["currency"] as? String {
                    currencyMap[id] = currency
                }
            }
            let fromName = nameMap[fromAccountId] ?? ""
            let toName = nameMap[toAccountId] ?? ""
            // 转移币种 = 指定币种或转出账户主币种
            let transferCurrency = currency ?? (currencyMap[fromAccountId] ?? "CNY").split(separator: ",").map(String.init).first ?? "CNY"
            let now = Date()
            let nowTS = Int64(now.timeIntervalSince1970)
            // 本账户：转出，余额减少，标记转入账户名称
            let outRecord = AssetAccountRecordModel(
                accountId: fromAccountId,
                changeType: AssetRecordChangeType.transfer.rawValue,
                money: money, moneyCents: -amountCents, remark: remark,
                relatedAccountName: toName, currency: transferCurrency,
                gmtCreated: now, gmtModfied: now
            )
            try insertRecord(outRecord)
            try applyBalance(accountId: fromAccountId, currency: transferCurrency, delta: -amountCents, nowTS: nowTS)
            // 目标账户：转入，余额增加，标记转出账户名称
            let inRecord = AssetAccountRecordModel(
                accountId: toAccountId,
                changeType: AssetRecordChangeType.transfer.rawValue,
                money: money, moneyCents: amountCents, remark: remark,
                relatedAccountName: fromName, currency: transferCurrency,
                gmtCreated: now, gmtModfied: now
            )
            try insertRecord(inRecord)
            try applyBalance(accountId: toAccountId, currency: transferCurrency, delta: amountCents, nowTS: nowTS)
        }
    }

    /// 修改明细金额并同步账户余额（差异 = 新值 - 旧值）
    static func updateRecordAmount(recordId: String, newSignedMoneyCents: Int64, money: String) throws {
        try SQLiteManager.shared.transaction {
            let rows = try SQLiteManager.shared.query(
                "SELECT * FROM \(table) WHERE id=?", [recordId])
            guard let row = rows.first, let old = rowToRecord(row) else {
                throw AssetAccountRecordError.ISNOTEXIT
            }
            let diff = newSignedMoneyCents - old.moneyCents
            let nowTS = Int64(Date().timeIntervalSince1970)
            try SQLiteManager.shared.execute(
                "UPDATE \(table) SET money=?, moneyCents=?, gmtModfied=? WHERE id=?",
                [money, newSignedMoneyCents, nowTS, recordId]
            )
            try applyBalance(accountId: old.accountId, currency: old.currency, delta: diff, nowTS: nowTS)
        }
    }

    /// 删除一条变更明细，并在同一事务内回滚账户余额。
    static func deleteRecord(recordId: String) throws {
        try SQLiteManager.shared.transaction {
            let rows = try SQLiteManager.shared.query(
                "SELECT * FROM \(table) WHERE id=?", [recordId])
            guard let row = rows.first, let record = rowToRecord(row) else {
                throw AssetAccountRecordError.ISNOTEXIT
            }
            try SQLiteManager.shared.execute("DELETE FROM \(table) WHERE id=?", [recordId])
            try applyBalance(accountId: record.accountId, currency: record.currency, delta: -record.moneyCents, nowTS: Int64(Date().timeIntervalSince1970))
        }
    }

    // MARK: - 内部

    /// 纯插入（供外部事务内调用，不自行开启事务）
    static func insertRecord(_ record: AssetAccountRecordModel) throws {
        try SQLiteManager.shared.execute(
            "INSERT INTO \(table)(id,accountId,changeType,money,moneyCents,remark,related_account_name,currency,gmtCreated,gmtModfied) VALUES(?,?,?,?,?,?,?,?,?,?)",
            [
                record.id.uuidString, record.accountId, record.changeType, record.money, record.moneyCents,
                record.remark, record.relatedAccountName, record.currency,
                Int64(record.gmtCreated.timeIntervalSince1970),
                Int64(record.gmtModfied.timeIntervalSince1970)
            ]
        )
    }

    static func rowToRecord(_ row: [String: Any?]) -> AssetAccountRecordModel? {
        guard let id = row["id"] as? String,
              let accountId = row["accountId"] as? String,
              let changeType = row["changeType"] as? Int64,
              let money = row["money"] as? String else { return nil }
        return AssetAccountRecordModel(
            id: UUID(uuidString: id) ?? UUID(),
            accountId: accountId,
            changeType: Int(changeType),
            money: money,
            moneyCents: row["moneyCents"] as? Int64 ?? 0,
            remark: row["remark"] as? String ?? "",
            relatedAccountName: row["related_account_name"] as? String ?? "",
            currency: row["currency"] as? String ?? "CNY",
            gmtCreated: Date(timeIntervalSince1970: TimeInterval(row["gmtCreated"] as? Int64 ?? 0)),
            gmtModfied: Date(timeIntervalSince1970: TimeInterval(row["gmtModfied"] as? Int64 ?? 0))
        )
    }
}
