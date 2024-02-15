//
//  AccountBook.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI
class AccountBookYearData : Identifiable,Encodable,Decodable {
    var version = "1.0"
    // 年份
    var year:Int
    // 数据
    // yyyyMM ：[data]
    var data:[String:[AccountBookData]] = [:]
    // 数据综合试验区
    // yyyyMM ：Decimal
    var total:[String:IncomeExpensesTotal] = [:]
    
    init(version: String = "1.0", year: Int, total:[String:IncomeExpensesTotal] = [:]) {
        self.version = version
        self.year = year
        self.total = total
    }
}

class IncomeExpensesTotal : Identifiable,Encodable,Decodable {
    // 收入合计
    var income:Decimal = Decimal(0.0)
    // 支出合计
    var expenses:Decimal = Decimal(0.0)
    var balance:Decimal {
        get {
            return income - expenses
        }
    }
    
    init(income:Decimal, expenses:Decimal) {
        self.income = income
        self.expenses = expenses
    }
}
