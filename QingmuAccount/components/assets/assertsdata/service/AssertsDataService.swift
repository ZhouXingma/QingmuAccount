//
//  AssertsDataService.swift
//  QingmuAccount
//  资产/负债数据的读写（SQLite 实现）。
//  Created by 周荥马 on 2022/12/29.
//

import Foundation

enum AssertsDataError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AssertsDataService {
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"

    public static let FILE_NAME = "asserts.json"

    public static let DEFAULT_ASSERTS = AssertsData()

    /**
     更新保存数据（整份重灌）
     */
    public static func setData(assertsData:AssertsData) throws {
        try SQLiteManager.shared.transaction {
            try SQLiteManager.shared.execute("DELETE FROM asserts_account")
            try SQLiteManager.shared.execute("DELETE FROM asserts_item")
            for (kind, dict) in [(0, assertsData.deposit), (1, assertsData.liabilities)] {
                for (accountName, moneyStr) in dict {
                    try SQLiteManager.shared.execute(
                        "INSERT INTO asserts_account(kind,accountName,totalCents) VALUES(?,?,?)",
                        [kind, accountName, SQLiteManager.cents(fromMoney: moneyStr)]
                    )
                }
            }
            for (kind, dataDict) in [(0, assertsData.depositData), (1, assertsData.liabilitiesData)] {
                for (ym, items) in dataDict {
                    for item in items {
                        try insertItem(kind, ym: ym, item)
                    }
                }
            }
        }
    }

    /**
     读取数据。无任何资产数据时返回 nil。
     */
    public static func readData() throws -> AssertsData? {
        let accounts = try SQLiteManager.shared.query("SELECT kind, accountName, totalCents FROM asserts_account")
        let items = try SQLiteManager.shared.query("SELECT * FROM asserts_item")
        guard accounts.count > 0 || items.count > 0 else { return nil }
        let asserts = AssertsData()
        for row in accounts {
            guard let kind = row["kind"] as? Int64, let accountName = row["accountName"] as? String else { continue }
            let cents = row["totalCents"] as? Int64 ?? 0
            let moneyStr = SQLiteManager.money(fromCents: cents)
            if kind == 0 {
                asserts.deposit[accountName] = moneyStr
            } else {
                asserts.liabilities[accountName] = moneyStr
            }
        }
        for row in items {
            guard let kind = row["kind"] as? Int64, let ym = row["ym"] as? String, let item = rowToItem(row) else { continue }
            if kind == 0 {
                var array = asserts.depositData[ym] ?? []
                array.append(item)
                asserts.depositData[ym] = array
            } else {
                var array = asserts.liabilitiesData[ym] ?? []
                array.append(item)
                asserts.liabilitiesData[ym] = array
            }
        }
        return asserts
    }

    // MARK: - 私有

    private static func insertItem(_ kind: Int, ym: String, _ item: AssertsDataItem) throws {
        try SQLiteManager.shared.execute(
            "INSERT OR REPLACE INTO asserts_item(id,kind,accountName,itemName,gmtCreated,gmtModfied,itemType,money,moneyCents,ym) VALUES(?,?,?,?,?,?,?,?,?,?)",
            [
                item.id.uuidString, kind, item.accountName, item.itemName,
                Int64(item.gmtCreated.timeIntervalSince1970),
                Int64(item.gmtModfied.timeIntervalSince1970),
                item.type, item.money,
                SQLiteManager.cents(fromMoney: item.money),
                ym
            ]
        )
    }

    private static func rowToItem(_ row: [String: Any?]) -> AssertsDataItem? {
        guard let id = row["id"] as? String,
              let accountName = row["accountName"] as? String,
              let itemName = row["itemName"] as? String,
              let gmtCreated = row["gmtCreated"] as? Int64,
              let gmtModfied = row["gmtModfied"] as? Int64,
              let itemType = row["itemType"] as? Int64,
              let money = row["money"] as? String else { return nil }
        return AssertsDataItem(
            id: UUID(uuidString: id) ?? UUID(),
            accountName: accountName,
            itemName: itemName,
            gmtCreated: Date(timeIntervalSince1970: TimeInterval(gmtCreated)),
            gmtModfied: Date(timeIntervalSince1970: TimeInterval(gmtModfied)),
            type: Int(itemType),
            money: money
        )
    }
}
