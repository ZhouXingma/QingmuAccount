//
//  AssetAccountRecordOfCacheService.swift
//  QingmuAccount
//  资产变更明细缓存服务。明细量小、仅详情页使用，不做全局缓存，直接查库；
//  每次变更后强制刷新账户缓存以保证余额一致。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

class AssetAccountRecordOfCacheService {
    /// 某账户的变更明细（时间倒序）
    static func getRecords(accountId: String) throws -> [AssetAccountRecordModel] {
        return try AssetAccountRecordService.getRecords(accountId: accountId)
    }

    /// 某账户的变更明细分页查询（时间倒序）
    static func getRecords(accountId: String, limit: Int, offset: Int) throws -> [AssetAccountRecordModel] {
        return try AssetAccountRecordService.getRecords(accountId: accountId, limit: limit, offset: offset)
    }

    /// 指定月份所有账户的变更明细（时间倒序）
    static func getMonthlyRecords(year: Int, month: Int) throws -> [AssetAccountRecordModel] {
        return try AssetAccountRecordService.getRecords(year: year, month: month)
    }

    /// 某账户指定月份的变更明细（时间倒序）
    static func getMonthlyRecords(accountId: String, year: Int, month: Int) throws -> [AssetAccountRecordModel] {
        return try AssetAccountRecordService.getRecords(accountId: accountId, year: year, month: month)
    }

    /// 记一笔变更：新增明细 + 同步账户余额，返回新明细 id
    static func addRecord(accountId: String, changeType: Int, signedMoneyCents: Int64,
                          money: String, remark: String, currency: String = "CNY", cache: GlobalModel) throws -> String {
        let id = try AssetAccountRecordService.addRecord(
            accountId: accountId, changeType: changeType,
            signedMoneyCents: signedMoneyCents, money: money, remark: remark, currency: currency
        )
        _ = try AssetAccountOfCacheService.reloadAccounts(cache: cache)
        return id
    }

    /// 转移：本账户减少、目标账户增加，同步两个账户余额
    static func transferRecord(fromAccountId: String, toAccountId: String,
                               amountCents: Int64, money: String, remark: String, currency: String? = nil, cache: GlobalModel) throws {
        try AssetAccountRecordService.transferRecord(
            fromAccountId: fromAccountId, toAccountId: toAccountId,
            amountCents: amountCents, money: money, remark: remark, currency: currency
        )
        _ = try AssetAccountOfCacheService.reloadAccounts(cache: cache)
    }

    /// 修改一条变更的金额并同步账户余额（差异 = 新值 - 旧值）
    static func updateRecordAmount(recordId: String, newSignedMoneyCents: Int64, money: String, cache: GlobalModel) throws {
        try AssetAccountRecordService.updateRecordAmount(
            recordId: recordId, newSignedMoneyCents: newSignedMoneyCents, money: money
        )
        _ = try AssetAccountOfCacheService.reloadAccounts(cache: cache)
    }

    /// 删除一条变更：删除明细 + 回滚账户余额
    static func deleteRecord(recordId: String, cache: GlobalModel) throws {
        try AssetAccountRecordService.deleteRecord(recordId: recordId)
        _ = try AssetAccountOfCacheService.reloadAccounts(cache: cache)
    }
}
