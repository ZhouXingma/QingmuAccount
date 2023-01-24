//
//  AssertsDetailListGroupModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2023/1/19.
//

import Foundation
class AssertsDetailListGroupModel {
    // 年
    var year:Int
    // 月
    var moth:Int
    // 总金额
    var totalMoney:Decimal
    // 数据集合
    var datas:[AssertsDataItem]
    
    init(year: Int, moth: Int, totalMoney: Decimal, datas: [AssertsDataItem] = []) {
        self.year = year
        self.moth = moth
        self.totalMoney = totalMoney
        self.datas = datas
    }
}
