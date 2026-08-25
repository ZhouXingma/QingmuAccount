//
//  AccountBookStatisticComponent.swift
//  QingmuAccount
//  统计（多币种）：按月/年、支出/收入；合计与趋势图按币种分开；分类可按金额（区分币种）或笔数。
//  Created by 周荥马 on 2022/12/19.
//

import SwiftUI
import Combine

struct AccountBookStatisticComponent : View {
    @EnvironmentObject var globalModel:GlobalModel

    // 外部传入的初始值
    var initYear: Int? = nil
    var initMonth: Int? = nil
    var initDateType: Int? = nil  // 0=月度, 1=年度
    var initBookId: String? = nil  // 目标账本ID

    // 查询数据的时间维度，年/月
    @State private var selectStaticDateType:Int = 0
    // 需要查询的年/月
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    @State private var month:Int =  DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 查询数据的支收维度，0:支出，1:收入
    @State private var expendIncomeType:Int = 0
    // 日期选择
    @State private var showDatePickerTime:Bool = false
    @State private var showDatePickerType:DatePickerType = .YM
    @State private var datePickerDateValue:DatePickerValue = DatePickerValue()

    // 统计结果
    @State private var totalCount:Int = 0
    // 每币种总金额 [currency:Decimal]
    @State private var totalByCurrency:[String:Decimal] = [:]
    // 折线图每币种序列 [currency:[Double]]
    @State private var chartSeries:[String:[Double]] = [:]
    // 有数据的币种（CNY 优先）
    @State private var chartCurrencies:[String] = []
    // 折线图当前启用的币种
    @State private var enabledCurrencies:Set<String> = []
    // 分类统计（金额模式）
    @State private var categoryAmountList:[CategoryAmountItem] = []
    // 分类统计（笔数模式）
    @State private var categoryCountList:[CategoryCountItem] = []
    // 分类模式 0=金额 1=笔数
    @State private var categoryMode:Int = 0
    // 金额模式分类排序选中的币种（空串=未选，默认取首个币种）
    @State private var categoryAmountCurrency:String = ""

    // 详情
    @State private var showDetail = false
    @StateObject var showDetailData:ExpendIncomeDetailData = ExpendIncomeDetailData()

    // 折线图颜色
    private let chartColorPalette:[Color] = [
        Color("DefaultButtonBackgroud"), Color.blue, Color.orange, Color.purple, Color.pink, Color.teal
    ]

    var body: some View {
        ZStack {
            Color("ViewBackgroundColor").ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeaderComponent()
                topMenu
                    .padding(.top, 12)
                VStack(spacing: 0) {
                    headerRow
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            sumCard
                            chartCard
                            categoryCard
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 30)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .selfDatePicker(showState: $showDatePickerTime, type: $showDatePickerType, param: $datePickerDateValue) { value in
            self.datePickerDateValue = value
            self.year = value.year ?? self.year
            self.month = value.month ?? self.month
            computeAndShow()
        }
        .sheet(isPresented: $showDetail) {
            AccountBookStatisticTitleConsumerDetail(showDetailData: showDetailData)
                .environmentObject(globalModel)
        }
        .onAppear() {
            if let y = initYear { year = y }
            if let m = initMonth { month = m }
            if let t = initDateType { selectStaticDateType = t }
            computeAndShow()
        }
    }

    // MARK: - 顶部菜单

    var topMenu: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("DefaultButtonBackgroud"))
                .frame(width: 150, height: 30)
                .offset(x: selectStaticDateType == 0 ? -75 : 75)
                .animation(.easeInOut(duration: 0.2), value: selectStaticDateType)
            HStack {
                topMenuItem(0, "月")
                topMenuItem(1, "年")
            }
        }
        .frame(width: 300, height: 30)
        .padding(3)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
    }

    func topMenuItem(_ code:Int, _ title:String) -> some View {
        Text(title)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 30)
            .foregroundColor(selectStaticDateType == code ? .white : .secondary)
            .font(.system(size: 14, weight: .bold))
            .contentShape(Rectangle())
            .onTapGesture {
                if selectStaticDateType != code {
                    selectStaticDateType = code
                    computeAndShow()
                }
            }
    }

    var headerRow: some View {
        HStack {
            HStack(spacing: 4) {
                if selectStaticDateType == 0 {
                    Text("\(String(year))年\(month)月")
                        .font(.system(size: 16, weight: .bold))
                        .onTapGesture {
                            showDatePickerType = .YM
                            showDatePickerTime = true
                            datePickerDateValue.year = year
                            datePickerDateValue.month = month
                        }
                } else {
                    Text("\(String(year))年")
                        .font(.system(size: 16, weight: .bold))
                        .onTapGesture {
                            showDatePickerType = .Y
                            showDatePickerTime = true
                            datePickerDateValue.year = year
                        }
                }
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
            }
            Spacer()
            HStack {
                typeButton("支出", 0)
                typeButton("收入", 1)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 40)
    }

    func typeButton(_ title:String, _ type:Int) -> some View {
        Text(title)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(expendIncomeType == type ? Color("DefaultButtonBackgroud") : .secondary)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color("DefaultButtonBackgroud").opacity(expendIncomeType == type ? 1 : 0), style: .init(lineWidth: 2)))
            .onTapGesture {
                if expendIncomeType != type {
                    expendIncomeType = type
                    computeAndShow()
                }
            }
    }

    // MARK: - 合计卡

    var sumCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("共\(expendIncomeType == 0 ? "支出" : "收入")\(totalCount)笔")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Image(systemName: expendIncomeType == 0 ? "arrow.up.right" : "arrow.down.left")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }
            if totalByCurrency.isEmpty {
                Text("暂无数据")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            } else {
                let currencies = sortCurrencies(Set(totalByCurrency.keys))
                // 每行最多 2 个，奇数个时最后一项独占一行并铺满整行
                let rows = stride(from: 0, to: currencies.count, by: 2).map {
                    Array(currencies[$0..<min($0 + 2, currencies.count)])
                }
                VStack(spacing: 10) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { currency in
                                currencyTile(currency)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(heroGradient, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("MainShadowColor").opacity(0.12), radius: 10, x: 0, y: 4)
    }

    func currencyTile(_ currency:String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(AssetCurrency.symbol(of: currency))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(AssetCurrency.name(of: currency))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            Text("\(AssetCurrency.symbol(of: currency))\(DecimalUtils.trans2StringOfCurrency(totalByCurrency[currency] ?? 0))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }

    var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color("DefaultButtonBackgroud"), Color("DefaultButtonBackgroud").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - 趋势图

    var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("趋势")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            if !chartCurrencies.isEmpty {
                chartCurrencyChips
            }
            MultiScrollChartLine(
                data: scrollChartData,
                style: MultiScrollChartStyle(
                    xAxisMinSpace: 44,
                    yAxisSep: 5,
                    smoothness: 1.0,
                    showYLines: true
                ),
                chartHeight: 270
            )
            .frame(maxWidth: .infinity)
            HStack(spacing: 4) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text("长按图表查看每日/每月各币种金额")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(16)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.08), lineWidth: 1)
        }
    }

    // 折线图数据（启用的币种，每个币种一条线）
    var scrollChartData: MultiScrollChartLineData {
        let enabled = chartCurrencies.filter { enabledCurrencies.contains($0) }
        let labels = chartXLabels
        let points = labels.enumerated().map { (idx, label) in
            MultiScrollChartDataPoint(
                label: label,
                values: enabled.map { currency in
                    Double?(chartSeries[currency]?[idx] ?? 0)
                }
            )
        }
        let styles = enabled.enumerated().map { (idx, currency) in
            let color = chartColorPalette[idx % chartColorPalette.count]
            return MultiScrollChartLineStyle(
                name: AssetCurrency.name(of: currency),
                lineColor: [color, color.opacity(0.85)],
                gradientColors: [color.opacity(0.18), color.opacity(0.02)],
                pointColor: color,
                showPointCircle: false,
                showAverageLine: false
            )
        }
        return MultiScrollChartLineData(points: points, lineStyle: styles)
    }

    var chartXLabels: [String] {
        if selectStaticDateType == 0 {
            let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
            return (1...dayLength).map { "\($0)" }
        }
        return (1...12).map { "\($0)" }
    }

    var chartCurrencyChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chartCurrencies, id:\.self) { currency in
                    chartCurrencyChip(currency)
                }
            }
            .padding(.vertical, 2)
        }
    }

    func chartCurrencyChip(_ currency:String) -> some View {
        let on = enabledCurrencies.contains(currency)
        return Text(AssetCurrency.name(of: currency))
            .font(.system(size: 12, weight: on ? .bold : .medium))
            .foregroundColor(on ? .white : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Capsule().fill(on ? colorFor(currency) : Color("MainBackgroundColor")))
            .overlay(Capsule().stroke(Color("MainShadowColor").opacity(0.1), lineWidth: on ? 0 : 1))
            .contentShape(Capsule())
            .onTapGesture {
                toggleCurrency(currency)
            }
    }

    func colorFor(_ currency:String) -> Color {
        let idx = chartCurrencies.firstIndex(of: currency) ?? 0
        return chartColorPalette[idx % chartColorPalette.count]
    }

    func toggleCurrency(_ currency:String) {
        if enabledCurrencies.contains(currency) {
            enabledCurrencies.remove(currency)
        } else {
            enabledCurrencies.insert(currency)
        }
    }

    // MARK: - 分类统计

    var categoryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("分类统计")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                HStack(spacing: 0) {
                    categoryModeButton(0, "金额")
                    categoryModeButton(1, "笔数")
                }
                .padding(3)
                .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 8))
            }
            if categoryMode == 0 && categoryAmountCurrencies.count > 1 {
                categoryAmountCurrencyChips
            }
            if categoryMode == 0 {
                if categoryAmountList.isEmpty {
                    emptyCategory
                } else {
                    categoryPieChart(amountMode: true)
                    VStack(spacing: 8) {
                        ForEach(categoryAmountList) { item in
                            amountCategoryRow(item)
                        }
                    }
                }
            } else {
                if categoryCountList.isEmpty {
                    emptyCategory
                } else {
                    categoryPieChart(amountMode: false)
                    VStack(spacing: 8) {
                        ForEach(categoryCountList) { item in
                            countCategoryRow(item)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.08), lineWidth: 1)
        }
    }

    func categoryModeButton(_ code:Int, _ title:String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: categoryMode == code ? .bold : .regular))
            .foregroundColor(categoryMode == code ? .white : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(categoryMode == code ? Color("DefaultButtonBackgroud") : Color.clear, in: RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
            .onTapGesture {
                categoryMode = code
            }
    }

    // 金额模式分类中出现的币种（去重，CNY 优先）
    var categoryAmountCurrencies: [String] {
        var set = Set<String>()
        for item in categoryAmountList {
            for v in item.values {
                set.insert(v.currency)
            }
        }
        return sortCurrencies(set)
    }

    var categoryAmountCurrencyChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categoryAmountCurrencies, id:\.self) { currency in
                    categoryAmountCurrencyChip(currency)
                }
            }
            .padding(.vertical, 2)
        }
    }

    func categoryAmountCurrencyChip(_ currency:String) -> some View {
        let on = categoryAmountCurrency == currency
        return Text(AssetCurrency.name(of: currency))
            .font(.system(size: 12, weight: on ? .bold : .medium))
            .foregroundColor(on ? .white : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Capsule().fill(on ? colorFor(currency) : Color("MainBackgroundColor")))
            .overlay(Capsule().stroke(Color("MainShadowColor").opacity(0.1), lineWidth: on ? 0 : 1))
            .contentShape(Capsule())
            .onTapGesture {
                if categoryAmountCurrency != currency {
                    categoryAmountCurrency = currency
                    resortAmountList()
                }
            }
    }

    // 金额模式按选中的币种金额降序重排
    func resortAmountList() {
        let currency = categoryAmountCurrency
        categoryAmountList.sort { a, b in
            let av = a.values.first { $0.currency == currency }?.value ?? 0
            let bv = b.values.first { $0.currency == currency }?.value ?? 0
            if av != bv { return av > bv }
            return a.totalCount > b.totalCount
        }
    }

    // MARK: - 分类饼图

    // 金额模式：按选中币种各类消费金额占比；笔数模式：按各分类笔数占比
    func categoryPieData(amountMode: Bool) -> [PieData] {
        if amountMode {
            let currency = categoryAmountCurrency
            return categoryAmountList.compactMap { item -> PieData? in
                let value = item.values.first { $0.currency == currency }?.value ?? 0
                guard value > 0 else { return nil }
                return PieData(itemName: item.title, itemValue: value.doubleValue)
            }
        }
        return categoryCountList.map { PieData(itemName: $0.title, itemValue: Double($0.count)) }
    }

    @ViewBuilder
    func categoryPieChart(amountMode: Bool) -> some View {
        let data = categoryPieData(amountMode: amountMode)
        if !data.isEmpty {
            Pie(peiDataList: data, radius: 70, pieWidth: 24, specifier: amountMode ? "%.2f" : "%.0f")
                .id("\(categoryMode)-\(categoryAmountCurrency)-\(data.count)")
                .frame(width: 180, height: 180)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
    }

    var emptyCategory: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 30))
                .foregroundColor(.secondary.opacity(0.4))
            Text("暂无分类数据")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    // 金额模式：每个分类展示各币种金额与占比
    func amountCategoryRow(_ item:CategoryAmountItem) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(hexStr2Unicode(item.iconStr))
                    .font(.custom("icomoon", size: 20))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .frame(width: 32, height: 32)
                    .background(Color("DefaultButtonBackgroud").opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(item.totalCount)笔")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            ForEach(item.values) { cv in
                let total = totalByCurrency[cv.currency] ?? 0
                let pct = total > 0 ? Double(truncating: (cv.value / total) as NSNumber) : 0
                HStack(spacing: 8) {
                    Text(AssetCurrency.name(of: cv.currency))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(colorFor(cv.currency))
                        .frame(width: 46, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    GeometryReader { reader in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color("MainShadowColor").opacity(0.12))
                            Capsule().fill(colorFor(cv.currency))
                                .frame(width: reader.size.width * CGFloat(min(max(pct, 0), 1)))
                        }
                    }.frame(height: 6)
                    Text("\(amountText(cv.currency, cv.value))")
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("\(Int(pct * 100))%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 38, alignment: .trailing)
                }
            }
        }
        .padding(12)
        .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .onTapGesture {
            openCategoryDetail(title: item.title, iconStr: item.iconStr, count: item.totalCount, list: item.list)
        }
    }

    // 笔数模式：仅按记录数统计
    func countCategoryRow(_ item:CategoryCountItem) -> some View {
        let pct = totalCount > 0 ? CGFloat(item.count) / CGFloat(totalCount) : 0
        return HStack(spacing: 10) {
            Text(hexStr2Unicode(item.iconStr))
                .font(.custom("icomoon", size: 20))
                .foregroundColor(Color("DefaultButtonBackgroud"))
                .frame(width: 32, height: 32)
                .background(Color("DefaultButtonBackgroud").opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            Text(item.title)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
            Spacer()
            GeometryReader { reader in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("MainShadowColor").opacity(0.12))
                    Capsule().fill(Color("DefaultButtonBackgroud"))
                        .frame(width: reader.size.width * min(max(pct, 0), 1))
                }
            }.frame(height: 6)
                .frame(maxWidth: 90)
            Text("\(item.count)笔")
                .font(.system(size: 13, weight: .bold))
        }
        .padding(12)
        .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .onTapGesture {
            openCategoryDetail(title: item.title, iconStr: item.iconStr, count: item.count, list: item.list)
        }
    }

    func openCategoryDetail(title:String, iconStr:String, count:Int, list:[AccountBookData]) {
        showDetailData.data = ExpendIncomeTitleData(title: title, iconStr: iconStr, value: 0, count: count, list: list)
        showDetail = true
    }

    // MARK: - 数据计算

    func computeAndShow() {
        let bookId = initBookId ?? globalModel.accountBook?.id.description
        guard let bookId = bookId else { return }
        guard let yearData = try? AccountBookDataService.readData(bookId, year: year) else {
            resetAll()
            return
        }
        let ymStr = ymStrOf(year, month)
        let type = expendIncomeType
        var totalByCur:[String:Decimal] = [:]
        var countByCur:[String:Int] = [:]
        var perDay:[String:[String:Decimal]] = [:]
        var perMonth:[String:[String:Decimal]] = [:]
        var catAmount:[String:[String:(Decimal, Int)]] = [:]
        var catAmountIcon:[String:String] = [:]
        var catCount:[String:(String, Int, [AccountBookData])] = [:]

        for (ym, records) in yearData.data {
            if selectStaticDateType == 0 && ym != ymStr {
                continue
            }
            for record in records where record.type == type {
                let currency = record.currency.isEmpty ? "CNY" : record.currency
                let value = Decimal(string: record.money) ?? 0
                totalByCur[currency, default: 0] += value
                countByCur[currency, default: 0] += 1
                if selectStaticDateType == 0 {
                    perDay[currency, default: [:]][record.dateStr, default: 0] += value
                } else {
                    perMonth[currency, default: [:]][ym, default: 0] += value
                }
                var curMap = catAmount[record.title] ?? [:]
                let (v, n) = curMap[currency] ?? (0, 0)
                curMap[currency] = (v + value, n + 1)
                catAmount[record.title] = curMap
                catAmountIcon[record.title] = record.iconStr
                var cc = catCount[record.title] ?? (record.iconStr, 0, [])
                cc.1 += 1
                cc.2.append(record)
                catCount[record.title] = cc
            }
        }

        totalCount = countByCur.values.reduce(0, +)
        totalByCurrency = totalByCur
        let sorted = sortCurrencies(Set(totalByCur.keys))
        chartCurrencies = sorted

        // 折线图序列
        var series:[String:[Double]] = [:]
        if selectStaticDateType == 0 {
            let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
            let monthStr = month < 10 ? "0\(month)" : "\(month)"
            for currency in sorted {
                var values:[Double] = []
                for day in 1...dayLength {
                    let dayStr = day < 10 ? "0\(day)" : "\(day)"
                    let ymd = "\(year)\(monthStr)\(dayStr)"
                    values.append((perDay[currency]?[ymd] ?? 0).doubleValue)
                }
                series[currency] = values
            }
        } else {
            for currency in sorted {
                var values:[Double] = []
                for m in 1...12 {
                    let mStr = m < 10 ? "0\(m)" : "\(m)"
                    let ym = "\(year)\(mStr)"
                    values.append((perMonth[currency]?[ym] ?? 0).doubleValue)
                }
                series[currency] = values
            }
        }
        chartSeries = series

        // 分类（金额模式）
        var amountList:[CategoryAmountItem] = []
        for (title, curMap) in catAmount {
            var values:[CategoryCurrencyValue] = []
            for currency in sortCurrencies(Set(curMap.keys)) {
                if let (v, n) = curMap[currency] {
                    values.append(CategoryCurrencyValue(currency: currency, value: v, count: n))
                }
            }
            amountList.append(CategoryAmountItem(
                title: title,
                iconStr: catAmountIcon[title] ?? "",
                values: values,
                list: catCount[title]?.2 ?? []
            ))
        }
        // 金额模式排序币种：默认选中首个（CNY 优先），失效时重置
        if categoryAmountCurrency.isEmpty || !sorted.contains(categoryAmountCurrency) {
            categoryAmountCurrency = sorted.first ?? ""
        }
        categoryAmountList = amountList
        resortAmountList()

        // 分类（笔数模式）
        var countList:[CategoryCountItem] = []
        for (title, cc) in catCount {
            countList.append(CategoryCountItem(title: title, iconStr: cc.0, count: cc.1, list: cc.2))
        }
        countList.sort { $0.count > $1.count }
        categoryCountList = countList

        // 折线图启用的币种：保留用户选择；首次无选择时默认启用前 4 个
        var enabled = enabledCurrencies.intersection(Set(sorted))
        if enabled.isEmpty {
            for currency in sorted {
                if enabled.count >= 4 { break }
                enabled.insert(currency)
            }
        }
        enabledCurrencies = enabled
    }

    func resetAll() {
        totalCount = 0
        totalByCurrency = [:]
        chartSeries = [:]
        chartCurrencies = []
        enabledCurrencies = []
        categoryAmountList = []
        categoryCountList = []
    }

    func sortCurrencies(_ set:Set<String>) -> [String] {
        return set.sorted { a, b in
            if a == "CNY" { return true }
            if b == "CNY" { return false }
            return a < b
        }
    }

    func ymStrOf(_ y:Int, _ m:Int) -> String {
        let monthStr = m < 10 ? String("0\(m)") : String("\(m)")
        return String("\(y)\(monthStr)")
    }

    func amountText(_ currency:String, _ value:Decimal) -> String {
        return "\(AssetCurrency.symbol(of: currency))\(DecimalUtils.trans2StringOfCurrency(value))"
    }
}

// MARK: - 分类数据模型

struct CategoryCurrencyValue: Identifiable {
    var id: String { currency }
    let currency: String
    let value: Decimal
    let count: Int
}

struct CategoryAmountItem: Identifiable {
    var id: String { title }
    let title: String
    let iconStr: String
    let values: [CategoryCurrencyValue]
    let list: [AccountBookData]
    var totalCount: Int { values.reduce(0) { $0 + $1.count } }
}

struct CategoryCountItem: Identifiable {
    var id: String { title }
    let title: String
    let iconStr: String
    let count: Int
    let list: [AccountBookData]
}
