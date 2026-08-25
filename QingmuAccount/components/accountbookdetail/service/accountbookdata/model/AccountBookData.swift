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
        return lhs.id == rhs.id && lhs.dateStr == rhs.dateStr && lhs.gmtCreated == rhs.gmtCreated && lhs.gmtModfied == rhs.gmtModfied && lhs.type == rhs.type && lhs.money == rhs.money && lhs.iconStr == rhs.iconStr && lhs.title == rhs.title && lhs.desc == rhs.desc && lhs.assetRecordId == rhs.assetRecordId && lhs.accountId == rhs.accountId && lhs.currency == rhs.currency
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
        hasher.combine(assetRecordId)
        hasher.combine(accountId)
        hasher.combine(currency)
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
    // 关联的资产账户记录 id（记账联动账户，空表示未关联）
    var assetRecordId:String
    // 记账所选资产账户 id（空表示未选账户）
    var accountId:String
    // 币型（ISO 代码，取自账户币型，默认 CNY）
    var currency:String

    init(version: String = "1.0", id: UUID = UUID(), dateStr: String, gmtCreated: Date = Date(), gmtModfied: Date = Date(), type: Int, money: String, iconStr: String, title: String, desc: String, assetRecordId: String = "", accountId: String = "", currency: String = "CNY") {
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
        self.assetRecordId = assetRecordId
        self.accountId = accountId
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case version, id, dateStr, gmtCreated, gmtModfied, type, money, iconStr, title, desc, assetRecordId, accountId, currency
    }

    // 兼容旧版 JSON：新增的 assetRecordId/accountId/currency 缺省时兜底
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = (try? container.decode(String.self, forKey: .version)) ?? "1.0"
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        dateStr = try container.decode(String.self, forKey: .dateStr)
        gmtCreated = try container.decode(Date.self, forKey: .gmtCreated)
        gmtModfied = try container.decode(Date.self, forKey: .gmtModfied)
        type = try container.decode(Int.self, forKey: .type)
        money = try container.decode(String.self, forKey: .money)
        iconStr = try container.decode(String.self, forKey: .iconStr)
        title = try container.decode(String.self, forKey: .title)
        desc = (try? container.decode(String.self, forKey: .desc)) ?? ""
        assetRecordId = (try? container.decode(String.self, forKey: .assetRecordId)) ?? ""
        accountId = (try? container.decode(String.self, forKey: .accountId)) ?? ""
        currency = (try? container.decode(String.self, forKey: .currency)) ?? "CNY"
    }
}

