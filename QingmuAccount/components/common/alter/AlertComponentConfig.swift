//
//  AlertComponentConfig.swift
//  QingmuAccount
//
//  自定义提醒的配置样式
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

/**
  配置对象
 */
class AlertComponentConfig {
    var title:String
    var desc:String
    var showCancelButton: Bool
    var cancalButtonName: String
    var showSureButton: Bool
    var sureButtonName: String
    var topBarColorStyle: AlertComponentTopBarColorStyle
    var cancelFun: () -> Void
    var sureFun: () -> Void
    
    static let DEFAULT = AlertComponentConfig()
    
    init(title: String = "提示", desc: String="确定进行该操作吗", showCancelButton: Bool = true, cancalButtonName: String="取消",  showSureButton: Bool=true, sureButtonName: String="确定", topBarColorStyle: AlertComponentTopBarColorStyle = .DEFAULT, cancelFun:@escaping () -> Void = {}, sureFun:@escaping () -> Void = {}) {
        self.title = title
        self.desc = desc
        self.showCancelButton = showCancelButton
        self.cancalButtonName = cancalButtonName
        self.showSureButton = showSureButton
        self.sureButtonName = sureButtonName
        self.topBarColorStyle = topBarColorStyle
        self.cancelFun = cancelFun
        self.sureFun = sureFun
    }
}

/**
  顶部条形的样式
 */
enum AlertComponentTopBarColorStyle {
    // 默认
    case DEFAULT
    // 红色，用于警告
    case RED
}
