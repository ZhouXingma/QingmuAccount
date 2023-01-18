//
//  DatePickerValue.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/4.
//

import SwiftUI

public class DatePickerValue {
    // 年
    var year:Int?
    // 月
    var month:Int?
    // 日
    var day:Int?
    
    init() {
        
    }
    
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
        self.year = year
        self.month = month
        self.day = day
    }
}
