//
//  AccountBookOfMonth.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation

import SwiftUI
class AccountBookData : Hashable,Identifiable,Encodable,Decodable {
    static func == (lhs: AccountBookData, rhs: AccountBookData) -> Bool {
        return lhs.id == rhs.id && lhs.dateStr == rhs.dateStr && lhs.gmtCreated == rhs.gmtCreated && lhs.gmtModfied == rhs.gmtModfied && lhs.type == rhs.type && lhs.money == rhs.money && lhs.iconStr == rhs.iconStr && lhs.title == rhs.title && lhs.desc == rhs.desc
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(dateStr)
        hasher.combine(gmtCreated)
        hasher.combine(gmtModfied)
        hasher.combine(type)
        hasher.combine(money)
        hasher.combine(iconStr)
        hasher.combine(title)
        hasher.combine(desc)
    }
    
    
    var version = "1.0"
    // 记录id
    var id:UUID = UUID()
    // 日期：yyyyMMdd
    var dateStr:String
    // 操作时间
    var gmtCreated:Date
    // 修改时间
    var gmtModfied:Date
    // 支付类型 0:支出 1:收入
    var type:Int
    // 金额
    var money:String
    // 图标
    var iconStr:String
    // 标题
    var title:String
    // 备注
    var desc:String
    
    init(version: String = "1.0", id: UUID = UUID(), dateStr: String, gmtCreated: Date = Date(), gmtModfied: Date = Date(), type: Int, money: String, iconStr: String, title: String, desc: String) {
        self.version = version
        self.id = id
        self.dateStr = dateStr
        self.gmtCreated = gmtCreated
        self.gmtModfied = gmtModfied
        self.type = type
        self.money = money
        self.iconStr = iconStr
        self.title = title
        self.desc = desc
    }
}

