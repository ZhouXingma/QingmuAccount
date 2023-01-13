//
//  AcountKeyBoardNotice.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/5.
//

import SwiftUI
import UIKit

class AcountKeyBoardNotifaction : ObservableObject {
    @Published var offY:Double = 0
    init() {
        // 键盘显示
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardHeightShow), name: NSNotification.Name(rawValue: UIResponder.keyboardDidShowNotification.rawValue), object: nil)
        // 键盘隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardHeightHidde), name: NSNotification.Name(rawValue: UIResponder.keyboardDidHideNotification.rawValue), object: nil)
    }
    /**
     键盘显示
     */
    @objc func keyBoardHeightShow(_ notification: Notification) {
       let keyboardinfo:CGRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardheight  = keyboardinfo.size.height
        self.offY = -(keyboardheight-245)
    }
    /**
     键盘隐藏
     */
    @objc func keyBoardHeightHidde(_ notification: Notification) {
        // 获取键盘信息
        self.offY = 0
    }
}
