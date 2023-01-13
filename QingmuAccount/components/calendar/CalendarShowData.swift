//
//  CalendarShowData.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/27.
//

import Foundation

class CalendarShowData {
    // 前一个日历视图
    var pre:CalendarShowDateItems = CalendarShowDateItems()
    // 当前显示的日历视图
    var show:CalendarShowDateItems = CalendarShowDateItems()
    // 下一个日历视图
    var next:CalendarShowDateItems = CalendarShowDateItems()
    
    public func calendarCount() -> Int {
        return 3
    }
}
class CalendarShowDateItems {
    var year:Int = 0
    var month:Int = 0
    var datas:[CalendarDateModel] = []
    
    init(year: Int = 0, month: Int = 0, datas: [CalendarDateModel] = []) {
        self.year = year
        self.month = month
        self.datas = datas
    }
}
