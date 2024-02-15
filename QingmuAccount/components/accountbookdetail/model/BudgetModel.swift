//
//  BudgetModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2024/1/15.
//  预算模型
//

import Foundation

// 历史预算使用情况
class HistoryBudgetUse {
    var historyList:[HistoryBudgetUseDetail] = []
}
// 历史预算使用情况 - 详情
struct HistoryBudgetUseDetail:Hashable {
    static func == (lhs: HistoryBudgetUseDetail, rhs: HistoryBudgetUseDetail) -> Bool {
        lhs.monthDate == rhs.monthDate && lhs.budgetValue == rhs.budgetValue && lhs.useValue == rhs.useValue
    }
    // 预算的月份
    var monthDate:String
    // 预算金额
    var budgetValue:Decimal
    // 使用金额
    var useValue:Decimal

    init(monthDate:String, budgetValue:Decimal, useValue:Decimal) {
        self.monthDate = monthDate
        self.budgetValue = budgetValue
        self.useValue = useValue
    }
    
    public func getMothDateOfMoth() -> String {
        if monthDate.lengthOfBytes(using: .utf8) != 6 {
            return "「未知」"
        }
        let start = monthDate.index(monthDate.startIndex,offsetBy: 4)
        let end = monthDate.index(monthDate.startIndex,offsetBy: 6)
        return String(monthDate[start..<end])
    }
}





