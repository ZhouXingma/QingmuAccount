//
//  AssetSummaryComponent.swift
//  QingmuAccount
//  资产汇总：按币种汇总各账户当前的总资产与总负债（与月份无关），点击币种展开查看各账户明细。
//  Created by 周荥马 on 2026/8/16.
//

import SwiftUI

struct AssetSummaryComponent: View {
    let accounts: [AssetAccountModel]
    let balanceMap: [String: [(currency: String, totalCents: Int64)]]
    var onAccountChanged: () -> Void = {}
    /// 已展开的币种
    @State private var expandedCurrencies: Set<String> = []

    var body: some View {
        VStack(spacing: 10) {
            if summaries.isEmpty {
                emptyView
            } else {
                ForEach(summaries) { summary in
                    currencyCard(summary)
                }
            }
        }
    }

    // MARK: - 数据计算

    /// 每币种汇总（含各账户明细）
    private var summaries: [AssetSummaryCurrency] {
        let accountMap = Dictionary(uniqueKeysWithValues: accounts.map { ($0.id.uuidString, $0) })
        var map: [String: AssetSummaryCurrency] = [:]
        for (accountId, balances) in balanceMap {
            guard let account = accountMap[accountId] else { continue }
            for (code, cents) in balances {
                var summary = map[code] ?? AssetSummaryCurrency(code: code)
                if cents >= 0 {
                    summary.assetCents += cents
                } else {
                    summary.liabilityCents += -cents
                }
                summary.accountItems.append(AssetSummaryAccount(account: account, balanceCents: cents))
                map[code] = summary
            }
        }
        // 按净资产（资产-负债）从大到小排序；跳过资产、负债均为 0 的币种
        return map.values
            .filter { $0.assetCents != 0 || $0.liabilityCents != 0 }
            .sorted { a, b in
                let na = a.assetCents - a.liabilityCents
                let nb = b.assetCents - b.liabilityCents
                if na != nb { return na > nb }
                return a.code < b.code
            }
            .map { summary in
                // 币种内账户按余额从大到小排序（余额相同再按名称）
                var s = summary
                s.accountItems.sort { a, b in
                    if a.balanceCents != b.balanceCents { return a.balanceCents > b.balanceCents }
                    return a.account.name < b.account.name
                }
                return s
            }
    }

    // MARK: - 视图

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "banknote")
                .font(.system(size: 30))
                .foregroundColor(.secondary.opacity(0.4))
            Text("暂无资产数据")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    /// 单个币种卡片
    private func currencyCard(_ summary: AssetSummaryCurrency) -> some View {
        let expanded = expandedCurrencies.contains(summary.code)
        return VStack(spacing: 0) {
            // 头部（点击展开/收起）
            HStack(spacing: 12) {
                // 币种徽标
                Text(AssetCurrency.symbol(of: summary.code))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .frame(width: 42, height: 42)
                    .background(Color("DefaultButtonBackgroud").opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Text(AssetCurrency.name(of: summary.code))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("FontColor"))
                            .lineLimit(1)
                        Text(summary.code)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 12) {
                        Text("总资产 \(money(summary.assetCents))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("DefaultButtonBackgroud"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("总负债 \(money(summary.liabilityCents))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("RedColor"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(expanded ? 180 : 0))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    if expanded {
                        expandedCurrencies.remove(summary.code)
                    } else {
                        expandedCurrencies.insert(summary.code)
                    }
                }
            }

            if expanded {
                Divider().padding(.leading, 14)
                accountList(summary)
            }
        }
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 6, x: 0, y: 3)
    }

    /// 币种下的账户明细列表（点击账户进入详情）
    private func accountList(_ summary: AssetSummaryCurrency) -> some View {
        VStack(spacing: 0) {
            ForEach(summary.accountItems) { item in
                NavigationLink {
                    AssetAccountDetailView(accountId: item.account.id.uuidString, onAccountChanged: onAccountChanged)
                } label: {
                    accountRow(item)
                }
                .buttonStyle(.plain)
                if item.id != summary.accountItems.last?.id {
                    Divider().padding(.leading, 62)
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// 账户明细行：当前币种的总资产或总负债（按余额正负着色）
    private func accountRow(_ item: AssetSummaryAccount) -> some View {
        HStack(spacing: 12) {
            AssetAccountIconView(icon: item.account.icon, iconSize: 22, textCornerRadius: 9)
                .padding(6)
                .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color("MainShadowColor").opacity(0.08), lineWidth: 1))
            Text(item.account.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color("FontColor"))
                .lineLimit(1)
            Spacer()
            Text(item.balanceCents >= 0 ? "资产 \(money(item.assetCents))" : "负债 \(money(item.liabilityCents))")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(item.balanceCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }

    private func money(_ cents: Int64) -> String {
        return SQLiteManager.money(fromCents: cents)
    }
}

/// 每币种汇总
private struct AssetSummaryCurrency: Identifiable {
    let code: String
    var assetCents: Int64 = 0
    var liabilityCents: Int64 = 0
    var accountItems: [AssetSummaryAccount] = []
    var id: String { code }
}

/// 币种下某账户的资产/负债
private struct AssetSummaryAccount: Identifiable {
    let account: AssetAccountModel
    let balanceCents: Int64
    var id: String { account.id.uuidString }
    var assetCents: Int64 { max(balanceCents, 0) }
    var liabilityCents: Int64 { max(-balanceCents, 0) }
}
