//
//  AcountKeyComputerHandle.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/5.
//

import Foundation

class AcountKeyComputerHandle {
    public static func handleAccountKeyTab(keyId:Int, computerDesc:inout String, value: inout String) {
        // 12 是删除，15是完成
        if (keyId != 12 && keyId != 15) {
            let addS = transAdds(keyId)
            computerDesc = keyHandle(computerDesc, addS)
        } else if keyId == 12 {
            computerDesc = keyHandleDelete(computerDesc)
        }
        value = DecimalUtils.trans2StringOfCurrency(computerNumber(computerDesc))
    }
    
    
    static func transAdds(_ keyId:Int) -> String {
        var v = ""
        switch(keyId) {
        case 1: v = "1"
        case 2: v = "2"
        case 3: v = "3"
        case 4: v = "4"
        case 5: v = "5"
        case 6: v = "6"
        case 7: v = "7"
        case 8: v = "8"
        case 9: v = "9"
        case 10: v = "."
        case 11: v = "0"
        case 13: v = "+"
        case 14: v = "-"
        default: v = ""
        }
        return v
    }
    
    static func keyHandle(_ s:String, _ addS:String) -> String {
        if (addS == "") {
            return s
        }
        let addSisPlusOrSubTake = isPlusOrSubTake(addS)
        // 当前值不存在的情况
        if (s == "") {
            if (addSisPlusOrSubTake) {
                return ""
            }
            if (addS == ".") {
                return "0."
            }
        }
        let a = s.components(separatedBy: ["+","-"])
        // 最后一个值不存在的情况，意味着最后一个字符是+或者-
        let latestValue = a[a.count-1]
        if (latestValue == "") {
            if (addSisPlusOrSubTake) {
                return s
            }
            if (addS == ".") {
                return s+"0."
            }
        }
        // 最后一个值的存在的情况
        let pointIndex = inclusePointIndex(latestValue)
        // 情况1：存在小数点
        if pointIndex != -1 {
            // 12.
            if latestValue.count - pointIndex == 1 {
                if (addSisPlusOrSubTake || addS == ".") {
                    return s
                }
            }
            // 12.0
            if latestValue.count - pointIndex > 1 {
                if (addS == ".") {
                    return s
                }
            }
            // 12.00
            if latestValue.count - pointIndex >= 3 {
                if (!addSisPlusOrSubTake) {
                    return s
                }
            }
        }
        // 情况2: 不存在小数点
        if (latestValue == "0") {
            if (addS != "." && !addSisPlusOrSubTake) {
                return s
            }
        }
        return s+addS;
    }
    
    private static func keyHandleDelete(_ s:String) -> String {
        if (s == "") {
            return s
        }
        if (s.count <= 1) {
            return ""
        }
        return String(s[s.startIndex...s.index(s.endIndex,offsetBy: -2)])
    }

    /**
     计算表达式
     */
    private static func computerNumber(_ s:String) -> Decimal {
        var p:Decimal = 0
        if (s == "") {
            return p
        }
        let firstTag = s.prefix(1).description
        var tempS = s
        if (firstTag != "+" && firstTag != "-") {
            tempS = "+"+s
        }
        let a = s.components(separatedBy: ["+","-"])
        for item in a {
            if (item == "") {
                continue
            }
            // 获取操作符
            var opTag = "+"
            if (tempS != "") {
                opTag = tempS.prefix(1).description
                // 更新新数组
                tempS = String(tempS[tempS.index(tempS.startIndex, offsetBy: item.count+1)...])
            }
            let k = (item as NSString).doubleValue
            if (opTag == "+") {
                p = p + Decimal(k)
            } else  {
                p = p - Decimal(k)
            }
        }
       return p
    }
    
    static func isPlusOrSubTake(_ addS:String) -> Bool {
        return addS == "+" || addS == "-"
    }

    static func inclusePointIndex(_ value:String) -> Int {
        let p = value.firstIndex(of: ".")
        if let a = p {
            return a.utf16Offset(in: value)
        }
        return -1
    }

}
