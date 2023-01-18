//
//  AccountBookSettingOfIconModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/6.
//

import SwiftUI
class AccountBookSetingOfIconModel : Identifiable,Encodable,Decodable,Hashable {
    static func == (lhs: AccountBookSetingOfIconModel, rhs: AccountBookSetingOfIconModel) -> Bool {
        return lhs.id == rhs.id && lhs.iconStr == rhs.iconStr && lhs.name == rhs.name && lhs.sort == rhs.sort
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(iconStr)
        hasher.combine(name)
        hasher.combine(sort)
    }
    var id:String
    var iconStr:String
    var name:String
    var sort:Int
    
    init(id:String = UUID().description, iconStr: String, name: String, sort: Int) {
        self.id = id
        self.iconStr = iconStr
        self.name = name
        self.sort = sort
    }
}
