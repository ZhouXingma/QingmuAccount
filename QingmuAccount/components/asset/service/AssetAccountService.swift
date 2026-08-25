//
//  AssetAccountService.swift
//  QingmuAccount
//  资产账户读写（SQLite 实现）。金额以分（totalCents）存储保精度。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

enum AssetAccountError: Error {
    // 账户名称已存在
    case ISEXIT
    // 账户不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AssetAccountService {
    private static let table = "asset_account"

    /// 全部账户，按类型、排序、创建时间排序
    static func getAll() throws -> [AssetAccountModel] {
        let rows = try SQLiteManager.shared.query(
            "SELECT * FROM \(table) ORDER BY type, sort, gmtCreated")
        return rows.compactMap { rowToAccount($0) }
    }

    /// 按 id 查询账户
    static func get(_ id: String) throws -> AssetAccountModel? {
        let rows = try SQLiteManager.shared.query("SELECT * FROM \(table) WHERE id=?", [id])
        guard let row = rows.first else { return nil }
        return rowToAccount(row)
    }

    /// 账户名称是否已存在
    static func nameExists(_ name: String) throws -> Bool {
        let rows = try SQLiteManager.shared.query("SELECT id FROM \(table) WHERE name=?", [name])
        return rows.count > 0
    }

    /// 新增账户。initialCents 为初始余额（分），非 0 时在同一事务内生成一条「调账」明细。
    static func add(_ account: AssetAccountModel, initialCents: Int64) throws {
        if try nameExists(account.name) {
            throw AssetAccountError.ISEXIT
        }
        try SQLiteManager.shared.transaction {
            try insert(account)
            if initialCents != 0 {
                let now = Date()
                let nowTS = Int64(now.timeIntervalSince1970)
                let primary = account.primaryCurrency
                let record = AssetAccountRecordModel(
                    accountId: account.id.uuidString,
                    changeType: AssetRecordChangeType.adjust.rawValue,
                    money: SQLiteManager.money(fromCents: abs(initialCents)),
                    moneyCents: initialCents,
                    remark: "初始余额",
                    currency: primary,
                    gmtCreated: now,
                    gmtModfied: now
                )
                try AssetAccountRecordService.insertRecord(record)
                // 初始余额挂入主币种余额（balance + totalCents）
                try AssetAccountRecordService.applyBalance(accountId: account.id.uuidString, currency: primary, delta: initialCents, nowTS: nowTS)
            }
        }
    }

    /// 更新账户基本信息（不直接改余额，余额通过明细变更）
    static func update(_ account: AssetAccountModel) throws {
        let changed = try SQLiteManager.shared.execute(
            "UPDATE \(table) SET name=?, type=?, icon=?, currency=?, sort=?, description=?, gmtModfied=? WHERE id=?",
            [
                account.name, account.type, account.icon, account.currency, account.sort, account.description,
                Int64(account.gmtModfied.timeIntervalSince1970), account.id.uuidString
            ]
        )
        _ = changed
    }

    /// 删除账户（明细由外键 ON DELETE CASCADE 级联删除）
    static func delete(id: String) throws {
        try SQLiteManager.shared.execute("DELETE FROM \(table) WHERE id=?", [id])
    }

    // MARK: - 内部

    static func insert(_ account: AssetAccountModel) throws {
        try SQLiteManager.shared.execute(
            "INSERT INTO \(table)(id,name,type,icon,currency,totalCents,sort,description,gmtCreated,gmtModfied) VALUES(?,?,?,?,?,?,?,?,?,?)",
            [
                account.id.uuidString, account.name, account.type, account.icon, account.currency,
                account.totalCents, account.sort, account.description,
                Int64(account.gmtCreated.timeIntervalSince1970),
                Int64(account.gmtModfied.timeIntervalSince1970)
            ]
        )
    }

    static func rowToAccount(_ row: [String: Any?]) -> AssetAccountModel? {
        guard let id = row["id"] as? String,
              let name = row["name"] as? String,
              let type = row["type"] as? Int64,
              let icon = row["icon"] as? String else { return nil }
        return AssetAccountModel(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            type: Int(type),
            icon: icon,
            currency: row["currency"] as? String ?? "CNY",
            totalCents: row["totalCents"] as? Int64 ?? 0,
            sort: Int(row["sort"] as? Int64 ?? 0),
            description: row["description"] as? String ?? "",
            gmtCreated: Date(timeIntervalSince1970: TimeInterval(row["gmtCreated"] as? Int64 ?? 0)),
            gmtModfied: Date(timeIntervalSince1970: TimeInterval(row["gmtModfied"] as? Int64 ?? 0))
        )
    }
}
