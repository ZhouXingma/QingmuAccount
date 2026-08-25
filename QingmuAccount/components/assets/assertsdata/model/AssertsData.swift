//
//  AssertsData.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/29.
//

import Foundation
class AssertsData : Identifiable,Encodable,Decodable {
    var version = "1.0"
    // 存款
    var deposit:[String:String] = [:]
    // 负债
    var liabilities:[String:String] = [:]
    // ym:[]
    var depositData:[String:[AssertsDataItem]] = [:]
    // ym:[]
    var liabilitiesData:[String:[AssertsDataItem]] = [:]
}




class AssertsDataItem : Hashable,Identifiable,Encodable,Decodable {
    static func == (lhs: AssertsDataItem, rhs: AssertsDataItem) -> Bool {
        return lhs.id == rhs.id &&
        lhs.accountName == rhs.accountName &&
        lhs.itemName == rhs.itemName &&
        lhs.gmtCreated == rhs.gmtCreated &&
        lhs.gmtModfied == rhs.gmtModfied &&
        lhs.type == rhs.type &&
        lhs.money == rhs.money
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(accountName)
        hasher.combine(itemName)
        hasher.combine(gmtCreated)
        hasher.combine(gmtModfied)
        hasher.combine(type)
        hasher.combine(money)
    }
    
    var version = "1.0"
    // 记录id
    var id:UUID = UUID()
    // 账户名称
    var accountName:String
    // 名称
    var itemName:String
    // 操作时间
    var gmtCreated:Date
    // 修改时间
    var gmtModfied:Date
    // 类型 0:-,1:+
    var type:Int
    // 金钱
    var money:String
    
    init(version: String = "1.0", id: UUID = UUID(), accountName: String, itemName: String, gmtCreated: Date, gmtModfied: Date, type: Int, money: String) {
        self.version = version
        self.id = id
        self.accountName = accountName
        self.itemName = itemName
        self.gmtCreated = gmtCreated
        self.gmtModfied = gmtModfied
        self.type = type
        self.money = money
    }
}
