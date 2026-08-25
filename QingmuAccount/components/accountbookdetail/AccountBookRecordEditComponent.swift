//
//  AccountBookRecordEditComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/11.
//

import SwiftUI

struct AccountBookRecordEditComponent : View {
    // 环境
    @EnvironmentObject var globalModel:GlobalModel
    // 用于关闭当前窗口
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 账本的记录信息
    @State var accountBookData: AccountBookData
    // 是否开启更新数据
    @State var updateData = false
    // 是否有数据进行编辑，删除或者修改
    @State var newRecordUpdate:(AccountBookData) -> Void = {_ in }
    // 显示提醒
    @State var showAlter = false
    @State var alterConfig = AlertComponentConfig(desc: "确定删除该记录吗？")
    @State var listType = 0;
    @State var selectDate:Date? = nil;
    // 资产账户（用于显示账户名）
    @State var assetAccounts:[AssetAccountModel] = [];

    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderComponent(title: "账单详情")
            billHeader
                .padding(.horizontal, 20)
                .padding(.top, 12)
            detailCard
                .padding(.horizontal, 20)
                .padding(.top, 16)
            Spacer()
            bottomBar
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .background(Color("ViewBackgroundColor"))
            .sheet(isPresented: $updateData) {
                AccountBookAddRecordComponent(newRecordUpdate: haveEditRecord,  updateRecord: accountBookData, listType: $listType, selectDate: $selectDate)
            }
            .onAppear() {
                do {
                    assetAccounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
                } catch {
                    assetAccounts = []
                }
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
    }
    // 账单头部：图标 + 标题/类型 + 金额 + 日期（紧凑布局）
    var billHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Text(hexStr2Unicode(accountBookData.iconStr))
                    .font(.custom("icomoon", size: 30))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 4) {
                    Text(accountBookData.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(accountBookData.type == 0 ? "支出" : "收入")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(billMoneyText())
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            HStack {
                Text(billDateInfo())
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: headerGradientColors(),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(color: Color("MainShadowColor").opacity(0.18), radius: 10, x: 0, y: 6)
    }
    // 详情卡片：账户 / 币型 / 创建时间 / 修改时间 / 备注
    var detailCard: some View {
        VStack(spacing: 0) {
            detailRow("账户", accountNameText())
            detailDivider()
            detailRow("币型", currencyDisplayText)
            detailDivider()
            detailRow("创建时间", DateUtils.transDate2String(accountBookData.gmtCreated, format: "yyyy-MM-dd HH:mm"))
            detailDivider()
            detailRow("修改时间", DateUtils.transDate2String(accountBookData.gmtModfied, format: "yyyy-MM-dd HH:mm"))
            if StringUtils.trimCount(accountBookData.desc) > 0 {
                detailDivider()
                detailRow("备注", accountBookData.desc)
            }
        }.padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 6, x: 0, y: 3)
    }
    // 详情一行：标签 + 值
    func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("FontColor"))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }.padding(.vertical, 12)
    }
    // 详情分隔线
    func detailDivider() -> some View {
        Rectangle()
            .fill(Color("MainShadowColor").opacity(0.08))
            .frame(height: 0.8)
    }
    // 底部操作行：删除（左）+ 编辑（右）
    var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                keyFeedback()
                deleteRecordAlter()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .bold))
                    Text("删除")
                        .font(.system(size: 15, weight: .bold))
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
                updateData = true
            } label: {
                Text("编辑")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color("MainShadowColor").opacity(0.25), radius: 6, x: 0, y: 3)
            }
        }.padding(.horizontal, 20)
            .padding(.bottom, 24)
    }
    // 有内容进行编辑
    func haveEditRecord(_ changeAccountBookData: AccountBookData) {
        accountBookData = changeAccountBookData
        newRecordUpdate(changeAccountBookData)
    }
    // 删除记录提醒
    func deleteRecordAlter() {
        alterConfig.title = "删除提醒"
        alterConfig.desc = "确定删除该记录吗？删除后无法恢复！"
        alterConfig.sureButtonName = "删除"
        alterConfig.topBarColorStyle = .RED
        alterConfig.sureFun = deleteRecord
        showAlter = true
    }
    // 删除记录真正的操作
    func deleteRecord() {
        do {
            try AccountBookDataOfCacheService.deleteData(globalModel.accountBook!.id.description, data: accountBookData, cache: globalModel)
            newRecordUpdate(accountBookData)
            presentationMode.wrappedValue.dismiss()
        } catch {

        }
    }

    // 日期格式转换：dataStr(yyyyMMdd)转换为（yyyy-MM-dd）
    func transDateStrFormat(_ dataStr:String) -> String{
        var tempValue = dataStr
        tempValue.insert(contentsOf: "-", at: dataStr.index(dataStr.startIndex, offsetBy: 4))
        tempValue.insert(contentsOf: "-", at: dataStr.index(dataStr.startIndex, offsetBy: 7))
        return tempValue
    }
    // 账单金额展示：支出带「-」，收入不带符号，不加币型标记
    func billMoneyText() -> String {
        let sign = accountBookData.type == 0 ? "-" : ""
        return "\(sign)\(accountBookData.money)"
    }
    // 账单日期展示：yyyy-MM-dd 星期X
    func billDateInfo() -> String {
        let date = DateUtils.transString2Date(accountBookData.dateStr, format: "yyyyMMdd") ?? Date()
        let components = DateUtils.findComponentsOfDate([.weekday], date: date)
        let weekday = DateUtils.transWeekDat2ChineseString(components.weekday ?? 1)
        return "\(transDateStrFormat(accountBookData.dateStr)) 星期\(weekday)"
    }
    // 账单头部渐变色：支出红、收入主题色
    func headerGradientColors() -> [Color] {
        if accountBookData.type == 0 {
            return [Color("RedColor"), Color("RedColor").opacity(0.72)]
        }
        return [Color("DefaultButtonBackgroud"), Color("DefaultButtonBackgroud").opacity(0.72)]
    }

    /// 记录对应的账户名称
    func accountNameText() -> String {
        if accountBookData.accountId.isEmpty {
            return "未设置"
        }
        return assetAccounts.first { $0.id.uuidString == accountBookData.accountId }?.name ?? ""
    }

    /// 币型显示：名称 + 编码，如「人民币 (CNY)」
    var currencyDisplayText: String {
        let currency = accountBookData.currency.isEmpty ? "CNY" : accountBookData.currency
        return "\(AssetCurrency.name(of: currency)) (\(currency))"
    }
}
