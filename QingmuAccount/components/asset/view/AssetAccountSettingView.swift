//
//  AssetAccountSettingView.swift
//  QingmuAccount
//  资产账户设置：顶部标题栏 + 分页（账户列表 / 按币型统计）。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI

struct AssetAccountSettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    @State private var accounts: [AssetAccountModel] = []
    @State private var balanceMap: [String: [(currency: String, totalCents: Int64)]] = [:]
    @State private var selection = 0
    @State private var showAdd = false
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            TabView(selection: $selection) {
                accountListPage.tag(0)
                statisticsPage.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        .selfAlter(showState: $showAlter, config: alterConfig)
        .onAppear {
            reload()
        }
        .sheet(isPresented: $showAdd) {
            AssetAccountEditView(mode: .add, account: nil, onSave: { reload() })
                .environmentObject(globalModel)
        }
    }

    // MARK: - 标题栏（返回 + 居中分段菜单 + 添加，一行）

    private var titleBar: some View {
        HStack(spacing: 0) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
            }
            Spacer()
            HStack(spacing: 28) {
                segmentItem(title: "账户", index: 0)
                segmentItem(title: "统计", index: 1)
            }
            Spacer()
            Button {
                keyFeedback()
                showAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func segmentItem(title: String, index: Int) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(selection == index ? Color("DefaultButtonBackgroud") : Color("FontColor").opacity(0.5))
                .animation(.easeInOut(duration: 0.15), value: selection)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("DefaultButtonBackgroud"))
                .frame(width: selection == index ? 22 : 0, height: 3)
                .animation(.easeInOut(duration: 0.15), value: selection)
        }
        .onTapGesture {
            keyFeedback(0)
            selection = index
        }
    }

    // MARK: - 账户列表页

    private var accountListPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(groupedKeys(), id: \.self) { type in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color("DefaultButtonBackgroud"))
                                .frame(width: 5, height: 5)
                            Text(AssetAccountType(rawValue: type)?.name ?? "其他")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 6)
                        ForEach(accounts.filter { $0.type == type }, id: \.id) { account in
                            accountRow(account)
                        }
                    }
                }
                if accounts.isEmpty {
                    emptyView
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
    }

    private func accountRow(_ account: AssetAccountModel) -> some View {
        NavigationLink {
            AssetAccountDetailView(accountId: account.id.uuidString, onAccountChanged: { reload() })
                .environmentObject(globalModel)
        } label: {
            HStack(spacing: 12) {
                AssetAccountIconView(icon: account.icon, iconSize: 30, textCornerRadius: 12)
                    .padding(9)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color("MainShadowColor").opacity(0.12), radius: 4, x: 0, y: 2)
                VStack(alignment: .leading, spacing: 3) {
                    Text(account.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                        .lineLimit(1)
                    Text("\(AssetAccountType(rawValue: account.type)?.name ?? "") · \(account.currencyDisplayName)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                if let balances = balanceMap[account.id.uuidString], !balances.isEmpty {
                    AccountBalanceCarouselHorizontal(balances: balances)
                } else {
                    RollingAmountText(cents: account.totalCents, font: .system(size: 15, weight: .bold),
                                      color: account.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                }
            }
            .padding(.horizontal, 12)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 60)
            .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 5, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("还没有资产账户，点击右上角添加")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - 统计页（按币型）

    private var statisticsPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                    Text("按币型统计")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                }
                if currencySummaries.isEmpty {
                    Text("暂无资产账户")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 10)
                } else {
                    ForEach(currencySummaries) { summary in
                        currencySummaryCard(summary)
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
    }

    private struct CurrencySummary: Identifiable {
        let code: String
        var assetsCents: Int64 = 0
        var liabilitiesCents: Int64 = 0
        var id: String { code }
    }

    private var currencySummaries: [CurrencySummary] {
        var map: [String: CurrencySummary] = [:]
        for (_, list) in balanceMap {
            for (c, cents) in list {
                var s = map[c] ?? CurrencySummary(code: c)
                if cents >= 0 {
                    s.assetsCents += cents
                } else {
                    s.liabilitiesCents += abs(cents)
                }
                map[c] = s
            }
        }
        return map.values.sorted { $0.code < $1.code }
    }

    private func currencySummaryCard(_ summary: CurrencySummary) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(AssetCurrency.name(of: summary.code))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Text(summary.code)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            HStack(spacing: 10) {
                summaryMiniItem(cents: summary.assetsCents,
                                colors: [Color("DefaultButtonBackgroud"), Color("DefaultButtonBackgroud").opacity(0.75)])
                summaryMiniItem(cents: summary.liabilitiesCents,
                                colors: [Color("RedColor"), Color("RedColor").opacity(0.75)])
            }
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func summaryMiniItem(cents: Int64, colors: [Color]) -> some View {
        RollingAmountText(cents: cents, font: .system(size: 16, weight: .bold), color: .white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 60)
            .background(
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .shadow(color: colors[0].opacity(0.25), radius: 5, x: 0, y: 3)
    }

    // MARK: - 工具

    private func groupedKeys() -> [Int] {
        let types = Set(accounts.map { $0.type })
        return types.sorted()
    }

    private func money(_ cents: Int64) -> String {
        return SQLiteManager.money(fromCents: cents)
    }

    private func reload() {
        do {
            let loaded = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            let balances = (try? AssetAccountBalanceService.getAllBalances()) ?? [:]
            withAnimation(.easeInOut(duration: 0.3)) {
                accounts = loaded
                balanceMap = balances
            }
        } catch {
            alterConfig.desc = "加载资产账户失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }
}
