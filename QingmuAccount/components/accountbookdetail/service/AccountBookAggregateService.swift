//
//  AccountBookAggregateService.swift
//  QingmuAccount
//  SQL 聚合查询：概览、统计、预算、日历的数据聚合，替代原来「读整年 JSON + 内存遍历」。
//  金额一律按分（moneyCents）求和，返回时转 Decimal 保证精度。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

// 按（账本, 类型, 币种）聚合的结果
struct BookTypeSum {
    let bookId: String
    let type: Int
    let currency: String
    let sum: Decimal
    let count: Int
}

// 按（日期/标题, 类型）聚合的结果
struct GroupSum {
    let group: String
    let type: Int
    let sum: Decimal
    let count: Int
}

// 按标题分组（含图标）
struct TitleGroupSum {
    let title: String
    let iconStr: String
    let type: Int
    let sum: Decimal
    let count: Int
}

class AccountBookAggregateService {
    /**
     跨账本：某月（month 非空）或某年各账本各类型各币种的收入支出合计。
     */
    static func bookTypeSums(year: Int, month: Int? = nil) throws -> [BookTypeSum] {
        let pattern = ymPattern(year: year, month: month)
        let rows = try SQLiteManager.shared.query(
            "SELECT bookId, type, currency, SUM(moneyCents) AS s, COUNT(*) AS c FROM record WHERE dateStr LIKE ? GROUP BY bookId, type, currency",
            [pattern]
        )
        return rows.compactMap { row in
            guard let bookId = row["bookId"] as? String,
                  let type = row["type"] as? Int64,
                  let cents = row["s"] as? Int64 else { return nil }
            let currency = (row["currency"] as? String) ?? ""
            return BookTypeSum(bookId: bookId, type: Int(type), currency: currency.isEmpty ? "CNY" : currency, sum: Decimal(cents) / 100, count: Int(row["c"] as? Int64 ?? 0))
        }
    }

    /**
     单账本某月（month 非空）或某年收入支出合计。
     */
    static func incomeExpenses(bookId: String, year: Int, month: Int? = nil) throws -> (income: Decimal, expenses: Decimal) {
        let pattern = ymPattern(year: year, month: month)
        let rows = try SQLiteManager.shared.query(
            "SELECT type, SUM(moneyCents) AS s FROM record WHERE bookId=? AND dateStr LIKE ? GROUP BY type",
            [bookId, pattern]
        )
        var income = Decimal(0)
        var expenses = Decimal(0)
        for row in rows {
            guard let type = row["type"] as? Int64, let cents = row["s"] as? Int64 else { continue }
            if type == 1 {
                income = Decimal(cents) / 100
            } else {
                expenses = Decimal(cents) / 100
            }
        }
        return (income, expenses)
    }

    /**
     单账本某月按日期（yyyyMMdd）分组，用于统计折线图与日历标记。
     */
    static func groupByDate(bookId: String, year: Int, month: Int) throws -> [GroupSum] {
        let pattern = ymPattern(year: year, month: month)
        let rows = try SQLiteManager.shared.query(
            "SELECT dateStr, type, SUM(moneyCents) AS s, COUNT(*) AS c FROM record WHERE bookId=? AND dateStr LIKE ? GROUP BY dateStr, type",
            [bookId, pattern]
        )
        return rows.compactMap { row in
            guard let dateStr = row["dateStr"] as? String,
                  let type = row["type"] as? Int64,
                  let cents = row["s"] as? Int64 else { return nil }
            return GroupSum(group: dateStr, type: Int(type), sum: Decimal(cents) / 100, count: Int(row["c"] as? Int64 ?? 0))
        }
    }

    /**
     单账本某月按标题分组，用于统计饼图。
     */
    static func groupByTitle(bookId: String, year: Int, month: Int) throws -> [TitleGroupSum] {
        let pattern = ymPattern(year: year, month: month)
        let rows = try SQLiteManager.shared.query(
            "SELECT title, iconStr, type, SUM(moneyCents) AS s, COUNT(*) AS c FROM record WHERE bookId=? AND dateStr LIKE ? GROUP BY title, type",
            [bookId, pattern]
        )
        return rows.compactMap { row in
            guard let title = row["title"] as? String,
                  let iconStr = row["iconStr"] as? String,
                  let type = row["type"] as? Int64,
                  let cents = row["s"] as? Int64 else { return nil }
            return TitleGroupSum(title: title, iconStr: iconStr, type: Int(type), sum: Decimal(cents) / 100, count: Int(row["c"] as? Int64 ?? 0))
        }
    }

    /**
     单账本某月支出合计（预算已用）。
     */
    static func expensesOfMonth(bookId: String, year: Int, month: Int) throws -> Decimal {
        let pattern = ymPattern(year: year, month: month)
        return try sumExpenses(bookId: bookId, pattern: pattern)
    }

    /**
     单账本某天支出合计（预算今日已用）。
     */
    static func expensesOfDay(bookId: String, dateStr: String) throws -> Decimal {
        return try sumExpenses(bookId: bookId, pattern: dateStr)
    }

    /**
     单账本某月每日支出合计（日历收支标记）。
     */
    static func dayExpenses(bookId: String, year: Int, month: Int) throws -> [GroupSum] {
        let pattern = ymPattern(year: year, month: month)
        let rows = try SQLiteManager.shared.query(
            "SELECT dateStr, type, SUM(moneyCents) AS s, COUNT(*) AS c FROM record WHERE bookId=? AND dateStr LIKE ? AND type=0 GROUP BY dateStr",
            [bookId, pattern]
        )
        return rows.compactMap { row in
            guard let dateStr = row["dateStr"] as? String, let cents = row["s"] as? Int64 else { return nil }
            return GroupSum(group: dateStr, type: 0, sum: Decimal(cents) / 100, count: Int(row["c"] as? Int64 ?? 0))
        }
    }

    // MARK: - 私有

    private static func ymPattern(year: Int, month: Int?) -> String {
        if let month = month {
            return String(format: "%04d%02d%%", year, month)
        }
        return "\(year)%"
    }

    private static func sumExpenses(bookId: String, pattern: String) throws -> Decimal {
        let rows = try SQLiteManager.shared.query(
            "SELECT SUM(moneyCents) AS s FROM record WHERE bookId=? AND type=0 AND dateStr LIKE ?",
            [bookId, pattern]
        )
        guard let cents = rows.first?["s"] as? Int64 else { return Decimal(0) }
        return Decimal(cents) / 100
    }
}
