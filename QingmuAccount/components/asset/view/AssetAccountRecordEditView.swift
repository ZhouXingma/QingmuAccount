//
//  AssetAccountRecordEditView.swift
//  QingmuAccount
//  资产变更「记一笔」（sheet）：类型代表方向，转移联动两个账户，仅调账可切换增减。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI

struct AssetAccountRecordEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    let accountId: String
    var onSave: () -> Void = {}

    @State private var changeType: Int = AssetRecordChangeType.transferIn.rawValue
    @State private var isPositive: Bool = true
    @State private var targetAccountId: String? = nil
    @State private var accounts: [AssetAccountModel] = []
    @State private var selectedCurrency: String = "CNY"
    @State private var setingValue: String = ""
    @State private var remark: String = ""
    @State private var showTargetPicker = false
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")

    private let typeColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderComponent(title: "记一笔")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    typeSection
                    if isTransfer {
                        targetSection
                    }
                    if needDirection {
                        directionSection
                    }
                    amountSection
                    remarkSection
                }
                .padding(.horizontal, 15)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .padding(.top, 12)

            // 保存
            Button {
                save()
            } label: {
                Text("保存")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Color("DefaultButtonBackgroud").opacity(canSave() ? 1 : ColorConfig.UNABLE_COLOR_OPCITY),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .shadow(color: canSave() ? Color("MainShadowColor").opacity(0.25) : Color.clear, radius: 6, x: 0, y: 3)
            }
            .disabled(!canSave())
            .padding(.horizontal, 15)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .onTapGesture { toHideKeyboard() }
        .onAppear {
            loadAccounts()
        }
        .sheet(isPresented: $showTargetPicker) {
            targetPickerSheet
        }
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    // MARK: - 状态判断

    private var isTransfer: Bool {
        return changeType == AssetRecordChangeType.transfer.rawValue
    }

    private var needDirection: Bool {
        return AssetRecordChangeType(rawValue: changeType)?.needDirectionPicker ?? false
    }

    private var selectedTargetAccount: AssetAccountModel? {
        guard let targetAccountId = targetAccountId else { return nil }
        return accounts.first { $0.id.uuidString == targetAccountId }
    }

    private var targetAccounts: [AssetAccountModel] {
        // 转入账户必须支持当前所选币型
        return accounts.filter {
            $0.id.uuidString != accountId && $0.currencyList.contains(selectedCurrency)
        }
    }

    // MARK: - 区块

    /// 类型选择（2 列大格子）
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("类型").font(.system(size: 15, weight: .bold))
            LazyVGrid(columns: typeColumns, spacing: 10) {
                ForEach(AssetRecordChangeType.allCases, id: \.rawValue) { item in
                    typeChip(item)
                }
            }
        }
        .padding(14)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 14))
    }

    private func typeChip(_ item: AssetRecordChangeType) -> some View {
        let selected = changeType == item.rawValue
        return HStack(spacing: 6) {
            Image(systemName: typeIcon(item))
                .font(.system(size: 14, weight: .bold))
            Text(item.name)
                .font(.system(size: 15, weight: .bold))
        }
        .foregroundColor(selected ? .white : Color("FontColor"))
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
            selected ? Color("DefaultButtonBackgroud") : Color("ViewBackgroundColor"),
            in: RoundedRectangle(cornerRadius: 10)
        )
        .shadow(color: selected ? Color("MainShadowColor").opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.15), value: changeType)
        .onTapGesture {
            keyFeedback(0)
            if changeType != item.rawValue {
                changeType = item.rawValue
                isPositive = item.defaultPositive
                if !item.needDirectionPicker {
                    targetAccountId = nil
                }
            }
        }
    }

    private func typeIcon(_ item: AssetRecordChangeType) -> String {
        switch item {
        case .transferIn: return "arrow.down.left.circle"
        case .transferOut: return "arrow.up.right.circle"
        case .transfer: return "arrow.left.arrow.right"
        case .adjust: return "slider.horizontal.3"
        }
    }

    /// 转移时：选择转入账户
    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("转入账户").font(.system(size: 15, weight: .bold))
            Button {
                keyFeedback()
                showTargetPicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.turn.down.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                    if let target = selectedTargetAccount {
                        AssetAccountIconView(icon: target.icon, iconSize: 24, textCornerRadius: 8)
                            .padding(5)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        Text(target.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("FontColor"))
                    } else {
                        Text("请选择转入的账户")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 54)
                .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 14))
    }

    /// 调账时：增/减切换
    private var directionSection: some View {
        HStack {
            Text("方向")
                .font(.system(size: 15, weight: .bold))
            Spacer()
            HStack(spacing: 8) {
                directionChip(title: "增加", positive: true)
                directionChip(title: "减少", positive: false)
            }
        }
        .padding(.horizontal, 14)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 56)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private func directionChip(title: String, positive: Bool) -> some View {
        let selected = isPositive == positive
        return Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(selected ? .white : Color("FontColor"))
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(
                selected ? (positive ? Color("DefaultButtonBackgroud") : Color("RedColor")) : Color("ViewBackgroundColor"),
                in: RoundedRectangle(cornerRadius: 9)
            )
            .shadow(color: selected ? Color("MainShadowColor").opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.15), value: isPositive)
            .onTapGesture {
                keyFeedback(0)
                isPositive = positive
            }
    }

    /// 金额输入（左侧币型下拉 + 右侧金额）
    private var amountSection: some View {
        HStack(alignment: .lastTextBaseline, spacing: 10) {
            // 币型下拉（金额左侧，固定宽度避免切换闪烁）
            Menu {
                ForEach(accountCurrencies, id: \.self) { code in
                    Button {
                        keyFeedback(0)
                        selectedCurrency = code
                        // 币型变化时，转移的转入账户需重新选择
                        if isTransfer {
                            targetAccountId = nil
                        }
                    } label: {
                        Text(AssetCurrency.name(of: code))
                    }
                }
            } label: {
                HStack(spacing: 3) {
                    Text(AssetCurrency.name(of: selectedCurrency))
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(Color("DefaultButtonBackgroud"))
                .frame(width: 78, height: 30)
                .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 9))
            }
            Spacer()
            Text(AssetCurrency.symbol(of: selectedCurrency))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("DefaultButtonBackgroud"))
            TextField("0.00", text: $setingValue)
                .font(.system(size: 32, weight: .bold))
                .keyboardType(.decimalPad)
                .foregroundColor(Color("FontColor"))
                .onTapGesture { toHideKeyboard() }
        }
        .padding(.horizontal, 16)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 74)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
    }

    /// 备注
    private var remarkSection: some View {
        HStack {
            Image(systemName: "text.alignleft")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
            TextField("备注（选填）", text: $remark)
                .font(.system(size: 15))
                .foregroundColor(Color("FontColor"))
                .onTapGesture { toHideKeyboard() }
        }
        .padding(.horizontal, 16)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 54)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var cardBackground: Color {
        return Color("MainBackgroundColor")
    }

    // MARK: - 目标账户选择 sheet

    private var targetPickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择转入账户")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Button {
                    showTargetPicker = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 10)

            if targetAccounts.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("暂无其他账户")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                    Text("转移需要在两个账户之间进行，请先到「资产账户」中添加其他账户")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(targetAccounts, id: \.id) { account in
                            targetAccountRow(account)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
    }

    private func targetAccountRow(_ account: AssetAccountModel) -> some View {
        let selected = targetAccountId == account.id.uuidString
        return HStack(spacing: 12) {
            AssetAccountIconView(icon: account.icon, iconSize: 28, textCornerRadius: 10)
                .padding(7)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(account.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Text(account.totalMoney)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            }
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 58)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selected ? Color("DefaultButtonBackgroud") : Color("MainShadowColor").opacity(0.06), lineWidth: selected ? 1.5 : 1)
        )
        .onTapGesture {
            keyFeedback(0)
            targetAccountId = account.id.uuidString
            showTargetPicker = false
        }
    }

    // MARK: - 逻辑

    private func loadAccounts() {
        do {
            accounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            selectedCurrency = accounts.first { $0.id.uuidString == accountId }?.primaryCurrency ?? "CNY"
        } catch {
            accounts = []
        }
    }

    /// 当前账户支持的币型
    private var accountCurrencies: [String] {
        accounts.first { $0.id.uuidString == accountId }?.currencyList ?? []
    }

    private func canSave() -> Bool {
        guard setingValue.count > 0,
              setingValue != "0", setingValue != "0.", setingValue != "0.0", setingValue != "0.00" else { return false }
        if isTransfer {
            return targetAccountId != nil
        }
        return true
    }

    private func save() {
        keyFeedback()
        let amountCents = abs(SQLiteManager.cents(fromMoney: setingValue))
        do {
            if isTransfer {
                guard let target = targetAccountId else {
                    alterConfig.desc = "请选择转入账户"
                    alterConfig.topBarColorStyle = .RED
                    alterConfig.showCancelButton = false
                    alterConfig.sureButtonName = "知道了"
                    showAlter = true
                    return
                }
                try AssetAccountRecordOfCacheService.transferRecord(
                    fromAccountId: accountId, toAccountId: target,
                    amountCents: amountCents, money: setingValue, remark: remark, currency: selectedCurrency, cache: globalModel
                )
            } else {
                let signed = signedAmount(amountCents)
                try AssetAccountRecordOfCacheService.addRecord(
                    accountId: accountId,
                    changeType: changeType,
                    signedMoneyCents: signed,
                    money: setingValue,
                    remark: remark,
                    currency: selectedCurrency,
                    cache: globalModel
                )
            }
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "保存失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }

    /// 非转移类型的带符号金额（类型即方向，调账按手动选择）
    private func signedAmount(_ amountCents: Int64) -> Int64 {
        switch AssetRecordChangeType(rawValue: changeType) ?? .transferIn {
        case .transferIn: return amountCents
        case .transferOut: return -amountCents
        case .transfer: return -amountCents
        case .adjust: return isPositive ? amountCents : -amountCents
        }
    }
}
