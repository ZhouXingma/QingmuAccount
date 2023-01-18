//
//  AccountBookSetingOfCacheService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI

class AccountBookSetingOfCacheService {
    
    public static func initSeting(_ accountBookId:String, cache:GlobalModel) throws {
        let data = try getSeting(accountBookId, cache: cache)
        if nil != data {
            cache.refreshAccountBookSeting(accountBookId: accountBookId, setting: data)
        }
    }
    
    public static func getSeting(_ accountBookId:String, cache:GlobalModel) throws -> AccountBookSetingModel? {
        var seting = cache.accountBookSetings[accountBookId]
        if (nil != seting) {
            return seting
        }
        seting = try AccountBookSetingService.readAccountBookSetting(accountBookId)
        if nil == seting {
            do {
                seting = AccountBookSetingService.DEFAULT_SETING
                try AccountBookSetingService.setAccountBookSetting(accountBookId, AccountBookSetingService.DEFAULT_SETING)
                cache.refreshAccountBookSeting(accountBookId: accountBookId, setting: seting)
            } catch {
                
            }
        } else {
            cache.refreshAccountBookSeting(accountBookId: accountBookId, setting: seting)
        }
        return seting
    }
    
    public static func updateSetting(_ accountBookId:String, _ setting: AccountBookSetingModel, cache:GlobalModel) throws {
        try AccountBookSetingService.setAccountBookSetting(accountBookId, setting)
        cache.refreshAccountBookSeting(accountBookId: accountBookId, setting: setting)
    }
}
