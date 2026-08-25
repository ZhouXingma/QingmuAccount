//
//  AccountBookDataService.swift
//  QingmuAccount
//  记账记录的整年读写（SQLite 实现）。money 以分（moneyCents）聚合保精度。
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI

enum AccountBookDataError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AccountBookDataService {
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"

    /**
     更新保存某一年的记录（整年幂等覆盖）
     */
    public static func setData(_ accountBookId:String, accountBookYearData:AccountBookYearData) throws {
        let pattern = "\(accountBookYearData.year)%"
        try SQLiteManager.shared.transaction {
            try SQLiteManager.shared.execute("DELETE FROM record WHERE bookId=? AND dateStr LIKE ?", [accountBookId, pattern])
            for (_, records) in accountBookYearData.data {
                for record in records {
                    try insertRecord(accountBookId, record)
                }
            }
        }
    }

    /**
     读取某一年的记录，组装为 AccountBookYearData（含按月收支合计）。无数据返回 nil。
     */
    public static func readData(_ accountBookId:String, year:Int) throws -> AccountBookYearData? {
        let pattern = "\(year)%"
        let rows = try SQLiteManager.shared.query(
            "SELECT * FROM record WHERE bookId=? AND dateStr LIKE ? ORDER BY dateStr",
            [accountBookId, pattern]
        )
        guard rows.count > 0 else { return nil }
        let yearData = AccountBookYearData(year: year)
        for row in rows {
            guard let record = rowToRecord(row) else { continue }
            let ym = String(record.dateStr.prefix(6))
            var array = yearData.data[ym] ?? []
            array.append(record)
            yearData.data[ym] = array
        }
        // 按月收支合计（SQL 聚合，替代原 updateYearDataTotal）
        let totalRows = try SQLiteManager.shared.query(
            "SELECT substr(dateStr,1,6) AS ym, type, SUM(moneyCents) AS s FROM record WHERE bookId=? AND dateStr LIKE ? GROUP BY ym, type",
            [accountBookId, pattern]
        )
        for row in totalRows {
            guard let ym = row["ym"] as? String,
                  let type = row["type"] as? Int64,
                  let cents = row["s"] as? Int64 else { continue }
            var total = yearData.total[ym] ?? IncomeExpensesTotal(income: 0, expenses: 0)
            if type == 1 {
                total.income = Decimal(cents) / 100
            } else {
                total.expenses = Decimal(cents) / 100
            }
            yearData.total[ym] = total
        }
        return yearData
    }

    // MARK: - 私有

    private static func insertRecord(_ bookId: String, _ record: AccountBookData) throws {
        try SQLiteManager.shared.execute(
            "INSERT OR REPLACE INTO record(id,bookId,dateStr,gmtCreated,gmtModfied,type,money,moneyCents,iconStr,title,desc,asset_record_id,account_id,currency) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            [
                record.id.uuidString, bookId, record.dateStr,
                Int64(record.gmtCreated.timeIntervalSince1970),
                Int64(record.gmtModfied.timeIntervalSince1970),
                record.type, record.money,
                SQLiteManager.cents(fromMoney: record.money),
                record.iconStr, record.title, record.desc, record.assetRecordId, record.accountId, record.currency
            ]
        )
    }

    private static func rowToRecord(_ row: [String: Any?]) -> AccountBookData? {
        guard let id = row["id"] as? String,
              let dateStr = row["dateStr"] as? String,
              let gmtCreated = row["gmtCreated"] as? Int64,
              let gmtModfied = row["gmtModfied"] as? Int64,
              let type = row["type"] as? Int64,
              let money = row["money"] as? String,
              let iconStr = row["iconStr"] as? String,
              let title = row["title"] as? String,
              let desc = row["desc"] as? String else { return nil }
        return AccountBookData(
            id: UUID(uuidString: id) ?? UUID(),
            dateStr: dateStr,
            gmtCreated: Date(timeIntervalSince1970: TimeInterval(gmtCreated)),
            gmtModfied: Date(timeIntervalSince1970: TimeInterval(gmtModfied)),
            type: Int(type),
            money: money,
            iconStr: iconStr,
            title: title,
            desc: desc,
            assetRecordId: row["asset_record_id"] as? String ?? "",
            accountId: row["account_id"] as? String ?? "",
            currency: row["currency"] as? String ?? "CNY"
        )
    }
}
