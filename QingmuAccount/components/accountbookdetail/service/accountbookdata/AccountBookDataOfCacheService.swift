//
//  AccountBookDataService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI

class AccountBookDataOfCacheService {
    /**
     添加数据
     */
    public static func addData(_ accountBookId:String, data:AccountBookData, cache:GlobalModel, updateCache:Bool = true, updaeFile:Bool = true, updateTotal:Bool = true) throws {
        let dataStr = data.dateStr
        if (StringUtils.trimCount(dataStr) != 8) {
            throw AccountBookDataError.TAKEHANLE
        }
        let yearStr = String(dataStr[dataStr.startIndex...dataStr.index(dataStr.startIndex, offsetBy: 3)])
        let year = (yearStr as NSString).integerValue
        // 获取数据
        var yearData = try getData(accountBookId, year: year, cache: cache)
        if (nil == yearData) {
            yearData = AccountBookYearData(year: year)
        }
        let ym = String(dataStr[dataStr.startIndex...dataStr.index(dataStr.startIndex, offsetBy: 5)])
        var ymDataArray:[AccountBookData]? = yearData!.data[ym]
        if (nil == ymDataArray) {
            ymDataArray = []
        }
        ymDataArray!.append(data)
        yearData!.data[ym] = ymDataArray
        if (updateTotal) {
            updateYearDataTotal(yearData!)
        }
        if (updaeFile) {
            try AccountBookDataService.setData(accountBookId, accountBookYearData: yearData!)
        }
        if (updateCache) {
            cache.refreshAccountBookYearData(yearData)
        }
    }
    /**
     更新数据
     */
    public static func updateData(_ accountBookId:String, oldData:AccountBookData, newData:AccountBookData, cache:GlobalModel) throws {
        // 处理逻辑，删除旧的，添加新的
        try deleteData(accountBookId, data: oldData, cache: cache,updateCache: true, updaeFile: false, updateTotal: false)
        try addData(accountBookId, data: newData, cache: cache, updateCache: true, updaeFile: true, updateTotal: true)
    }
    /**
     删除数据
     */
    public static func deleteData(_ accountBookId:String, data:AccountBookData, cache:GlobalModel, updateCache:Bool = true, updaeFile:Bool = true,updateTotal:Bool = true) throws {
        let dataStr = data.dateStr
        if (StringUtils.trimCount(dataStr) != 8) {
            throw AccountBookDataError.TAKEHANLE
        }
        let yearStr = String(dataStr[dataStr.startIndex...dataStr.index(dataStr.startIndex, offsetBy: 3)])
        let year = (yearStr as NSString).integerValue
        // 获取数据
        let yearData = try getData(accountBookId, year: year, cache: cache)
        if (nil == yearData) {
            return
        }
        let ym = String(dataStr[dataStr.startIndex...dataStr.index(dataStr.startIndex, offsetBy: 5)])
        var ymDataArray:[AccountBookData]? = yearData!.data[ym]
        if (nil == ymDataArray) {
            return
        }
        var removeIndex:Int? = nil
        for (index,dataItem) in ymDataArray!.enumerated() {
            if dataItem.id.description == data.id.description {
                removeIndex = index
                break
            }
        }
        if (nil != removeIndex) {
            ymDataArray!.remove(at: removeIndex!)
            yearData!.data[ym] = ymDataArray
            if (updateTotal) {
                updateYearDataTotal(yearData!)
            }
            if (updaeFile) {
                try AccountBookDataService.setData(accountBookId, accountBookYearData: yearData!)
            }
            if (updateCache) {
                cache.refreshAccountBookYearData(yearData)
            }
        }
        
    }
    
    public static func getData(_ accountBookId:String, year:Int, cache:GlobalModel) throws -> AccountBookYearData? {
        if let yearData = cache.accountBookYearData {
            if (yearData.year == year) {
                return yearData
            }
        }
        let yearDataDb = try AccountBookDataService.readData(accountBookId, year: year)
        cache.refreshAccountBookYearData(yearDataDb)
        return yearDataDb
    }
    
    // 更新总数据
    private static func updateYearDataTotal(_ yearData:AccountBookYearData) {
        for (ym,ymData) in yearData.data {
            var totalIn = Decimal(0.00);
            var totalEx = Decimal(0.00)
            if ymData.count > 0 {
                for ymDataItem in ymData {
                    if ymDataItem.type == 0 {
                        totalEx = totalEx + (Decimal(string:ymDataItem.money) ?? Decimal(0.0))
                    } else {
                        totalIn = totalIn + (Decimal(string:ymDataItem.money) ?? Decimal(0.0))
                    }
                }
            }
            yearData.total[ym] = IncomeExpensesTotal(income: totalIn, expenses: totalEx)
        }
    }
}
