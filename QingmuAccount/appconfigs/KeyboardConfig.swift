//
//  KeyboardConfig.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import Foundation
import SwiftUI

extension TextField {
    
    /// 添加关闭键盘工具栏
    /// - Returns: 返回
    func wzz_makeToolBar() -> some View {
        return self.toolbar(content: {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    toHideKeyboard()
                } label: {
                    Text("完成")
                }
            }
        })
    }
}

extension View {
    /// 关闭键盘事件
    func toHideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
