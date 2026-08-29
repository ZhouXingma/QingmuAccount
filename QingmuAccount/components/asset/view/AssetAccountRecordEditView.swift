//
//  AssetAccountRecordEditView.swift
//  QingmuAccount
//  资产变更「记一笔」（sheet）：类型代表方向，转移联动两个账户，仅调账可切换增减。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI

/// 资产记录输入框（用于调账的双向联动：金额 <-> 目标余额）
private enum AssetRecordInputField: Hashable {
    case amount
    case target
}

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
    @State private var balances: [(currency: String, totalCents: Int64)] = []
    @State private var currentCents: Int64 = 0
    @State private var targetValue: String = ""
    @FocusState private var focusedInput: AssetRecordInputField?

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
                        balanceSection
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
        .onChange(of: setingValue) { _ in
            // 当前正在输入金额时，实时回算目标余额
            guard isAdjust, focusedInput == .amount else { return }
            refreshTargetFromAmount()
        }
        .onChange(of: isPositive) { _ in
            // 切换增减（非编辑目标余额时）时，按金额回算目标余额
            guard isAdjust, focusedInput != .target else { return }
            refreshTargetFromAmount()
        }
        .onChange(of: targetValue) { _ in
            // 当前正在输入目标余额时，实时反推增减与金额
            guard isAdjust, focusedInput == .target else { return }
            refreshAmountFromTarget()
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
                focusedInput = nil
                if item == .adjust {
                    resetAdjustFields()
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
                toHideKeyboard()
                isPositive = positive
            }
    }

    /// 调账余额：两块独立卡片（白底）中间夹箭头，全部居中对齐
    private var balanceSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                balanceBlock(title: "当前余额", value: formatCents(currentCents),
                             color: currentCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                targetBlock
            }
            Text("修改目标余额将自动计算方向与金额")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    /// 只读当前余额块（独立白底卡片，内容居中）
    private func balanceBlock(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(title)（\(AssetCurrency.symbol(of: selectedCurrency))）")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
    }

    /// 目标余额块（独立白底卡片，内容居中）
    private var targetBlock: some View {
        VStack(spacing: 4) {
            Text("目标余额（\(AssetCurrency.symbol(of: selectedCurrency))）")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            TextField("0.00", text: moneyBinding($targetValue, filteredTargetInput))
                .focused($focusedInput, equals: .target)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .bold))
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(Color("FontColor"))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
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
                        // 币型变化时，调账按新币种的当前余额重新计算
                        currentCents = currentBalanceCents(of: code)
                        if isAdjust {
                            resetAdjustFields()
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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("DefaultButtonBackgroud"))
            TextField("0.00", text: moneyBinding($setingValue, filteredMoneyInput))
                .focused($focusedInput, equals: .amount)
                .font(.system(size: 24, weight: .bold))
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
            balances = (try? AssetAccountBalanceService.getBalances(accountId: accountId)) ?? []
            currentCents = currentBalanceCents(of: selectedCurrency)
        } catch {
            accounts = []
        }
    }

    /// 当前账户支持的币型
    private var accountCurrencies: [String] {
        accounts.first { $0.id.uuidString == accountId }?.currencyList ?? []
    }

    private func canSave() -> Bool {
        guard safeMoneyCents(setingValue) > 0 else { return false }
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

    private var isAdjust: Bool {
        return changeType == AssetRecordChangeType.adjust.rawValue
    }

    /// 选中币种的当前余额（分）
    private func currentBalanceCents(of code: String) -> Int64 {
        return balances.first { $0.currency == code }?.totalCents ?? 0
    }

    /// 分转展示字符串（保留两位小数）
    private func formatCents(_ cents: Int64) -> String {
        return SQLiteManager.money(fromCents: cents)
    }

    /// 金额字符串转分：空串 / 非法输入按 0 处理（避免 NSDecimalNumber 对空串乘 100 抛溢出异常）
    private func safeMoneyCents(_ value: String) -> Int64 {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }
        let decimal = NSDecimalNumber(string: trimmed)
        guard !decimal.doubleValue.isNaN else { return 0 }
        return SQLiteManager.cents(fromMoney: trimmed)
    }

    /// 金额输入过滤：仅允许数字与一个小数点（小数点须跟在数字后）
    private func filteredMoneyInput(_ raw: String) -> String {
        var seenDot = false
        return raw.reduce(into: "") { result, ch in
            if ch == "." {
                if seenDot || result.isEmpty { return }
                seenDot = true
                result.append(ch)
            } else if ch.isASCII && ch.isNumber {
                result.append(ch)
            }
        }
    }

    /// 目标余额过滤：可选前导负号，其余为数字与一个小数点（小数点须跟在数字后）
    private func filteredTargetInput(_ raw: String) -> String {
        var seenDot = false
        return raw.reduce(into: "") { result, ch in
            if ch == "-" {
                if result.isEmpty { result.append(ch) }
            } else if ch == "." {
                if seenDot || result.isEmpty || result == "-" { return }
                seenDot = true
                result.append(ch)
            } else if ch.isASCII && ch.isNumber {
                result.append(ch)
            }
        }
    }

    /// 金额输入框绑定：写入前按指定规则过滤非法字符
    private func moneyBinding(_ value: Binding<String>, _ filter: @escaping (String) -> String) -> Binding<String> {
        Binding(get: { value.wrappedValue }, set: { value.wrappedValue = filter($0) })
    }

    /// 当前设置的带符号调整金额（正=增加，负=减少）
    private func adjustSignedCents() -> Int64 {
        let amountCents = abs(safeMoneyCents(setingValue))
        return isPositive ? amountCents : -amountCents
    }

    /// 切换到调账/换币种时，重置为不做调整的初始状态
    private func resetAdjustFields() {
        setingValue = ""
        targetValue = formatCents(currentCents)
        isPositive = true
    }

    /// 由金额 + 方向 → 回算目标余额
    private func refreshTargetFromAmount() {
        targetValue = formatCents(currentCents + adjustSignedCents())
    }

    /// 由目标余额 → 反推增减方向与金额（空/非法按 0 处理）
    private func refreshAmountFromTarget() {
        let targetCents = safeMoneyCents(targetValue)
        let diff = targetCents - currentCents
        if diff > 0 {
            isPositive = true
        } else if diff < 0 {
            isPositive = false
        }
        setingValue = (diff == 0) ? "" : formatCents(abs(diff))
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
