//
//  AssetAccountBalanceService.swift
//  QingmuAccount
//  资产账户分币种余额查询（asset_account_balance 表）。
//  Created by 周荥马 on 2026/8/14.
//

import Foundation

class AssetAccountBalanceService {
    /// 某账户各币种余额
    static func getBalances(accountId: String) throws -> [(currency: String, totalCents: Int64)] {
        let rows = try SQLiteManager.shared.query(
            "SELECT currency, totalCents FROM asset_account_balance WHERE accountId=? ORDER BY currency",
            [accountId])
        return rows.compactMap { row in
            guard let c = row["currency"] as? String, let cents = row["totalCents"] as? Int64 else { return nil }
            return (c, cents)
        }
    }

    /// 全部账户各币种余额（accountId -> [(currency, cents)]）
    static func getAllBalances() throws -> [String: [(currency: String, totalCents: Int64)]] {
        let rows = try SQLiteManager.shared.query("SELECT accountId, currency, totalCents FROM asset_account_balance")
        var result: [String: [(currency: String, totalCents: Int64)]] = [:]
        for row in rows {
            guard let accountId = row["accountId"] as? String,
                  let c = row["currency"] as? String,
                  let cents = row["totalCents"] as? Int64 else { continue }
            var list = result[accountId] ?? []
            list.append((c, cents))
            result[accountId] = list
        }
        return result
    }
}
