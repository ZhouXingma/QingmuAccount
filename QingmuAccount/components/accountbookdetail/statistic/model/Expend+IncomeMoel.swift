//
//  AccountBookStatisticModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/22.
//

import Foundation

class StatisticsData {
    var expendData:ExpendIncomeModel = ExpendIncomeModel()
    var incomeData:ExpendIncomeModel = ExpendIncomeModel()
}

class ExpendIncomeModel {
    // 收支数量（笔数）
    var totalCount:Int = 0
    // 收支总金额
    var totalValue:Decimal = 0
    // 收支数量集合,日:金额
    var monthData:[String:ExpendIncomeDateData] = [:]
    // 根据标题分类统计数据
    var titleData:[String:ExpendIncomeTitleData] = [:]
    // 转换折线图数据
    // type类型：0：月，1:年
    func charData(year:Int, month:Int, type:Int) -> ChartData {
        if type == 0{
            let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
            var values:[(String,Double)] = []
            for day in 1...dayLength {
                let dayStr = day < 10 ? String("0\(day)") : String("\(day)")
                let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
                let ymd = String("\(year)\(monthStr)\(dayStr)")
                let dayValue = monthData[ymd]?.value ?? 0.0
                values.append((String("\(day)"), dayValue.doubleValue))
            }
            return ChartData(values: values)
        } else {
            var values:[(String,Double)] = []
            for month in 1...12 {
                let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
                let ym = String("\(year)\(monthStr)")
                let monthValue = monthData[ym]?.value ?? 0.0
                values.append((String("\(month)"), monthValue.doubleValue))
            }
            return ChartData(values: values)
        }
       
    }
    // 转换饼图数据
    func peiDataList() -> [PieData] {
        var data:[PieData] = []
        for item in titleData.values {
            data.append(PieData(itemName: item.title, itemValue: item.value.doubleValue))
        }
        return data
    }
    // 根据类别暂时列表
    // @param sotType 排序类型，0:按照金额，1:按照支付笔数
    func titleDataListWithSort(sortType:Int) -> [ExpendIncomeTitleData]{
        let groupValues = titleData.values.sorted { item1, item2 in
            if sortType == 0 {
                return item1.value >= item2.value
            } else {
                return item1.count >= item2.count
            }
        }
        return groupValues
    }
}



// 收支数据模型
class ExpendIncomeDateData {
    var dateStr:String
    var value:Decimal
    var count:Int
    init(dateStr: String, value: Decimal = 0, count: Int = 0) {
        self.dateStr = dateStr
        self.value = value
        self.count = count
    }
}

// 收支数据模型
class ExpendIncomeTitleData {
    // 标题
    var title:String
    // 图标
    var iconStr:String
    // 总金额
    var value:Decimal
    // 总笔数
    var count:Int
    // 记录列表
    var list:[AccountBookData]
    
    init(title: String, iconStr: String = "", value: Decimal = 0, count: Int = 0, list:[AccountBookData] = []) {
        self.title = title
        self.iconStr = iconStr
        self.value = value
        self.count = count
        self.list = list
    }
}


class ExpendIncomeDetailData : ObservableObject {
    @Published var data:ExpendIncomeTitleData? = nil
    
    init() {
    }
    init(data:ExpendIncomeTitleData) {
        self.data = data
    }
}


