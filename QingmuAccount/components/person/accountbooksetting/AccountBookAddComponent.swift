//
//  AccountBookAddComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
struct AccountBookAddComponent : View {
    // 全局环境
    @EnvironmentObject var globalModel:GlobalModel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectAccountBook") private var selectAccountBook = AccountBookHandleService.DEFAULT_NAME
    // 图标的显示样式
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 45), count: 3)
    // 颜色的显示样式
    private let colorGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 40), count: 4)
    
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
    
    // 是否显示提醒
    @State private var showSelfAlter = false
    // 是否显示添加结果
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
                ZStack {
                    // 标题始终居中
                    Text(updateAccountBook != nil ? "编辑账本" : "添加账本")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                    
                    // 删除按钮在右侧（仅在编辑模式且不是默认账本时显示）
                    HStack {
                        Spacer()
                        
                        if updateAccountBook != nil && updateAccountBook?.id != AccountBookHandleService.DEFAULT_UUID {
                            Button(action: {
                                showDeleteConfirm = true
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("RedColor"))
                                    .padding(.trailing, 20)
                            }
                        } else {
                            // 占位符，保持对称
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.clear)
                                .padding(.trailing, 20)
                        }
                    }
                }
                .frame(height: 44)
                .background(Color("ViewBackgroundColor"))
                
                // 预览卡片（始终显示在顶部）
                AccountBookPreviewCard(name: accountBookName, description: accountBookDescription, icon: selectIcon, color: selectColor)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                
                // 进度条
                ProgressStepIndicator(currentStep: $currentStep, totalSteps: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                
                Divider()
                    .padding(.bottom, 16)
                
                // 内容区域
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
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                Divider()
                    .padding(.top, 12)
                
                // 底部按钮
                StepNavigationButtons(currentStep: $currentStep, totalSteps: 3, onConfirm: handleAccountBook)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
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
            loadAssetAccounts()
        }
        .sheet(isPresented: $showAssetAccountPicker) {
            assetAccountPickerSheet
        }
        .onTapGesture {
            toHideKeyboard()
        }
    }
    
    // MARK: - Step 1: 输入名称和描述
    var Step1_NameAndDescription: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("账本信息")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("FontColor"))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("账本名称")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("输入账本名称（6个字以内）", text: $accountBookName)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color("MainBackgroundColor"))
                    .cornerRadius(10)
                    .font(.system(size: 14))
                    .onTapGesture {}
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("账本描述")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text("(可选)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.6))
                }
                
                TextEditor(text: $accountBookDescription)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(height: 100)
                    .background(Color("MainBackgroundColor"))
                    .cornerRadius(10)
                    .font(.system(size: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }

            // 默认资产账户
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("默认账户")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text("(可选)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.6))
                }

                Button {
                    keyFeedback()
                    showAssetAccountPicker = true
                } label: {
                    HStack(spacing: 10) {
                        if let selectedAccount = selectedAssetAccount {
                            AssetAccountIconView(icon: selectedAccount.icon, iconSize: 26, textCornerRadius: 8)
                            Text(selectedAccount.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("FontColor"))
                        } else {
                            Text("选择默认使用的资产账户")
                                .font(.system(size: 14))
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
                    .background(Color("MainBackgroundColor"))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }

            // 默认币型（单选）
            VStack(alignment: .leading, spacing: 8) {
                Text("默认币型")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(AssetCurrency.allCases, id: \.rawValue) { item in
                        currencyChip(item)
                    }
                }
            }

            Spacer()
                .frame(height: 40)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Step 2: 选择图标
    var Step2_SelectIcon: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择图标")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("FontColor"))
            
            Text("为你的账本选择一个喜欢的图标")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                let rows = stride(from: 0, to: accountBookIconArray.count, by: 5).map { index in
                    Array(accountBookIconArray[index..<min(index + 5, accountBookIconArray.count)])
                }
                
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 12) {
                        ForEach(rows[rowIndex], id: \.self) { item in
                            VStack {
                                Text(item.rawValue)
                                    .font(.custom("icomoon", size: 32))
                                    .foregroundColor(selectIcon == item ? .white : Color("DefaultButtonBackgroud"))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(selectIcon == item ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectIcon = item
                                }
                                toHideKeyboard()
                            }
                        }
                    }
                }
            }
            
            Spacer()
                .frame(height: 20)
        }
        .padding(.vertical, 20)
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

    // MARK: - Step 3: 选择颜色
    var Step3_SelectColor: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择颜色")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("FontColor"))
            
            Text("为你的账本选择一个主题颜色")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            
            SoftColorPanel(hex: selectColorBinding)
            
            Spacer()
                .frame(height: 20)
        }
        .padding(.vertical, 20)
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
        return VStack(spacing: 2) {
            Text(item.name)
                .font(.system(size: 13, weight: .bold))
            Text(item.rawValue)
                .font(.system(size: 9))
                .opacity(0.7)
        }
        .foregroundColor(selected ? .white : Color("FontColor"))
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(
            selected ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"),
            in: RoundedRectangle(cornerRadius: 9)
        )
        .shadow(color: selected ? Color("MainShadowColor").opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
        .onTapGesture {
            keyFeedback(0)
            selectedCurrency = item.rawValue
        }
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
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 0) {
                    // 圆圈
                    ZStack {
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
                                .foregroundColor(step <= currentStep ? .white : .gray)
                        }
                    }
                    
                    // 连接线
                    if step < totalSteps {
                        Divider()
                            .frame(height: 2)
                            .background(step < currentStep ? Color("DefaultButtonBackgroud") : Color.gray.opacity(0.15))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(height: 32)
    }
}

// MARK: - 账本预览卡片
struct AccountBookPreviewCard: View {
    let name: String
    let description: String
    let icon: IconFontEnum
    let color: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Color(hex: color.count > 0 ? color : ColorConfig.SOFT_COLORS[0])
                        .cornerRadius(12)
                    
                    Text(icon.rawValue)
                        .font(.custom("icomoon", size: 28))
                        .foregroundColor(.white)
                }
                .frame(width: 56, height: 56)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(StringUtils.trim(name).isEmpty ? "输入账本名称" : StringUtils.trim(name))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(StringUtils.trim(name).isEmpty ? .gray : Color("FontColor"))
                        .lineLimit(1)
                    
                    if !StringUtils.trim(description).isEmpty {
                        Text(StringUtils.trim(description))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color("MainBackgroundColor"))
            .cornerRadius(12)
        }
    }
}

// MARK: - 步骤导航按钮
struct StepNavigationButtons: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let onConfirm: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("上一步")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("MainBackgroundColor"))
                    .cornerRadius(12)
                }
            }
            
            if currentStep < totalSteps {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("下一步")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("DefaultButtonBackgroud"))
                    .cornerRadius(12)
                }
            } else {
                Button(action: onConfirm) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("完成")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("DefaultButtonBackgroud"))
                    .cornerRadius(12)
                }
            }
        }
    }
}

