//
//  OverviewModel.swift
//  QingmuAccount
//
//  概览数据模型
//  Created by 周荥马 on 2024/7/3.
//

import Foundation

// 概览汇总数据（预留）
class OverviewSummaryData {
    // 月度汇总：yyyyMM -> 月收支合计
    var monthlyTotals: [String: IncomeExpensesTotal] = [:]
    // 年度汇总：year -> 年收支合计
    var yearlyTotals: [Int: IncomeExpensesTotal] = [:]

    init() {}
}

// 单个账本某个币种的收支
struct OverviewBookCurrencySum: Identifiable {
    var id: String { currency }
    let currency: String
    var income: Decimal = 0
    var expenses: Decimal = 0
    var balance: Decimal { income - expenses }
}

// 概览页单个账本明细（按币种分组）
struct OverviewBookDetail: Identifiable {
    var id: String { bookId }
    var bookName: String
    var bookId: String
    var currencySums: [OverviewBookCurrencySum]
}

/// 币种排序：CNY 优先，其余按 AssetCurrency 声明顺序，未知币种排最后（与统计/日历口径一致）
func overviewSortedCurrencies(_ set: Set<String>) -> [String] {
    let order: [String: Int] = Dictionary(uniqueKeysWithValues: AssetCurrency.allCases.enumerated().map { ($0.element.rawValue, $0.offset) })
    return set.sorted { a, b in
        if a == "CNY" { return true }
        if b == "CNY" { return false }
        let oa = order[a] ?? Int.max
        let ob = order[b] ?? Int.max
        if oa != ob { return oa < ob }
        return a < b
    }
}
