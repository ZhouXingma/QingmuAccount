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
    // 描述信息
    var desc: String
    // 标记信息
    var mark: Bool
    
    init(day: Date, desc: String, mark: Bool) {
        self.day = day
        self.desc = desc
        self.mark = mark
    }
    /**
     是否是今日
     true:今日，false:不是今日
     */
    func isToDay(today: Date) -> Bool {
        return day.timeIntervalSince1970 == today.timeIntervalSince1970
    }
    /**
     是否是选中的日期
     true: 是， false: 不是
     */
    func isSelectDay(selectDate: Date) -> Bool{
        return day.timeIntervalSince1970 == selectDate.timeIntervalSince1970
    }
    /**
    是否是当前选择的这个月
     */
    func isThisMonth(month: Int) -> Bool {
        let monthValue = DateUtils.findComponentsOfDate([.month], date: day).month!
        return monthValue == month
    }
    
    func getDayString() -> String {
        let dayValue = DateUtils.findComponentsOfDate([.day], date: day).day!
        return String(dayValue)
    }
    
}
