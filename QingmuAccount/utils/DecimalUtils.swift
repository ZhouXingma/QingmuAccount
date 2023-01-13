//
//  DecimalUtils.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/1.
//


import SwiftUI
class DecimalUtils {
    private static var specifier:String="%.2f"
    private static var specifier1:String="%.1f"
    public static func trans2StringOfCurrency(_ value:Decimal) -> String {
        let doubleValue = Double(truncating: value as NSNumber)
        return String(format: specifier, doubleValue)
    }
    
    public static func trans2StringOfPercent(_ value:Decimal) -> String {
        let doubleValue = Double(truncating: value as NSNumber)
        return String(format: specifier1, doubleValue)
    }
}


extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
