//
//  AssetAccountOfCacheService.swift
//  QingmuAccount
//  资产账户缓存服务：视图实际调用层，操作后同步刷新 GlobalModel.assetAccounts。
//  Created by 周荥马 on 2026/8/12.
//

import Foundation

class AssetAccountOfCacheService {
    /// 获取全部账户，优先走缓存
    static func getAccounts(cache: GlobalModel) throws -> [AssetAccountModel] {
        if let accounts = cache.assetAccounts {
            return accounts
        }
        let accounts = try AssetAccountService.getAll()
        cache.refreshAssetAccounts(accounts)
        return accounts
    }

    /// 强制重读并刷新缓存（增删改、记变更后调用，保证余额一致）
    static func reloadAccounts(cache: GlobalModel) throws -> [AssetAccountModel] {
        let accounts = try AssetAccountService.getAll()
        cache.refreshAssetAccounts(accounts)
        return accounts
    }

    /// 新增账户（可带初始余额）
    static func addAccount(_ account: AssetAccountModel, initialCents: Int64, cache: GlobalModel) throws {
        try AssetAccountService.add(account, initialCents: initialCents)
        _ = try reloadAccounts(cache: cache)
    }

    /// 更新账户基本信息
    static func updateAccount(_ account: AssetAccountModel, cache: GlobalModel) throws {
        try AssetAccountService.update(account)
        _ = try reloadAccounts(cache: cache)
    }

    /// 删除账户（级联删除明细）
    static func deleteAccount(id: String, cache: GlobalModel) throws {
        try AssetAccountService.delete(id: id)
        _ = try reloadAccounts(cache: cache)
    }
}
