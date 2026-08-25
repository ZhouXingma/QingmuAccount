//
//  IconSetingService.swift
//  QingmuAccount
//  账本设置的读写（SQLite 实现）：预算 + 收支图标设置。
//  Created by 周荥马 on 2022/12/6.
//

import SwiftUI

enum AccountBookSetingError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AccountBookSetingService {
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"

    public static let FILE_NAME = "accountbookSeting.json"

    public static let DEFAULT_SETING = AccountBookSetingModel()

    public static func setAccountBookSetting(_ accountBookId:String, _ setting: AccountBookSetingModel) throws {
        try SQLiteManager.shared.transaction {
            try SQLiteManager.shared.execute("DELETE FROM budget WHERE bookId=?", [accountBookId])
            try SQLiteManager.shared.execute("DELETE FROM icon_setting WHERE bookId=?", [accountBookId])
            for (ym, currencyBudgets) in setting.budget {
                for (currency, amount) in currencyBudgets {
                    try SQLiteManager.shared.execute(
                        "INSERT INTO budget(bookId,ym,currency,budgetCents) VALUES(?,?,?,?)",
                        [accountBookId, ym, currency, SQLiteManager.cents(fromMoney: "\(amount)")]
                    )
                }
            }
            for item in setting.inRecordIconSeting {
                try insertIcon(accountBookId, kind: 1, item)
            }
            for item in setting.outRecordIconSeting {
                try insertIcon(accountBookId, kind: 0, item)
            }
        }
    }

    /**
     读取账本设置。无任何设置数据时返回 nil。
     */
    public static func readAccountBookSetting(_ accountBookId:String) throws -> AccountBookSetingModel? {
        let budgetRows = try SQLiteManager.shared.query("SELECT ym, currency, budgetCents FROM budget WHERE bookId=?", [accountBookId])
        let inRows = try SQLiteManager.shared.query("SELECT id, iconStr, name, sort FROM icon_setting WHERE bookId=? AND kind=1 ORDER BY sort", [accountBookId])
        let outRows = try SQLiteManager.shared.query("SELECT id, iconStr, name, sort FROM icon_setting WHERE bookId=? AND kind=0 ORDER BY sort", [accountBookId])
        guard budgetRows.count > 0 || inRows.count > 0 || outRows.count > 0 else { return nil }
        let setting = AccountBookSetingModel()
        for row in budgetRows {
            if let ym = row["ym"] as? String,
               let currency = row["currency"] as? String,
               let cents = row["budgetCents"] as? Int64 {
                var currencyBudgets = setting.budget[ym] ?? [:]
                currencyBudgets[currency] = Decimal(cents) / 100
                setting.budget[ym] = currencyBudgets
            }
        }
        if inRows.count > 0 {
            setting.inRecordIconSeting = inRows.compactMap { rowToIcon($0) }
        }
        if outRows.count > 0 {
            setting.outRecordIconSeting = outRows.compactMap { rowToIcon($0) }
        }
        return setting
    }

    // MARK: - 私有

    private static func insertIcon(_ accountBookId: String, kind: Int, _ item: AccountBookSetingOfIconModel) throws {
        try SQLiteManager.shared.execute(
            "INSERT INTO icon_setting(bookId,kind,id,iconStr,name,sort) VALUES(?,?,?,?,?,?)",
            [accountBookId, kind, item.id, item.iconStr, item.name, item.sort]
        )
    }

    private static func rowToIcon(_ row: [String: Any?]) -> AccountBookSetingOfIconModel? {
        guard let id = row["id"] as? String,
              let iconStr = row["iconStr"] as? String,
              let name = row["name"] as? String,
              let sort = row["sort"] as? Int64 else { return nil }
        return AccountBookSetingOfIconModel(id: id, iconStr: iconStr, name: name, sort: Int(sort))
    }
}
