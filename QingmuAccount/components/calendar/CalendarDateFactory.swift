//
//  CalendarDateFactory.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/25.
//

import Foundation



func createCalendarShowData(year:Int, month:Int) -> CalendarShowData {
    let result = CalendarShowData()
    var preYear = year
    var preMonth = month - 1
    if (preMonth < 1) {
        preMonth = 12
        preYear = preYear - 1
    }
    
    var nextYear = year
    var nextMonth = month + 1
    if (nextMonth > 12) {
        nextMonth = 1
        nextYear = nextYear + 1
    }
    result.pre = CalendarShowDateItems(year: preYear, month: preMonth)
    result.show = CalendarShowDateItems(year: year, month: month)
    result.next = CalendarShowDateItems(year: nextYear, month: nextMonth)
    
    result.pre.datas = createCalendarDateModelsaOfMonth(year: preYear, month: preMonth)
    result.show.datas = createCalendarDateModelsaOfMonth(year: year, month: month)
    result.next.datas = createCalendarDateModelsaOfMonth(year: nextYear, month: nextMonth)
    return result
}

func createCalendarDateModelsaOfMonth(year:Int, month:Int) ->[CalendarDateModel]{
    // 获取这个个月的第一天
    let firstDateOfMonth = DateUtils.trans2Date(year: year, month: month, day: 1)!
    // 获取这一天是星期几,也是在这个日历上1号之前要补充的天数
    let monthBeforeSupplementCount = DateUtils.dayOfWeek(year: year, month: month, day: 1)
    // 这个月一共有几天
    let dayLengthOfMonth = DateUtils.monthOfDayLength(year: year, month: month)
    // 这个月日历一共要显示多少天
    let dayCount = calendarDayComponentShowDayCount(dayLengthOfMonth: dayLengthOfMonth, monthBeforeSupplementCount: monthBeforeSupplementCount)
    // 开始的日期
    let startDate = DateUtils.nextDay(firstDateOfMonth, count: Double(-monthBeforeSupplementCount))
    // 返回的日历字典集合
    var result:[CalendarDateModel] = []
    for index in 0..<dayCount {
        let resultDate = DateUtils.nextDay(startDate, count: Double(index))
        result.append(CalendarDateModel(day: resultDate, desc: "", mark: false))
    }
    return result
}
/**
 日历组件显示天数计算
 dayLengthOfMonth: 这个月一共有的天数
 monthBeforeSupplementCount：这个月之前要补充的天数
 */
func calendarDayComponentShowDayCount(dayLengthOfMonth:Int, monthBeforeSupplementCount:Int) -> Int{
    var result = dayLengthOfMonth + monthBeforeSupplementCount
    // 获取余数
    let y = result % 7
    if (y != 0) {
        result = ((dayLengthOfMonth + monthBeforeSupplementCount)/7 + 1) * 7
    }
    return result
}



