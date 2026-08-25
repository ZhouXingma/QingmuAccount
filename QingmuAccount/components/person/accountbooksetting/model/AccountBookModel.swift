//
//  AccountBookModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

class AccountBookModel : Identifiable,Encodable,Decodable,Hashable{
    static func == (lhs: AccountBookModel, rhs: AccountBookModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.iconStr == rhs.iconStr && lhs.gmtCreated == rhs.gmtCreated && lhs.bgColor == rhs.bgColor && lhs.defaultAssetAccountId == rhs.defaultAssetAccountId && lhs.defaultCurrency == rhs.defaultCurrency
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(bgColor)
        hasher.combine(iconStr)
        hasher.combine(gmtCreated)
        hasher.combine(defaultAssetAccountId)
        hasher.combine(defaultCurrency)
    }

    var id = UUID()
    // 账本名称
    var name:String
    // 图标
    var iconStr:String
    // 背景颜色
    var bgColor:String
    // 账本描述
    var description:String?
    // 默认资产账户 id（账本关联账户，空表示未设置）
    var defaultAssetAccountId:String
    // 默认币型（ISO 代码，记账未选账户时的兜底币型）
    var defaultCurrency:String
    // 创建时间
    var gmtCreated:Date


    init(id: UUID = UUID(), name: String, iconStr:String, bgColor:String, description:String? = nil, defaultAssetAccountId:String = "", defaultCurrency:String = "CNY", gmtCreated:Date = Date()) {
        self.id = id
        self.name = name
        self.iconStr = iconStr
        self.bgColor = bgColor
        self.description = description
        self.defaultAssetAccountId = defaultAssetAccountId
        self.defaultCurrency = defaultCurrency
        self.gmtCreated = gmtCreated
    }

    enum CodingKeys: String, CodingKey {
        case id, name, iconStr, bgColor, description, defaultAssetAccountId, defaultCurrency, gmtCreated
    }

    // 兼容旧版 JSON：新增的 defaultAssetAccountId/defaultCurrency 缺省时兜底，缺 id 时生成新 UUID
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        iconStr = try container.decode(String.self, forKey: .iconStr)
        bgColor = try container.decode(String.self, forKey: .bgColor)
        description = try? container.decode(String.self, forKey: .description)
        defaultAssetAccountId = (try? container.decode(String.self, forKey: .defaultAssetAccountId)) ?? ""
        defaultCurrency = (try? container.decode(String.self, forKey: .defaultCurrency)) ?? "CNY"
        gmtCreated = try container.decode(Date.self, forKey: .gmtCreated)
    }
}



