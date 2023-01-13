//
//  StingUtils.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

class StringUtils {
    /**
     去除前尾空格
     */
    static func trim(_ str:String) -> String {
        str.trimmingCharacters(in: .whitespaces)
    }
    /**
     去除前尾空格后的字符串长度
     */
    static func trimCount(_ str:String) -> Int {
        return trim(str).count
    }

}
