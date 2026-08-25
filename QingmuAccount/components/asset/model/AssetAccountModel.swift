//
//  AssetAccountModel.swift
//  QingmuAccount
//  资产账户 v2 体系：资产账户 + 资产变更明细模型。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

/// 币型（数据库存 ISO 代码，展示用中文名）
enum AssetCurrency: String, CaseIterable {
    case CNY = "CNY"
    case USD = "USD"
    case JPY = "JPY"
    case HKD = "HKD"
    case EUR = "EUR"
    case GBP = "GBP"
    case KRW = "KRW"
    case AUD = "AUD"
    case CAD = "CAD"
    case SGD = "SGD"

    var name: String {
        switch self {
        case .CNY: return "人民币"
        case .USD: return "美元"
        case .JPY: return "日元"
        case .HKD: return "港币"
        case .EUR: return "欧元"
        case .GBP: return "英镑"
        case .KRW: return "韩元"
        case .AUD: return "澳元"
        case .CAD: return "加元"
        case .SGD: return "新加坡元"
        }
    }

    /// 货币符号
    var symbol: String {
        switch self {
        case .CNY: return "¥"
        case .USD: return "$"
        case .JPY: return "¥"
        case .HKD: return "HK$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .KRW: return "₩"
        case .AUD: return "A$"
        case .CAD: return "C$"
        case .SGD: return "S$"
        }
    }

    /// 代码 → 中文名，未知代码回退为原代码
    static func name(of code: String) -> String {
        return AssetCurrency(rawValue: code)?.name ?? code
    }

    /// 代码 → 符号，未知代码回退为原代码
    static func symbol(of code: String) -> String {
        return AssetCurrency(rawValue: code)?.symbol ?? code
    }
}

/// 资产账户类型
enum AssetAccountType: Int, CaseIterable {
    case bank = 0        // 银行账户
    case creditCard = 1  // 信用卡
    case socialFund = 2  // 社保账户（公积金、医保等）
    case online = 3      // 网络平台（支付宝、微信等）
    case finance = 4     // 金融理财
    case borrowLoan = 5  // 借欠贷（借款、欠款、车贷、房贷等）

    var name: String {
        switch self {
        case .bank: return "银行账户"
        case .creditCard: return "信用卡"
        case .socialFund: return "社保账户"
        case .online: return "网络平台"
        case .finance: return "金融理财"
        case .borrowLoan: return "借欠贷"
        }
    }
}

/// 资产变更类型（类型本身即代表方向，仅调账可手动切换增减）
enum AssetRecordChangeType: Int, CaseIterable {
    case transferIn = 0   // 转入：本账户增加
    case transferOut = 1  // 转出：本账户减少
    case transfer = 2     // 转移：本账户减少，目标账户增加
    case adjust = 3       // 调账：可设置增加/减少

    var name: String {
        switch self {
        case .transferIn: return "转入"
        case .transferOut: return "转出"
        case .transfer: return "转移"
        case .adjust: return "调账"
        }
    }

    /// 本账户默认方向：true=增加，false=减少
    var defaultPositive: Bool {
        switch self {
        case .transferIn: return true
        case .transferOut, .transfer: return false
        case .adjust: return true
        }
    }

    /// 是否需要增/减切换（仅调账）
    var needDirectionPicker: Bool {
        return self == .adjust
    }
}

/// 资产账户
class AssetAccountModel: Identifiable, Hashable, Encodable, Decodable {
    static func == (lhs: AssetAccountModel, rhs: AssetAccountModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.type == rhs.type &&
            lhs.icon == rhs.icon && lhs.currency == rhs.currency && lhs.totalCents == rhs.totalCents &&
            lhs.description == rhs.description
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(icon)
        hasher.combine(currency)
        hasher.combine(totalCents)
        hasher.combine(description)
    }

    var id: UUID
    var name: String
    /// 0银行账户 1信用卡 2社保账户 3网络平台 4金融理财 5借欠贷
    var type: Int
    /// 图片资源名（Assets.xcassets/AccountIcons）
    var icon: String
    /// 币型（ISO 代码）
    var currency: String
    /// 总金额（分）：>0 存款，<0 负债
    var totalCents: Int64
    /// 排序
    var sort: Int
    /// 备注（还款时间、还款方式等）
    var description: String
    var gmtCreated: Date
    var gmtModfied: Date

    init(id: UUID = UUID(), name: String, type: Int, icon: String, currency: String = "CNY",
         totalCents: Int64 = 0, sort: Int = 0, description: String = "",
         gmtCreated: Date = Date(), gmtModfied: Date = Date()) {
        self.id = id
        self.name = name
        self.type = type
        self.icon = icon
        self.currency = currency
        self.totalCents = totalCents
        self.sort = sort
        self.description = description
        self.gmtCreated = gmtCreated
        self.gmtModfied = gmtModfied
    }

    /// 展示用金额字符串（带正负号，保留两位小数）
    var totalMoney: String {
        let isNegative = totalCents < 0
        let absMoney = SQLiteManager.money(fromCents: abs(totalCents))
        return isNegative ? "-" + absMoney : absMoney
    }

    /// 币型列表（currency 以逗号分隔存储，如 "CNY,USD"）
    var currencyList: [String] {
        currency.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
    /// 主币型（列表第一个，空则默认 CNY）
    var primaryCurrency: String {
        currencyList.first ?? "CNY"
    }
    /// 币型展示文案（多个用 · 连接的中文名）
    var currencyDisplayName: String {
        let names = currencyList.map { AssetCurrency.name(of: $0) }
        return names.isEmpty ? "人民币" : names.joined(separator: " · ")
    }
}

/// 资产变更明细（记录每一次余额变更）
class AssetAccountRecordModel: Identifiable, Hashable, Encodable, Decodable {
    static func == (lhs: AssetAccountRecordModel, rhs: AssetAccountRecordModel) -> Bool {
        return lhs.id == rhs.id && lhs.accountId == rhs.accountId && lhs.changeType == rhs.changeType &&
            lhs.moneyCents == rhs.moneyCents && lhs.remark == rhs.remark && lhs.relatedAccountName == rhs.relatedAccountName && lhs.currency == rhs.currency
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(accountId)
        hasher.combine(changeType)
        hasher.combine(moneyCents)
        hasher.combine(remark)
        hasher.combine(relatedAccountName)
        hasher.combine(currency)
    }

    var id: UUID
    var accountId: String
    /// 变更类型：0转入 1转出 2转移 3调账
    var changeType: Int
    /// 金额原文（绝对值）
    var money: String
    /// 金额（分）带符号：正=余额增加，负=余额减少
    var moneyCents: Int64
    var remark: String
    /// 对方账户名称（转移明细用：转出至/转入自）
    var relatedAccountName: String
    /// 本笔变更所属币型（ISO 代码）
    var currency: String
    var gmtCreated: Date
    var gmtModfied: Date

    init(id: UUID = UUID(), accountId: String, changeType: Int, money: String, moneyCents: Int64,
         remark: String = "", relatedAccountName: String = "", currency: String = "CNY",
         gmtCreated: Date = Date(), gmtModfied: Date = Date()) {
        self.id = id
        self.accountId = accountId
        self.changeType = changeType
        self.money = money
        self.moneyCents = moneyCents
        self.remark = remark
        self.relatedAccountName = relatedAccountName
        self.currency = currency
        self.gmtCreated = gmtCreated
        self.gmtModfied = gmtModfied
    }

    /// 展示用金额字符串（带 +/- 号）
    var moneyText: String {
        let absMoney = SQLiteManager.money(fromCents: abs(moneyCents))
        return moneyCents >= 0 ? "+" + absMoney : "-" + absMoney
    }
}
