//
//  AccountBookAddComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//
import SwiftUI
import Foundation

struct AccountBookAddComponent : View {
    // 全局环境
    @EnvironmentObject var globalModel:GlobalModel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectAccountBook") private var selectAccountBook = AccountBookHandleService.DEFAULT_NAME

    // 图标的显示样式
    private let iconColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
    // 币型的显示样式
    private let currencyColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    // 步骤控制
    @State private var currentStep: Int = 1

    // 账本名称
    @State private var accountBookName:String = ""
    // 账本描述
    @State private var accountBookDescription:String = ""
    // 选择的图标
    @State private var selectIcon:IconFontEnum = .icon1
    // 选择的颜色
    @State private var selectColor:String = ""
    // 默认资产账户
    @State private var selectedAssetAccountId:String = ""
    @State private var assetAccounts:[AssetAccountModel] = []
    @State private var showAssetAccountPicker = false
    // 默认币型
    @State private var selectedCurrency:String = "CNY"
    // 名称校验
    @State private var showNameError = false
    @FocusState private var nameFieldFocused: Bool

    // 是否显示提醒
    @State private var showSelfAlter = false
    @State private var showNormalAlter = false
    // 失败信息提醒配置
    @State private var alterConfig = AlertComponentConfig()
    // 普通信息提醒配置
    @State private var normalAlterConfig = AlertComponentConfig()
    // 是否显示等待
    @State private var isCreatingWait = false
    // 是否显示删除确认
    @State private var showDeleteConfirm = false
    // 添加成功后/更新成功后的执行对象
    var handleAccountBookSuccessFun: ([String:AccountBookModel]?) -> Void
    // 更新账本名字
    @Binding var updateAccountBook: AccountBookModel?

    var body: some View {
        ZStack {
            Color("ViewBackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部指示条
                RoundedRectangle(cornerRadius: 2.5)
                    .frame(width: 30, height: 5)
                    .padding(.top, 10)
                    .foregroundColor(Color("DefaultButtonBackgroud"))

                // 标题栏
                header

                // 实时预览（悬浮卡片）
                AccountBookPreviewCard(
                    name: accountBookName,
                    description: accountBookDescription,
                    icon: selectIcon,
                    color: selectColor,
                    accountName: selectedAssetAccount?.name ?? "",
                    currency: selectedCurrency
                )
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // 步骤指示
                ProgressStepIndicator(currentStep: $currentStep, totalSteps: 3)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                Divider()
                    .padding(.top, 14)

                // 内容 + 悬浮操作栏
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            switch currentStep {
                            case 1:
                                Step1_NameAndDescription
                            case 2:
                                Step2_SelectIcon
                            case 3:
                                Step3_SelectColor
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 104)
                    }

                    actionBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color("ViewBackgroundColor"))
        .selfAlter(showState: $showSelfAlter, config: alterConfig)
        .selfAlter(showState: $showNormalAlter, config: normalAlterConfig)
        .selfLoading(showState: $isCreatingWait)
        .alert("删除账本", isPresented: $showDeleteConfirm) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                handleDeleteAccountBook()
            }
        } message: {
            Text("确定要删除《\(updateAccountBook?.name ?? "")》吗？此操作无法撤销。")
        }
        .onAppear() {
            self.accountBookName = updateAccountBook?.name ?? ""
            self.accountBookDescription = updateAccountBook?.description ?? ""
            let tempIcon: IconFontEnum = IconFontEnum.findByUnicodeValue(updateAccountBook?.iconStr ?? "") ?? .icon1
            self.selectIcon = tempIcon
            self.selectColor = updateAccountBook?.bgColor ?? ""
            self.selectedAssetAccountId = updateAccountBook?.defaultAssetAccountId ?? ""
            self.selectedCurrency = updateAccountBook?.defaultCurrency ?? "CNY"
            self.showNameError = false
            loadAssetAccounts()
        }
        .sheet(isPresented: $showAssetAccountPicker) {
            assetAccountPickerSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onTapGesture {
            toHideKeyboard()
        }
    }

    // MARK: - 标题栏

    private var header: some View {
        ZStack {
            Text(updateAccountBook != nil ? "编辑账本" : "添加账本")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("FontColor"))

            HStack {
                Spacer()

                if updateAccountBook != nil && updateAccountBook?.id != AccountBookHandleService.DEFAULT_UUID {
                    Button(action: {
                        showDeleteConfirm = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("RedColor"))
                            .frame(width: 34, height: 34)
                    }
                } else {
                    // 占位符，保持标题居中
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.clear)
                        .frame(width: 34, height: 34)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 44)
    }

    // MARK: - 悬浮操作栏

    private var actionBar: some View {
        HStack(spacing: 8) {
            if currentStep > 1 {
                Button(action: goBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("上一步")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if currentStep < 3 {
                Button(action: goNext) {
                    HStack(spacing: 6) {
                        Text("下一步")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("DefaultButtonBackgroud"), in: Capsule())
                    .shadow(color: Color("DefaultButtonBackgroud").opacity(0.28), radius: 10, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: finish) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("完成")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("DefaultButtonBackgroud"), in: Capsule())
                    .shadow(color: Color("DefaultButtonBackgroud").opacity(0.28), radius: 10, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color("MainShadowColor").opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 18, x: 0, y: 10)
    }

    // MARK: - Step 1: 输入名称和描述

    var Step1_NameAndDescription: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("账本信息")
                .font(.system(size: 16.5, weight: .semibold))
                .foregroundColor(Color("FontColor"))

            // 账本名称
            VStack(alignment: .leading, spacing: 7) {
                Text("账本名称")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                ZStack(alignment: .trailing) {
                    TextField("输入账本名称（6个字以内）", text: $accountBookName)
                        .font(.system(size: 15))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.trailing, 48)
                        .frame(height: 48)
                        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(nameFieldBorder, lineWidth: 1)
                        )
                        .focused($nameFieldFocused)
                        .onChange(of: accountBookName) { value in
                            if value.count > 6 {
                                accountBookName = String(value.prefix(6))
                            }
                            if showNameError && StringUtils.trimCount(value) > 0 {
                                showNameError = false
                            }
                        }

                    Text("\(accountBookName.count)/6")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 13)
                }

                if showNameError {
                    Text("请先填写账本名称")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color("RedColor"))
                }
            }

            // 账本描述
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 5) {
                    Text("账本描述")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("(可选)")
                        .font(.system(size: 11.5))
                        .foregroundColor(.secondary.opacity(0.6))
                }

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $accountBookDescription)
                        .font(.system(size: 15))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color.clear)

                    if accountBookDescription.isEmpty {
                        Text("这笔账本用来记什么？")
                            .font(.system(size: 15))
                            .foregroundColor(Color.gray.opacity(0.55))
                            .padding(.horizontal, 13)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 100)
                .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color("MainShadowColor").opacity(0.1), lineWidth: 1)
                )
            }

            // 默认资产账户
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 5) {
                    Text("默认账户")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("(可选)")
                        .font(.system(size: 11.5))
                        .foregroundColor(.secondary.opacity(0.6))
                }

                Button {
                    keyFeedback()
                    showAssetAccountPicker = true
                } label: {
                    HStack(spacing: 10) {
                        if let selectedAccount = selectedAssetAccount {
                            AssetAccountIconView(icon: selectedAccount.icon, iconSize: 26, textCornerRadius: 8)
                            Text(selectedAccount.name)
                                .font(.system(size: 14.5, weight: .medium))
                                .foregroundColor(Color("FontColor"))
                        } else {
                            Text("选择默认使用的资产账户")
                                .font(.system(size: 14.5))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("MainShadowColor").opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            // 默认币型
            VStack(alignment: .leading, spacing: 7) {
                Text("默认币型")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                LazyVGrid(columns: currencyColumns, spacing: 8) {
                    ForEach(AssetCurrency.allCases, id: \.rawValue) { item in
                        currencyChip(item)
                    }
                }
            }
        }
        .padding(.top, 18)
    }

    private var nameFieldBorder: Color {
        if showNameError && StringUtils.trimCount(accountBookName) <= 0 {
            return Color("RedColor")
        }
        if nameFieldFocused {
            return Color("DefaultButtonBackgroud")
        }
        return Color("MainShadowColor").opacity(0.1)
    }

    // MARK: - Step 2: 选择图标

    var Step2_SelectIcon: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("选择图标")
                .font(.system(size: 16.5, weight: .semibold))
                .foregroundColor(Color("FontColor"))

            Text("为你的账本选择一个喜欢的图标。")
                .font(.system(size: 12.5))
                .foregroundColor(.secondary)

            LazyVGrid(columns: iconColumns, spacing: 10) {
                ForEach(accountBookIconArray, id: \.self) { item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectIcon = item
                        }
                        toHideKeyboard()
                    } label: {
                        Text(item.rawValue)
                            .font(.custom("icomoon", size: 30))
                            .foregroundColor(selectIcon == item ? .white : Color("DefaultButtonBackgroud"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                selectIcon == item ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(selectIcon == item ? Color.clear : Color("MainShadowColor").opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 11)
        }
        .padding(.top, 18)
    }

    // MARK: - Step 3: 选择颜色

    var Step3_SelectColor: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Text("选择颜色")
                    .font(.system(size: 16.5, weight: .semibold))
                    .foregroundColor(Color("FontColor"))

                Spacer()

                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(hex: normalizedSelectColor))
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                    Text("#" + normalizedSelectColor.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }

            Text("为你的账本选择一个主题颜色。")
                .font(.system(size: 12.5))
                .foregroundColor(.secondary)

            SoftColorPanel(hex: selectColorBinding)
                .padding(.top, 11)
        }
        .padding(.top, 18)
    }

    private var normalizedSelectColor: String {
        let value = selectColor.isEmpty ? ColorConfig.SOFT_COLORS[0] : selectColor
        return value.replacingOccurrences(of: "#", with: "")
    }

    /// SoftColorPanel 绑定：兼容带 # 的 selectColor
    private var selectColorBinding: Binding<String> {
        Binding(
            get: { selectColor.hasPrefix("#") ? String(selectColor.dropFirst()) : selectColor },
            set: { newHex in
                selectColor = newHex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : "#" + newHex
            }
        )
    }

    /**
     当前选中的默认账户
     */
    var selectedAssetAccount: AssetAccountModel? {
        guard !selectedAssetAccountId.isEmpty else { return nil }
        return assetAccounts.first { $0.id.uuidString == selectedAssetAccountId }
    }

    /// 默认币型单选 chip
    func currencyChip(_ item: AssetCurrency) -> some View {
        let selected = selectedCurrency == item.rawValue
        return Button {
            keyFeedback(0)
            selectedCurrency = item.rawValue
        } label: {
            VStack(spacing: 1) {
                Text(item.name)
                    .font(.system(size: 13, weight: .bold))
                Text(item.rawValue)
                    .font(.system(size: 9))
                    .opacity(0.62)
            }
            .foregroundColor(selected ? .white : Color("FontColor"))
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                selected ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? Color.clear : Color("MainShadowColor").opacity(0.08), lineWidth: 1)
            )
            .shadow(color: selected ? Color("DefaultButtonBackgroud").opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    /**
     加载资产账户
     */
    func loadAssetAccounts() {
        do {
            assetAccounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
        } catch {
            assetAccounts = []
        }
    }

    /**
     默认账户选择面板
     */
    var assetAccountPickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择默认账户")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Button {
                    showAssetAccountPicker = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    notSetRow
                    ForEach(assetAccounts, id: \.id) { account in
                        assetAccountPickerRow(account)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
    }

    /// 「不设置」默认账户行
    var notSetRow: some View {
        let selected = selectedAssetAccountId.isEmpty
        return HStack(spacing: 12) {
            Image(systemName: "nosign")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 30, height: 30)
                .padding(7)
                .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
            Text("不设置")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color("FontColor"))
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            }
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 50)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selected ? Color("DefaultButtonBackgroud") : Color("MainShadowColor").opacity(0.06), lineWidth: selected ? 1.5 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            keyFeedback(0)
            selectedAssetAccountId = ""
            showAssetAccountPicker = false
        }
    }

    /// 账户选择行（图标 + 名称 + 类型·币型 + 余额）
    func assetAccountPickerRow(_ account: AssetAccountModel) -> some View {
        let selected = selectedAssetAccountId == account.id.uuidString
        return HStack(spacing: 12) {
            AssetAccountIconView(icon: account.icon, iconSize: 30, textCornerRadius: 10)
                .padding(7)
                .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(account.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                    .lineLimit(1)
                Text("\(AssetAccountType(rawValue: account.type)?.name ?? "") · \(account.currencyDisplayName)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(account.totalMoney)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(account.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            }
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 62)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selected ? Color("DefaultButtonBackgroud") : Color("MainShadowColor").opacity(0.06), lineWidth: selected ? 1.5 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            keyFeedback(0)
            selectedAssetAccountId = account.id.uuidString
            showAssetAccountPicker = false
        }
    }

    // MARK: - 步骤操作

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = max(1, currentStep - 1)
        }
    }

    private func goNext() {
        if currentStep == 1 && !validForm() {
            showNameError = true
            nameFieldFocused = true
            return
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = min(3, currentStep + 1)
        }
    }

    private func finish() {
        if !validForm() {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentStep = 1
            }
            showNameError = true
            nameFieldFocused = true
            return
        }
        handleAccountBook()
    }

    /**
     处理账本的操作
     */
    func handleAccountBook () {
        if nil != updateAccountBook {
            updateAccountBookSure()
        } else {
            addAccountBook()
        }
    }

    /**
     添加账本
     */
    func addAccountBook() {
        alterConfig.showCancelButton = true
        alterConfig.cancalButtonName = "取消"
        alterConfig.showSureButton = true
        alterConfig.sureButtonName = "确定"
        alterConfig.desc="确定添加该账本吗？"
        alterConfig.cancelFun = {}
        alterConfig.sureFun = addAccountBookSure
        withAnimation(.easeOut) {
            showSelfAlter = true
        }
    }
    /**
    确认添加账本操作
     */
    func addAccountBookSure() {
        isCreatingWait = true
        do {
            let data = try AccountBookHandleOfCacheService.addAccountBook(name: StringUtils.trim(accountBookName), icon: selectIcon.getUnicodeValue(), bgColor: selectColor, description: StringUtils.trim(accountBookDescription).isEmpty ? nil : StringUtils.trim(accountBookDescription), defaultAssetAccountId: selectedAssetAccountId, defaultCurrency: selectedCurrency, cache: globalModel)
            openNormalAlter("添加账本成功！")
            accountBookName=""
            handleAccountBookSuccessFun(data)
            // 延迟关闭，确保提示框显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch AccountBookHandleError.ISEXIT {
            openNormalAlter("添加账本失败！该账本已经存在",.RED)
        } catch {
            openNormalAlter("添加账本失败！",.RED)
        }
        isCreatingWait = false
    }

    func updateAccountBookSure() {
        isCreatingWait = true
        do {
            let data = try AccountBookHandleOfCacheService.updateAccountBook(id: updateAccountBook!.id, name: StringUtils.trim(accountBookName), icon: selectIcon.getUnicodeValue(), bgColor: selectColor, description: StringUtils.trim(accountBookDescription).isEmpty ? nil : StringUtils.trim(accountBookDescription), defaultAssetAccountId: selectedAssetAccountId, defaultCurrency: selectedCurrency, cache: globalModel)
            openNormalAlter("更新账本成功！")
            handleAccountBookSuccessFun(data)
            // 延迟关闭，确保提示框显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch AccountBookHandleError.ISNOTEXIT {
            openNormalAlter("更新账本失败！该账本不存在",.RED)
        } catch {
            openNormalAlter("更新账本失败！",.RED)
        }
        isCreatingWait = false
    }

    /**
     删除账本
     */
    func handleDeleteAccountBook() {
        guard let bookName = updateAccountBook?.name else { return }
        isCreatingWait = true
        do {
            let _ = try AccountBookHandleOfCacheService.deleteAccountBook(bookName, cache: globalModel)

            // 如果删除的是当前选中的账本，则切换到日常账本
            if selectAccountBook == bookName {
                selectAccountBook = AccountBookHandleService.DEFAULT_NAME
                let _ = try AccountBookHandleOfCacheService.changeSelectAccountBook(name: AccountBookHandleService.DEFAULT_NAME, cache: globalModel)
            }

            openNormalAlter("账本删除成功！")
            // 延迟关闭，确保提示框显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                handleAccountBookSuccessFun(try? AccountBookHandleOfCacheService.getAccountBooks(cache: globalModel))
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            openNormalAlter("账本删除失败！",.RED)
        }
        isCreatingWait = false
    }

    /**
    开启普通提示
     */
    func openNormalAlter(_ desc:String, _ style:AlertComponentTopBarColorStyle = .DEFAULT) {
        normalAlterConfig.showCancelButton = false
        normalAlterConfig.showSureButton = true
        normalAlterConfig.sureButtonName = "我知道啦！"
        normalAlterConfig.desc = desc
        normalAlterConfig.topBarColorStyle = style
        withAnimation {
            showNormalAlter = true
        }
    }
    /**
    表单是否已经填写完整
     */
    func validForm() -> Bool {
        if(StringUtils.trimCount(accountBookName) <= 0 || StringUtils.trimCount(accountBookName) > 6) {
            return false
        }
        return true
    }
}

// MARK: - 进度指示器
struct ProgressStepIndicator: View {
    @Binding var currentStep: Int
    let totalSteps: Int

    private let labels = ["信息", "图标", "颜色"]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        currentStep = step
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            // 当前步骤的柔和外环
                            Circle()
                                .fill(Color("DefaultButtonBackgroud").opacity(step == currentStep ? 0.12 : 0))
                                .frame(width: 36, height: 36)

                            Circle()
                                .fill(step <= currentStep ? Color("DefaultButtonBackgroud") : Color.gray.opacity(0.15))
                                .frame(width: 28, height: 28)

                            if step < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(step)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(step == currentStep ? .white : .gray)
                            }
                        }

                        Text(labels[min(step - 1, labels.count - 1)])
                            .font(.system(size: 10.5, weight: step == currentStep ? .semibold : .regular))
                            .foregroundColor(step == currentStep ? Color("FontColor") : .secondary)
                    }
                    .frame(width: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? Color("DefaultButtonBackgroud") : Color.gray.opacity(0.15))
                        .frame(height: 2)
                        .padding(.top, 17)
                }
            }
        }
    }
}

// MARK: - 账本预览卡片（悬浮）
struct AccountBookPreviewCard: View {
    let name: String
    let description: String
    let icon: IconFontEnum
    let color: String
    let accountName: String
    let currency: String

    private var bookColor: Color {
        Color(hex: color.count > 0 ? color : ColorConfig.SOFT_COLORS[0])
    }

    private var trimmedName: String {
        StringUtils.trim(name)
    }

    private var trimmedDescription: String {
        StringUtils.trim(description)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(bookColor)

                    Text(icon.rawValue)
                        .font(.custom("icomoon", size: 28))
                        .foregroundColor(.white)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 3) {
                    Text(trimmedName.isEmpty ? "输入账本名称" : trimmedName)
                        .font(.system(size: 15.5, weight: .bold))
                        .foregroundColor(trimmedName.isEmpty ? .gray : Color("FontColor"))
                        .lineLimit(1)

                    Text(trimmedDescription.isEmpty ? "添加一句描述" : trimmedDescription)
                        .font(.system(size: 11.5))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            Divider()
                .padding(.top, 10)

            HStack(spacing: 12) {
                Text(accountName.isEmpty ? "未设置默认账户" : accountName)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(AssetCurrency.name(of: currency))
                    .lineLimit(1)
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .padding(.top, 9)
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color("MainShadowColor").opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 10)
    }
}
