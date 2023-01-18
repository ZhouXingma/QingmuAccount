//
//  AssertsDataService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/29.
//

import Foundation
class AssertsDataCacheService {
    public static func initAsserts(cache:GlobalModel) throws {
        let data = try getAsserts(cache: cache)
        if nil != data {
            cache.refreshAssertsData(data)
        }
    }

    public static func getAsserts(cache:GlobalModel) throws -> AssertsData? {
        var assertsData = cache.assertsData
        if (nil != assertsData) {
            return assertsData
        }
        assertsData = try AssertsDataService.readData()
        if nil == assertsData {
            do {
                assertsData = AssertsDataService.DEFAULT_ASSERTS
                try AssertsDataService.setData(assertsData: AssertsDataService.DEFAULT_ASSERTS)
                cache.refreshAssertsData(assertsData)
            } catch {
                
            }
        } else {
            cache.refreshAssertsData(assertsData)
        }
       
        return assertsData
    }

    
    public static func updateAsserts(_ assertsData: AssertsData, cache:GlobalModel) throws {
        try AssertsDataService.setData(assertsData: assertsData)
        cache.refreshAssertsData(assertsData)
    }
}


