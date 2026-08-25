//
//  AccountBookSetingModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/6.
//

import SwiftUI

class AccountBookSetingModel:Encodable,Decodable {
    // yyyyMM : [currency : 预算]
    var budget:[String:[String:Decimal]]
    // 收入图标设置
    var inRecordIconSeting:[AccountBookSetingOfIconModel] = []
    // 输出图标设置
    var outRecordIconSeting:[AccountBookSetingOfIconModel] = []

    init(budget:[String:[String:Decimal]] = [:],
         inRecordIconSeting: [AccountBookSetingOfIconModel] = defaultAccountBookInRecordIcon,
         outRecordIconSeting: [AccountBookSetingOfIconModel] = defaultAccountBookOutRecordIcon) {
        self.budget = budget
        self.inRecordIconSeting = inRecordIconSeting
        self.outRecordIconSeting = outRecordIconSeting
    }

    enum CodingKeys: String, CodingKey {
        case budget
        case inRecordIconSeting
        case outRecordIconSeting
    }

    // 兼容旧版单币种 JSON（budget: yyyyMM : 金额）与新版多币种 JSON（yyyyMM : [currency : 金额]）
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let nested = try? container.decode([String: [String: Decimal]].self, forKey: .budget) {
            budget = nested
        } else if let legacy = try? container.decode([String: Decimal].self, forKey: .budget) {
            budget = legacy.mapValues { ["CNY": $0] }
        } else {
            budget = [:]
        }
        inRecordIconSeting = (try? container.decode([AccountBookSetingOfIconModel].self, forKey: .inRecordIconSeting)) ?? []
        outRecordIconSeting = (try? container.decode([AccountBookSetingOfIconModel].self, forKey: .outRecordIconSeting)) ?? []
    }
}
