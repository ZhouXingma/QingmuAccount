//
//  AssetAccountSelectComponent.swift
//  QingmuAccount
//  资产账户选择（类似账本选择）：列出账户，点击进入账户详情。
//  Created by 周荥马 on 2026/8/13.
//

import SwiftUI

struct AssetAccountSelectComponent: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    @State private var accounts: [AssetAccountModel] = []
    @State private var balanceMap: [String: [(currency: String, totalCents: Int64)]] = [:]
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏（居中标题 + 左右对称）
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                }
                Spacer()
                Text("选择账户")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 6)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(accounts, id: \.id) { account in
                        NavigationLink {
                            AssetAccountDetailView(accountId: account.id.uuidString, onAccountChanged: { reload() })
                                .environmentObject(globalModel)
                        } label: {
                            accountRow(account)
                        }
                        .buttonStyle(.plain)
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
    }

    private func accountRow(_ account: AssetAccountModel) -> some View {
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
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 62)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 5, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("还没有资产账户，请先到「资产账户」中添加")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func reload() {
        do {
            accounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            balanceMap = (try? AssetAccountBalanceService.getAllBalances()) ?? [:]
        } catch {
            alterConfig.desc = "加载账户失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }
}
