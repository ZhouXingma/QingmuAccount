//
//  DatePickerValue.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/4.
//

import SwiftUI

public class DataPickerValue {
    // key
    var key:String?
    // 数据
    var data:String?
    
    init() {
        
    }
    
    init(key: String? = nil, data: String? = nil) {
        self.key = key
        self.data = data
    }
}
