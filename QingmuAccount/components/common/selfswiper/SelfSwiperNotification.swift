//
//  SelfSwiperNotification.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/10.
//

import Foundation
class SelfSwiperNotification:ObservableObject {
    public static let notificationName = "selfSwiperNotification"
    @Published var handleId:String? = nil
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: SelfSwiperNotification.notificationName), object: nil)
    }
    /// 接受到通知后的方法回调
    @objc private func notificationAction(noti: Notification) {
        handleId = noti.object as? String
    }
    /// 析构函数.类似于OC的 dealloc
    deinit {
       /// 移除通知
       NotificationCenter.default.removeObserver(self)
    }
}
