//
//  AccountBookStatisticTitleConsumerDetail.swift
//  QingmuAccount
//  单个类别的消费详情（与首页账本列表展示一致：按日分组，账户·币型右上角）
//  Created by 周荥马 on 2024/1/13.
//

import SwiftUI

struct AccountBookStatisticTitleConsumerDetail: View {
    @EnvironmentObject var globalModel: GlobalModel
    @ObservedObject var showDetailData: ExpendIncomeDetailData
    // 按日分组 [dateStr: [record]]
    @State private var dayGroups: [(dateStr: String, records: [AccountBookData])] = []
    @State private var assetAccounts: [AssetAccountModel] = []

    var body: some View {
        VStack {
            HStack {
                Text("\"\(showDetailData.data!.title)\"收支详情")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("FontColor"))
            }.padding(.bottom, 10)
            HStack {
                Text("共\(showDetailData.data!.count.description)笔")
            }.font(.system(size: 16, weight: .bold))
            ScrollView(showsIndicators: false) {
                ForEach(dayGroups, id: \.dateStr) { group in
                    daySection(group.dateStr, records: group.records)
                }
            }
        }.padding(.top, 20)
            .padding(.horizontal, 20)
            .background(Color("ViewBackgroundColor"))
            .onAppear() {
                initList()
            }
    }

    // 按日分组的列表区块（与首页一致）
    func daySection(_ dateStr: String, records: [AccountBookData]) -> some View {
        VStack {
            HStack {
                Text(trans2ListDateInfo(dateStr))
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .bold))
                Spacer()
            }.padding(.horizontal, 10)
            VStack(alignment: .center, spacing: 5) {
                ForEach(records, id: \.self) { record in
                    recordRow(record)
                }
            }
        }.padding(.bottom, 20)
    }

    // 单条记录（与首页 recordDayListItem 一致：账户·币型右上角）
    func recordRow(_ record: AccountBookData) -> some View {
        HStack {
            Text(hexStr2Unicode(record.iconStr))
                .font(.custom("icomoon", size: 25))
                .foregroundColor(Color("DefaultButtonBackgroud"))
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(record.title)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.bottom, 2)
                if StringUtils.trimCount(record.desc) > 0 {
                    Text(record.desc)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(record.type == 0 ? "-\(record.money)" : "\(record.money)")
                .font(.system(size: 15, weight: .bold))
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.horizontal, 10)
        .frame(height: 60)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .topTrailing) {
            // 账户 · 币型
            Text(accountCurrencyText(record))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.trailing, 10)
                .padding(.top, 4)
        }
    }

    // 记录显示用的账户 + 币型文本（如「招商银行 · 人民币」）
    func accountCurrencyText(_ record: AccountBookData) -> String {
        let name = assetAccounts.first { $0.id.uuidString == record.accountId }?.name ?? ""
        let currency = record.currency.isEmpty ? "CNY" : record.currency
        if name.isEmpty {
            return AssetCurrency.name(of: currency)
        }
        return "\(name) · \(AssetCurrency.name(of: currency))"
    }

    // 日期显示（与首页一致：X月X日 星期X）
    func trans2ListDateInfo(_ dateStr: String) -> String {
        let date = DateUtils.transString2Date(dateStr, format: "yyyyMMdd")!
        let components = DateUtils.findComponentsOfDate([.month, .day, .weekday], date: date)
        return String("\(components.month!)月\(components.day!)日 星期\(DateUtils.transWeekDat2ChineseString(components.weekday!))")
    }

    func initList() {
        if showDetailData.data!.list.count <= 0 {
            return
        }
        let sorted = showDetailData.data!.list.sorted(by: { $0.dateStr > $1.dateStr })
        // 按日期分组
        var groups: [(dateStr: String, records: [AccountBookData])] = []
        var currentDate = ""
        var currentRecords: [AccountBookData] = []
        for record in sorted {
            if record.dateStr != currentDate {
                if !currentRecords.isEmpty {
                    groups.append((currentDate, currentRecords))
                }
                currentDate = record.dateStr
                currentRecords = []
            }
            currentRecords.append(record)
        }
        if !currentRecords.isEmpty {
            groups.append((currentDate, currentRecords))
        }
        dayGroups = groups
        if let accounts = try? AssetAccountOfCacheService.getAccounts(cache: globalModel) {
            assetAccounts = accounts
        }
    }
}

struct AccountBookStatisticTitleConsumerDetail_Previews: PreviewProvider {

    static var previews: some View {
        var showDetailData: ExpendIncomeDetailData = ExpendIncomeDetailData(data: ExpendIncomeTitleData(title: "早餐", iconStr: "ed4b", value: 200.0, count: 1, list: [AccountBookData(version: "1.0", dateStr: "20230112", type: 0, money: "52", iconStr: "ed4b", title: "早餐", desc: "备注信息"), AccountBookData(version: "1.0", dateStr: "20230111", type: 0, money: "52", iconStr: "ed4b", title: "早餐", desc: "备注信息")]))

        AccountBookStatisticTitleConsumerDetail(showDetailData: showDetailData)
    }
}
