//
//  PieData.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/24.
//

import Foundation

class PieData:ObservableObject {
    @Published var itemName : String
    @Published var itemValue : Double
    
    init(itemName: String, itemValue: Double) {
        self.itemName = itemName
        self.itemValue = itemValue
    }
}
