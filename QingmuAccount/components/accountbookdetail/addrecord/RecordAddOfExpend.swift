//
//  AccountBookAddRecordOfInComponent.swift
//  QingmuAccount
//
//  账本记录-支出
//  Created by 周荥马 on 2022/12/7.

import SwiftUI

struct RecordAddOfExpend : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 5), count: 5)
    // 该支付类型
    let payType:Int = 0
    /**
     新记录进行操作了，添加了新记录后执行的函数
     */
    @State var newRecordUpdate:(AccountBookData)->Void = {_ in }
    // 数据
    @State var money:String = "0.00"
    @State var title:String = defaultAccountBookOutRecordIcon[0].name
    @State var desc:String = ""
    @State var iconStr:String = defaultAccountBookOutRecordIcon[0].iconStr
    @State var computerStr = ""
    @State var dateStr = DateUtils.transDate2String(Date(), format: "yyyyMMdd")
    // 提醒
    @State var showAlter = false
    @State var alterConfig = AlertComponentConfig()
    // 图标
    @State var outRecordIcons:[AccountBookSetingOfIconModel] = defaultAccountBookOutRecordIcon
    // 账本配置信息
    @State var accountBookSeting:AccountBookSetingModel? = nil
    @State var selectAccountBook:AccountBookModel? = nil
    // 显示图标编辑
    @State var showEditIcon:Bool = false
    // 进行更新的数据
    @Binding var updateRecord:AccountBookData?
    // 列表进入还是日历进入
    @Binding var listType:Int;
    // 自定义选择的时间
    @Binding var selectDate:Date?
    // 账户
    @State var selectedAccountId: String = ""
    @State var showAccountPicker = false
    @State var assetAccounts: [AssetAccountModel] = []
    // 币型（空 = 自动跟随账户/账本默认币型）
    @State var selectedCurrency: String = ""
    @State var showCurrencyPicker = false
    
    
    var body: some View {
        VStack {
            HStack {
                RecordAddItemShow(iconStr: $iconStr, money: $money, title: $title, desc: $desc, computerDesc: $computerStr)
            }.padding(.horizontal,15)
                .padding(.vertical,5)
           
            ScrollView(.vertical,showsIndicators: false) {
                LazyVGrid(columns: iConGridItems) {
                    ForEach(outRecordIcons ,id:\.self) { item in
                        
                        RecordItemIconButton(iconStr:item.iconStr, name:item.name, selectIconStr: $iconStr)
                            .highPriorityGesture(
                                TapGesture().onEnded({ _ in
                                    keyFeedback()
                                    iconStr = item.iconStr
                                    title = item.name
                                })
                            )
                    }
                    RecordItemIconButton(iconStr:"plus.circle", name:"编辑",isImage: true, selectIconStr: $iconStr)
                        .highPriorityGesture(
                            TapGesture().onEnded({ _ in
                                keyFeedback()
                                showEditIcon = true
                            })
                        )
                }.padding(.horizontal,15)
                    .padding(.vertical,5)
            }
            keyBoard
        }.ignoresSafeArea()
            .sheet(isPresented: $showEditIcon, content: {
                RecordIconSeting(iconType: payType,haveChangeIcons: {
                    loadAccountBookInfo()
                    initUpdateData()
                }).environmentObject(globalModel)
            })
            .onAppear() {
                loadAccountBookInfo()
                initUpdateData()
                loadAssetAccounts()
            }
            .sheet(isPresented: $showAccountPicker) {
                accountPickerSheet
            }
            .sheet(isPresented: $showCurrencyPicker) {
                currencyPickerSheet
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
    }

    /**
     键盘
     */
    var keyBoard:some View {
        AcountKeyBoard(date: trans2KeyDateStrFormat(updateRecord?.dateStr), desc: updateRecord?.desc ?? "", accountName: selectedAccountName, accountTapFun: {
            showAccountPicker = true
        }, currencyName: currencyNameText, currencyTapFun: {
            showCurrencyPicker = true
        }) { newDesc in
            desc = newDesc
        } dateChangeFun: { newDate in
            dateStr = DateUtils.transDate2String(DateUtils.transString2Date(newDate, format: "yyyy-MM-dd") ?? Date(), format: "yyyyMMdd")
        } keyTabFun: { keyId in
            if (keyId == 15) {
                // 完成
                if ((money as NSString).doubleValue < 0) {
                    alterConfig.cancalButtonName = "清空"
                    alterConfig.desc="您这金额该是收入了"
                    alterConfig.cancelFun = reset
                    showAlter = true
                    return
                }
                if ((money as NSString).doubleValue == 0) {
                    alterConfig.cancalButtonName = "清空"
                    alterConfig.desc="请输入正常的金额"
                    alterConfig.cancelFun = reset
                    showAlter = true
                    return
                }
                // 完成其它操作
                if (nil != updateRecord) {
                    updateData()
                } else {
                    addData()
                }
            }
            if (computerStr.count >= 49 && keyId != 12) {
                // 超长计算
                alterConfig.cancalButtonName = "清空"
                alterConfig.desc="暂不支持超长计算"
                alterConfig.cancelFun = reset
                showAlter = true
                return
            }
            AcountKeyComputerHandle.handleAccountKeyTab(keyId: keyId, computerDesc: &computerStr, value: &money)
        }.frame(height: 300).padding(.bottom,25)
    }
    /**
     重置计算信息
     */
    func reset() {
        self.computerStr = ""
        self.money = "0.00"
    }

    // MARK: - 账户

    /// 当前选中账户名称（显示用）
    var selectedAccountName: String {
        assetAccounts.first { $0.id.uuidString == selectedAccountId }?.name ?? ""
    }

    /// 加载资产账户，编辑时默认选中记录原账户，新增时默认账本默认账户
    func loadAssetAccounts() {
        do {
            assetAccounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            if let rec = updateRecord {
                selectedAccountId = rec.accountId
                selectedCurrency = rec.currency.isEmpty ? defaultBookCurrency : rec.currency
            } else {
                selectedAccountId = globalModel.accountBook?.defaultAssetAccountId ?? ""
                selectedCurrency = defaultBookCurrency
            }
            syncCurrencyWithAccount()
        } catch {
            assetAccounts = []
        }
    }

    // MARK: - 币型

    /// 账本默认币型，未设置默认币型时用人民币
    var defaultBookCurrency: String {
        let currency = globalModel.accountBook?.defaultCurrency ?? ""
        return currency.isEmpty ? "CNY" : currency
    }
    /// 键盘上币型显示的中文名
    var currencyNameText: String {
        AssetCurrency.name(of: selectedCurrency)
    }
    /// 可选币型：选了账户时受账户币型数组限制，否则 10 种都可选
    var availableCurrencies: [String] {
        if !selectedAccountId.isEmpty, let account = assetAccounts.first(where: { $0.id.uuidString == selectedAccountId }) {
            return account.currencyList
        }
        return AssetCurrency.allCases.map { $0.rawValue }
    }
    /// 选了账户时，所选币型须在账户币型数组内，否则自动切换为账户主币型
    func syncCurrencyWithAccount() {
        guard !selectedAccountId.isEmpty else { return }
        guard let account = assetAccounts.first(where: { $0.id.uuidString == selectedAccountId }) else { return }
        if !account.currencyList.contains(selectedCurrency) {
            selectedCurrency = account.primaryCurrency
        }
    }
    /// 校验：选了账户时，所选币型必须在账户币型数组中
    func validateCurrencyWithAccount() -> Bool {
        guard !selectedAccountId.isEmpty else { return true }
        guard let account = assetAccounts.first(where: { $0.id.uuidString == selectedAccountId }) else { return true }
        return account.currencyList.contains(selectedCurrency)
    }
    /// 币型与账户不匹配的提醒
    func showCurrencyNotSupportAlter() {
        alterConfig.showCancelButton = false
        alterConfig.desc = "所选币型不在该账户支持的币型中，请重新选择币型或账户"
        alterConfig.sureButtonName = "知道了"
        showAlter = true
    }

    var accountPickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择账户")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Button {
                    showAccountPicker = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 10)

            if assetAccounts.isEmpty {
                Spacer()
                Text("暂无资产账户")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        // 不设置账户
                        HStack(spacing: 12) {
                            Image(systemName: "nosign")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.secondary)
                                .frame(width: 26, height: 26)
                                .padding(6)
                                .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 9))
                            Text("不设置账户")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color("FontColor"))
                            Spacer()
                            if selectedAccountId.isEmpty {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color("DefaultButtonBackgroud"))
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            keyFeedback(0)
                            selectedAccountId = ""
                            showAccountPicker = false
                        }
                        ForEach(assetAccounts, id: \.id) { account in
                            accountPickerRow(account)
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

    func accountPickerRow(_ account: AssetAccountModel) -> some View {
        let selected = selectedAccountId == account.id.uuidString
        return HStack(spacing: 12) {
            AssetAccountIconView(icon: account.icon, iconSize: 26, textCornerRadius: 9)
                .padding(6)
                .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 9))
            Text(account.name)
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
            selectedAccountId = account.id.uuidString
            syncCurrencyWithAccount()
            showAccountPicker = false
        }
    }

    // MARK: - 币型

    var currencyPickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择币型")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Button {
                    showCurrencyPicker = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 10)

            if !selectedAccountId.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("已按所选账户的币型筛选，置灰的不可选")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(AssetCurrency.allCases, id: \.rawValue) { item in
                        currencyPickChip(item)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
    }

    /// 币型单选 chip（账户不支持时置灰不可选）
    func currencyPickChip(_ item: AssetCurrency) -> some View {
        let selected = selectedCurrency == item.rawValue
        let available = availableCurrencies.contains(item.rawValue)
        return VStack(spacing: 2) {
            Text(item.name)
                .font(.system(size: 13, weight: .bold))
            Text(item.rawValue)
                .font(.system(size: 9))
                .opacity(0.7)
        }
        .foregroundColor(selected ? .white : Color("FontColor"))
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
            available ? (selected ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor")) : Color("MainBackgroundColor"),
            in: RoundedRectangle(cornerRadius: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selected ? Color("DefaultButtonBackgroud") : Color.clear, lineWidth: 1.5)
        )
        .opacity(available ? 1 : 0.4)
        .shadow(color: available && selected ? Color("MainShadowColor").opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
        .onTapGesture {
            keyFeedback(0)
            guard available else { return }
            selectedCurrency = item.rawValue
            showCurrencyPicker = false
        }
    }
    
    
    func initUpdateData() {
        if nil == updateRecord {
            if nil == selectDate {
                return
            }
            if listType == 1 {
                let nowDateStr = DateUtils.transDate2String(Date(), format: "yyyyMMdd");
                let selectDateStr = DateUtils.transDate2String(selectDate!, format: "yyyyMMdd")
                if selectDateStr > nowDateStr {
                    dateStr = nowDateStr
                } else {
                    dateStr = selectDateStr
                }
            }
            return
        }
        if updateRecord!.type == payType {
            title = updateRecord!.title
            desc = updateRecord!.desc
            iconStr = updateRecord!.iconStr
            money = updateRecord!.money
            dateStr = updateRecord!.dateStr
            computerStr = ""
        } else {
            desc = updateRecord!.desc
            money = updateRecord!.money
            dateStr = updateRecord!.dateStr
            computerStr = ""
        }
    }
    
    func updateData() {
        if nil == updateRecord {
            return
        }
        if !validateCurrencyWithAccount() {
            showCurrencyNotSupportAlter()
            return
        }
        let currency = selectedCurrency
        var data = AccountBookData(id:updateRecord!.id,dateStr: dateStr, gmtCreated:updateRecord!.gmtCreated, type: payType, money: money, iconStr: iconStr, title: title, desc: desc, assetRecordId: updateRecord!.assetRecordId, accountId: selectedAccountId, currency: currency)
        do {
            // 账户联动：账户变化回滚旧账户并新建；账户不变且有关联则更新账户金额
            let old = updateRecord!
            let amountCents = abs(SQLiteManager.cents(fromMoney: money))
            let signed = payType == 0 ? -amountCents : amountCents
            let changeType = payType == 0 ? AssetRecordChangeType.transferOut.rawValue : AssetRecordChangeType.transferIn.rawValue
            let bookName = globalModel.accountBook?.name ?? "账本"
            let typeName = payType == 0 ? "支出" : "收入"
            let remark = "\(bookName)·\(typeName)"

            if old.accountId != selectedAccountId {
                // 账户变化：回滚旧账户记录，在新账户建记录
                if !old.assetRecordId.isEmpty {
                    try? AssetAccountRecordOfCacheService.deleteRecord(recordId: old.assetRecordId, cache: globalModel)
                }
                if !selectedAccountId.isEmpty {
                    data.assetRecordId = try AssetAccountRecordOfCacheService.addRecord(
                        accountId: selectedAccountId, changeType: changeType,
                        signedMoneyCents: signed, money: money, remark: remark, currency: currency, cache: globalModel)
                } else {
                    data.assetRecordId = ""
                }
            } else if !old.assetRecordId.isEmpty {
                // 账户不变：更新账户记录金额（差异自动同步余额）
                try AssetAccountRecordOfCacheService.updateRecordAmount(
                    recordId: old.assetRecordId, newSignedMoneyCents: signed, money: money, cache: globalModel)
            }
            try AccountBookDataOfCacheService.updateData(globalModel.accountBook!.id.description, oldData: old, newData: data, cache: globalModel)
            newRecordUpdate(data)
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "更新记录失败，您可以退出程序重试"
            alterConfig.showCancelButton = true
            alterConfig.cancalButtonName="取消"
            alterConfig.sureButtonName = "重试"
            alterConfig.sureFun = updateData
            showAlter = true
        }
    }
    
    /**
     添加记录
     */
    func addData() {
        if nil == globalModel.accountBook {
            showLoadAccountBookInfoError()
            return
        }
        if !validateCurrencyWithAccount() {
            showCurrencyNotSupportAlter()
            return
        }
        let currency = selectedCurrency
        var data = AccountBookData(dateStr: dateStr, type: payType, money: money, iconStr: iconStr, title: title, desc: desc, accountId: selectedAccountId, currency: currency)
        do {
            // 联动资产账户：支出减少、收入增加，并在账户记录备注账本与类型
            if !selectedAccountId.isEmpty {
                let amountCents = abs(SQLiteManager.cents(fromMoney: money))
                let signed = payType == 0 ? -amountCents : amountCents
                let changeType = payType == 0 ? AssetRecordChangeType.transferOut.rawValue : AssetRecordChangeType.transferIn.rawValue
                let bookName = globalModel.accountBook?.name ?? "账本"
                let typeName = payType == 0 ? "支出" : "收入"
                let remark = "\(bookName)·\(typeName)"
                let recordId = try AssetAccountRecordOfCacheService.addRecord(
                    accountId: selectedAccountId, changeType: changeType,
                    signedMoneyCents: signed, money: money, remark: remark, currency: currency, cache: globalModel)
                data.assetRecordId = recordId
            }
            try AccountBookDataOfCacheService.addData(globalModel.accountBook!.id.description, data: data, cache: globalModel)
            newRecordUpdate(data)
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "添加记录失败，您可以退出程序重试"
            alterConfig.showCancelButton = true
            alterConfig.cancalButtonName="取消"
            alterConfig.sureButtonName = "重试"
            alterConfig.sureFun = addData
            showAlter = true
        }
    }
    
    
    /**
     加载账本信息
     */
    func loadAccountBookInfo() {
        if (nil != globalModel.accountBook) {
            do {
                let seting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
                accountBookSeting = seting
                if (nil != seting) {
                    outRecordIcons = seting!.outRecordIconSeting
                    if (outRecordIcons.count > 0) {
                        iconStr = outRecordIcons[0].iconStr
                        title = outRecordIcons[0].name
                    }
                }
            } catch {
                showLoadAccountBookInfoError()
            }
            
        } else {
            showLoadAccountBookInfoError()
        }
    }
    
    func showLoadAccountBookInfoError () {
        alterConfig.showCancelButton = false
        alterConfig.desc = "加载账本信息失败，无法进行后续操作"
        alterConfig.sureButtonName = "重试"
        alterConfig.sureFun = loadAccountBookInfo
        showAlter = true
    }
    
    // dataStr(yyyyMMdd)转换为（yyyy-MM-dd）
    func trans2KeyDateStrFormat(_ dateStr:String?) -> String{
        if nil == dateStr {
            if listType == 1 {
                if nil == selectDate {
                    return "今天"
                }
                let nowDateStr = DateUtils.transDate2String(Date(), format: "yyyy-MM-dd");
                let selectDateStr = DateUtils.transDate2String(selectDate!, format: "yyyy-MM-dd")
                if selectDateStr > nowDateStr {
                    return "今天"
                } else {
                    return selectDateStr;
                }
            } else {
                return "今天"
            }
        }
        var tempValue = dateStr!
        tempValue.insert(contentsOf: "-", at: tempValue.index(tempValue.startIndex, offsetBy: 4))
        tempValue.insert(contentsOf: "-", at: tempValue.index(tempValue.startIndex, offsetBy: 7))
        let nowDateStr = DateUtils.transDate2String(Date(), format: "yyyy-MM-dd")
        if tempValue == nowDateStr {
            return "今天"
        }
        return tempValue
    }
}


