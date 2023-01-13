//
//  AccountBookSetingModel.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/6.
//

import SwiftUI

class AccountBookSetingModel:Encodable,Decodable {
    // yyyyMM:预算
    var budget:[String:Decimal]
    // 收入图标设置
    var inRecordIconSeting:[AccountBookSetingOfIconModel] = []
    // 输出图标设置
    var outRecordIconSeting:[AccountBookSetingOfIconModel] = []
    
    init(budget:[String:Decimal] = [:],
         inRecordIconSeting: [AccountBookSetingOfIconModel] = defaultAccountBookInRecordIcon,
         outRecordIconSeting: [AccountBookSetingOfIconModel] = defaultAccountBookOutRecordIcon) {
        self.budget = budget
        self.inRecordIconSeting = inRecordIconSeting
        self.outRecordIconSeting = outRecordIconSeting
    }
    
}
