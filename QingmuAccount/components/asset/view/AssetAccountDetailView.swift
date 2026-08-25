//
//  AssetAccountDetailView.swift
//  QingmuAccount
//  资产账户详情：余额头部 + 变更流水 + 记一笔 + 编辑/删除账户。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI

struct AssetAccountDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    let accountId: String
    var onAccountChanged: () -> Void = {}

    @State private var account: AssetAccountModel? = nil
    @State private var records: [AssetAccountRecordModel] = []
    @State private var balances: [(currency: String, totalCents: Int64)] = []
    @State private var hasMore = true
    @State private var isLoadingMore = false
    private let pageSize = 50
    @State private var showRecordEdit = false
    @State private var showAccountEdit = false
    @State private var showDeleteAccountAlter = false
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")
    @StateObject private var notifaction = SelfSwiperNotification()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DefaultTopBarComponent {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button {
                    keyFeedback()
                    showAccountEdit = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                }
            }.padding(.trailing, 20)

            if let account = account {
                accountHeader(account)
                    .padding(.horizontal, 15)
                    .padding(.top, 14)

                // 流水
                HStack {
                    Text("流水").font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("共 \(records.count) 笔").font(.system(size: 12)).foregroundColor(.secondary)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 8)

                if records.isEmpty {
                    emptyRecordView
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(groupedRecords, id: \.key) { group in
                                monthGroupHeader(group.key)
                                ForEach(group.records, id: \.id) { record in
                                    recordRow(record)
                                }
                            }
                            // 加载更多 / 到底提示
                            if hasMore {
                                ProgressView()
                                    .padding(.vertical, 14)
                                    .onAppear {
                                        loadMore()
                                    }
                            } else {
                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(Color("MainShadowColor").opacity(0.2))
                                        .frame(width: 28, height: 1)
                                    Text("没有更多了")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Rectangle()
                                        .fill(Color("MainShadowColor").opacity(0.2))
                                        .frame(width: 28, height: 1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                    }
                }

                Spacer()

                // 底部操作：删除账户（小）+ 记一笔（主按钮）一行
                HStack(spacing: 12) {
                    Button {
                        showDeleteAccountAlter = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 13, weight: .bold))
                            Text("删除账户")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color("RedColor"))
                        .frame(width: 104, height: 50)
                        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("RedColor").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                    Button {
                        keyFeedback()
                        showRecordEdit = true
                    } label: {
                        Text("记一笔")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color("MainShadowColor").opacity(0.25), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 24)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { reload() }
        .selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        .sheet(isPresented: $showRecordEdit) {
            AssetAccountRecordEditView(accountId: accountId, onSave: { reload() })
                .environmentObject(globalModel)
        }
        .sheet(isPresented: $showAccountEdit) {
            if let account = account {
                AssetAccountEditView(mode: .edit, account: account, onSave: { reload() })
                    .environmentObject(globalModel)
            }
        }
        .selfAlter(showState: $showDeleteAccountAlter, config: deleteAccountConfig)
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    private var deleteAccountConfig: AlertComponentConfig {
        var config = AlertComponentConfig(
            title: "删除提醒",
            desc: "确定删除该账户吗？其全部流水将一并删除，且无法恢复！",
            sureButtonName: "删除",
            topBarColorStyle: .RED,
            sureFun: { deleteAccount() }
        )
        return config
    }

    private func accountHeader(_ account: AssetAccountModel) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                AssetAccountIconView(icon: account.icon, iconSize: 38, textCornerRadius: 13)
                    .padding(9)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13))
                    .shadow(color: Color("MainShadowColor").opacity(0.12), radius: 4, x: 0, y: 2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                    Text("\(AssetAccountType(rawValue: account.type)?.name ?? "") · \(account.currencyDisplayName)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    if !account.description.isEmpty {
                        Text(account.description)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .padding(.top, 2)
                    }
                }
                Spacer()
            }
            if balances.isEmpty {
                HStack {
                    Text("当前余额").font(.system(size: 13)).foregroundColor(.secondary)
                    Spacer()
                    RollingAmountText(cents: account.totalCents, font: .system(size: 24, weight: .bold),
                                      color: account.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                }
            } else {
                VStack(alignment: .trailing, spacing: 6) {
                    ForEach(balances, id: \.currency) { item in
                        HStack(spacing: 10) {
                            Text(AssetCurrency.name(of: item.currency))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            RollingAmountText(cents: item.totalCents, font: .system(size: 16, weight: .bold),
                                              color: item.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func recordRow(_ record: AssetAccountRecordModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(AssetRecordChangeType(rawValue: record.changeType)?.name ?? "变更")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                if !record.relatedAccountName.isEmpty {
                    Text(relatedAccountText(record))
                        .font(.system(size: 12))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .lineLimit(1)
                }
                if !record.remark.isEmpty {
                    Text(record.remark)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text(DateUtils.transDate2String(record.gmtCreated, format: "yyyy-MM-dd HH:mm"))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(record.moneyText)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(record.moneyCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 62)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
        .selfSwiper(id: record.id.uuidString, maxOffsetX: 62, notification: notifaction) {
            Button {
                deleteRecord(record)
            } label: {
                Image(systemName: "trash.circle")
                    .frame(width: 60, height: 62)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Color("RedColor"), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    /// 转移明细的对方账户文案（按方向：转出至 / 转入自）
    private func relatedAccountText(_ record: AssetAccountRecordModel) -> String {
        if record.moneyCents >= 0 {
            return "转入自 \(record.relatedAccountName)"
        }
        return "转出至 \(record.relatedAccountName)"
    }

    private var emptyRecordView: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("暂无流水，点击下方「记一笔」添加")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func reload() {
        do {
            let accounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            account = accounts.first { $0.id.uuidString == accountId }
            balances = (try? AssetAccountBalanceService.getBalances(accountId: accountId)) ?? []
            let recs = try AssetAccountRecordOfCacheService.getRecords(accountId: accountId, limit: pageSize, offset: 0)
            withAnimation(.easeInOut(duration: 0.3)) {
                records = recs
                hasMore = recs.count == pageSize
                isLoadingMore = false
            }
            onAccountChanged()
        } catch {
            alterConfig.desc = "加载失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }

    /// 按年月分组的流水（时间倒序）
    private var groupedRecords: [(key: String, records: [AssetAccountRecordModel])] {
        let groups = Dictionary(grouping: records) { record -> String in
            let c = Calendar.current.dateComponents([.year, .month], from: record.gmtCreated)
            return "\(c.year ?? 0)年\(String(format: "%02d", c.month ?? 0))月"
        }
        return groups.keys.sorted(by: >).compactMap { key in
            guard let recs = groups[key] else { return nil }
            return (key, recs)
        }
    }

    private func monthGroupHeader(_ text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color("DefaultButtonBackgroud"))
                .frame(width: 5, height: 5)
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 6)
    }

    private func loadMore() {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        do {
            let newRecords = try AssetAccountRecordOfCacheService.getRecords(accountId: accountId, limit: pageSize, offset: records.count)
            withAnimation(.easeInOut(duration: 0.3)) {
                records.append(contentsOf: newRecords)
                hasMore = newRecords.count == pageSize
            }
        } catch {
            hasMore = false
        }
        isLoadingMore = false
    }

    private func deleteRecord(_ record: AssetAccountRecordModel) {
        do {
            try AssetAccountRecordOfCacheService.deleteRecord(recordId: record.id.uuidString, cache: globalModel)
            reload()
        } catch {
            alterConfig.desc = "删除失败"
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }

    private func deleteAccount() {
        do {
            try AssetAccountOfCacheService.deleteAccount(id: accountId, cache: globalModel)
            onAccountChanged()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "删除失败"
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }
}
