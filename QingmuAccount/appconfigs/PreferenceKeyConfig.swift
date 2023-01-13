//
//  ScrollPreferenceKey.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/30.
//
import SwiftUI
struct MainTabViewScrollPreferenceKey : PreferenceKey {
    static var defaultValue:[Int:Double] = [:]
    static func reduce(value: inout [Int:Double], nextValue: () ->[Int:Double] ) {
        let temp = nextValue()
        for key in temp.keys {
            value[key] = temp[key]
        }
    }
}


struct IconTypeScrollPreferenceKey : PreferenceKey {
    static var defaultValue:String = ""
    static func reduce(value: inout String, nextValue: () -> String ) {
        let temp = nextValue()
        if StringUtils.trimCount(temp)>0 {
            value = temp
        }
    }
}


struct CalendarPreferenceKey : PreferenceKey {
    static var defaultValue:CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
