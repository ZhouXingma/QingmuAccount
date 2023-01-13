//
//  AccountBookModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

class AccountBookModel : Identifiable,Encodable,Decodable,Hashable{
    static func == (lhs: AccountBookModel, rhs: AccountBookModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.iconStr == rhs.iconStr && lhs.gmtCreated == rhs.gmtCreated && lhs.bgColor == rhs.bgColor
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(bgColor)
        hasher.combine(iconStr)
        hasher.combine(gmtCreated)
    }
    
    var id = UUID()
    // 账本名称
    var name:String
    // 图标
    var iconStr:String
    // 背景颜色
    var bgColor:String
    // 创建时间
    var gmtCreated:Date
    
    
    init(id: UUID = UUID(), name: String, iconStr:String, bgColor:String, gmtCreated:Date = Date()) {
        self.id = id
        self.name = name
        self.iconStr = iconStr
        self.bgColor = bgColor
        self.gmtCreated = gmtCreated
    }
}


