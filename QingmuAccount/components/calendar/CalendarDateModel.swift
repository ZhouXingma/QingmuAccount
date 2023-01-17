//
//  CalendarDateModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/25.
//

import SwiftUI

class CalendarDateModel  {
    // 日期
    var day: Date
    var yearValue:Int
    var monthValue:Int
    var dayValue:Int
    // 描述信息
    var desc: String
    // 标记信息
    var mark: Bool
    // 是否当前这个月
    var isCurrentMonth:Bool
    // 是否是今天
    var isToday:Bool
    
    init(day: Date, yearValue:Int, monthValue:Int, dayValue:Int, desc: String, mark: Bool, isCurrentMonth:Bool, isToday:Bool = false) {
        self.day = day
        self.yearValue = yearValue
        self.monthValue = monthValue
        self.dayValue = dayValue
        self.desc = desc
        self.mark = mark
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
    }
    
    func isSelectedDay(_ selectDate:Date) -> Bool {
        let dayComponent = DateUtils.findComponentsOfDate([.year,.month,.day], date: selectDate)
        let dateYear = dayComponent.year!
        let dateMonth = dayComponent.month!
        let dateDay = dayComponent.day!
        return dateYear == yearValue && dateMonth == monthValue && dateDay == dayValue
    
    }
}
