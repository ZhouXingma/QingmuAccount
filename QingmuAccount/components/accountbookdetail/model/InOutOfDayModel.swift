//
//  InOutOfMonthModel.swift
//  QingmuAccount
//  月度收支情况
//  Created by 周荥马 on 2022/12/8.
//

import Foundation

class InOutOfDayModel {
    // 日期 yyyyMMdd
    var dateStr:String
    // 收入
    var income:Decimal = 0
    // 支出
    var expend:Decimal = 0
    // 结余
    var balance:Decimal = 0
    // 当日记录
    var data:[AccountBookData] = []
    
    init(dateStr: String, income: Decimal = 0, expend: Decimal = 0, balance: Decimal = 0, data: [AccountBookData] = []) {
        self.dateStr = dateStr
        self.income = income
        self.expend = expend
        self.balance = balance
        self.data = data
    }
    
    public func addData(_ dataItem:AccountBookData) {
        data.append(dataItem)
        if (dataItem.type == 0) {
            // 支出
            expend = expend + (Decimal(string: dataItem.money) ?? 0)
        } else {
            // 收入
            income = income + (Decimal(string: dataItem.money) ?? 0)
        }
        computerBalance()
    }
    
    public func getDataWithSort() -> [AccountBookData]{
        return data.sorted { item1, item2 in
            item1.gmtCreated >= item2.gmtCreated
        }
    }
    
    /**
     计算结余
     */
    private func computerBalance() {
        balance = income - expend
    }
    
    
}
