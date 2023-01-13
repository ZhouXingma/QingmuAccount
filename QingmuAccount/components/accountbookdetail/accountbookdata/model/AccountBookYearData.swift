//
//  AccountBook.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI
class AccountBookYearData : Identifiable,Encodable,Decodable {
    var version = "1.0"
    // 年份
    var year:Int
    // yyyyMM ：[data]
    var data:[String:[AccountBookData]] = [:]
    
    init(version: String = "1.0", year: Int) {
        self.version = version
        self.year = year
    }
}
