//
//  GlobalConfig.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/24.
//

import SwiftUI
import Combine

class GlobalModel: ObservableObject {
    @Published var accountBook:AccountBookModel?
    @Published var accountBooks:[String:AccountBookModel]?
    @Published var accountBookSetings:[String:AccountBookSetingModel] = [:]
    @Published var accountBookYearData:AccountBookYearData?
    @Published var assertsData:AssertsData?
    @Published var darkModeSettings: Int = UserDefaults.standard.integer(forKey: "darkMode") {
            didSet {
                UserDefaults.standard.set(self.darkModeSettings, forKey: "darkMode")
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                switch self.darkModeSettings {
                case 0:
                 window?.overrideUserInterfaceStyle = .unspecified
                case 1:
                 window?.overrideUserInterfaceStyle = .light
                case 2:
                 window?.overrideUserInterfaceStyle = .dark
                default:
                 window?.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    
    
    
    public func refreshAccountBooks(_ accountBooksParam:[String:AccountBookModel]?) {
        if let a = accountBooksParam {
            self.accountBooks = a
        } else {
            self.accountBooks = try!AccountBookHandleService.readAccountBooks()
        }
    }
    
    public func refreshAccountBook(_ accountBookParam:AccountBookModel?) {
        self.accountBook = accountBookParam
        self.accountBookYearData = nil
    }
    
    public func refreshAccountBookSeting(accountBookId:String, setting:AccountBookSetingModel?) {
        if (nil != setting && StringUtils.trimCount(accountBookId) > 0) {
            self.accountBookSetings[accountBookId] = setting!
        }
    }
    
    public func refreshAccountBookYearData(_ yearData:AccountBookYearData?) {
        self.accountBookYearData = yearData
    }
    
    public func refreshAssertsData(_ assertsData:AssertsData?) {
        self.assertsData = assertsData
    }
    
}

