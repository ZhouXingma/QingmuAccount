//
//  DateUtils.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/25.
//

import SwiftUI

class DateUtils {
    
    public static func transWeekDat2ChineseString(_ weekDay:Int) -> String {
        var value = ""
        switch weekDay {
        case 1 : value = "日"
        case 2 : value = "一"
        case 3 : value = "二"
        case 4 : value = "三"
        case 5 : value = "四"
        case 6 : value = "五"
        case 7 : value = "六"
        default: value = ""
        }
        return value
    }
    
    /**
     获取某年某月月有多少天
     */
    public static func monthOfDayLength(year:Int, month:Int) -> Int {
        // 开始日期
        var start = DateComponents()
        start.year = year
        start.month = month
        start.day = 1
        // 结束日期
        var end  = DateComponents();
        let isNewYear = month + 1 > 12
        end.year = isNewYear ? year + 1 : year
        end.month = isNewYear ? 1 :month + 1
        end.day = 1
        // 日期差距
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.day], from: start, to: end)
        return diff.day!
    }
    /**
     某个月的第一天是星期几
     */
    public static func monthOfFirstDayOfWeek(year:Int, month:Int) -> Int {
        return dayOfWeek(year: year, month: month, day: 1)
    }
    /**
     某一天是星期几
     0,1,2,3,4,5,6(日一二三四五六)
     */
    public static func dayOfWeek(year:Int, month:Int, day:Int) -> Int {
        var dateComponents = DateComponents();
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        let weekDay = calendar.component(.weekday, from: date!)
        return weekDay-1
    }
    /**
     转换成Date
     */
    public static func trans2Date(year:Int, month:Int, day:Int, hour:Int = 0, minute:Int = 0, second:Int = 0, nanosecond:Int = 0) -> Date? {
        var dateComponents = DateComponents();
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.nanosecond = nanosecond
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)
    }
    /**
    获取日期的某个DateComponents，可以是年，月，日，时，分，秒，星期
     */
    public static func findComponentsOfDate(_ components:Set<Calendar.Component>, date:Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents(components, from: date)
    }
    /**
     日期转为字符串
     */
    public static func transDate2String(_ date:Date, format:String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from: date)
    }
    /**
     将字符串转换为时间
     */
    public static func transString2Date(_ dateStr:String, format:String) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.date(from: dateStr)
    }
    /**
     几天后，或者几天前
     count > 0 几天后
     count < 0几天前
     */
    public static func nextDay(_ date:Date, count:Double) -> Date {
        if (count == 0) {
            return date
        }
        let changeSecond:Double = 24 * 60 * 60 * count
        return date + changeSecond
    }
    /**
     一天的开始
     */
    public static func dayStart(_ date:Date) -> Date {
        let calendar  = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: dateComponents)!
    }

    /**
     一天的结束
     */
    public static func dayEnd(_ date:Date) -> Date {
        let dayStartDate = dayStart(date)
        var handleComponts = DateComponents()
        handleComponts.day = 1
        handleComponts.second = -1
        let calendar  = Calendar.current
        let endDayDate = calendar.date(byAdding: handleComponts, to: dayStartDate)!
        return endDayDate
    }
    
    /**
     年度和月度转换为yyyyMM格式
     */
    public static func ymStr(_ year:Int, _ month:Int) -> String {
        let monthStr = month < 10 ? "0\(month)" : "\(month)"
        let ymStr = String("\(year)\(monthStr)")
        return ymStr
    }
    
    /**
     年度和月度转换为yyyyMM格式
     */
    public static func ymStr(_ date:Date) -> String {
       return transDate2String(date, format: "yyyyMM")
    }

}
