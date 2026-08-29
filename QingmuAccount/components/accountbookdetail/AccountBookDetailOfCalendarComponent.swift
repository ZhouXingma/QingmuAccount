//
//  AccountBookDetailOfCalendarComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/2.
//

import SwiftUI

/// 单个币种某月的收支统计（含选中日期的当日统计）
struct AccountBookCurrencyStats: Identifiable {
    var id: String { currency }
    let currency: String
    var monthIncome: Decimal = 0
    var monthExpense: Decimal = 0
    var dayIncome: Decimal = 0
    var dayExpense: Decimal = 0
    /// 当日支出 / 当月支出（0~1），当月无支出为 nil
    var dayExpensePercent: Double? {
        guard monthExpense > 0 else { return nil }
        return (dayExpense / monthExpense).doubleValue
    }
    /// 当日收入 / 当月收入（0~1），当月无收入为 nil
    var dayIncomePercent: Double? {
        guard monthIncome > 0 else { return nil }
        return (dayIncome / monthIncome).doubleValue
    }
}

struct AccountBookDetailOfCalendarComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    @State private var dayDatas:[AccountBookData] = []
    // 资产账户（用于显示记录对应的账户名）
    @State private var assetAccounts:[AssetAccountModel] = []
    // 列表滑动通知
    @StateObject var notifaction = SelfSwiperNotification()
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    @State private var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    @State private var selectDate:Date = Date()
    // 编辑记录
    @State var editRecord:Bool = false
    // 编辑的记录数据
    @State var editAccountBookData:AccountBookData? = nil
    // 最后加载时间
    @Binding var latestLoadTime:Date
    @Binding var calendarSelectDate:Date?
    // 日历当前显示币种（ISO 码）
    @State var selectedCurrency:String = ""
    // 本月各币种统计
    @State var monthCurrencyStats:[AccountBookCurrencyStats] = []
    // 本月有记录的币种（按 AssetCurrency 顺序）
    @State var monthCurrencies:[String] = []
    // 当前显示月份 yyyyMM
    @State private var currentShowYM:String = ""
    // 下方 tab：0=本月币种统计，1=流水（默认）
    @State private var currencyTabIndex:Int = 1

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // 顶部：币型切换 + 日历（随滚动离开）
                calendarHeaderView
                // 吸顶 tab 栏 + 内容
                Section {
                    tabContentView
                    Color.clear.frame(height: 80)
                } header: {
                    tabBarView
                }
            }
        }
        .sheet(isPresented: $editRecord, content: {
            AccountBookRecordEditComponent(accountBookData: editAccountBookData!, newRecordUpdate: { item in
                self.latestLoadTime = Date()
            }).environmentObject(globalModel)
        })
        .onChange(of: latestLoadTime, perform: { newValue in
            realoadDayDatas()
        })
        .onChange(of: globalModel.accountBook, perform: { newValue in
            // 推迟到下一个 RunLoop，避免重载时同步回写缓存状态（Publishing during view update）
            DispatchQueue.main.async {
                realoadDayDatas()
                // 切换账本后刷新日历数值与统计
                latestLoadTime = Date()
            }
        })
        .onChange(of: selectDate, perform: { newValue in
            calendarSelectDate = newValue
            realoadDayDatas()
            // 刷新选中日期的统计（当日部分）
            refreshCurrencyMonthStatsForSelectedDate()
        })
        .onAppear() {
            realoadDayDatas()
        }
    }
    // 顶部：币型切换 + 日历卡片
    var calendarHeaderView: some View {
        VStack(spacing: 0) {
            // 币种切换行：固定高度始终占位，避免切换月份时币型出现导致与日历互相遮盖
            currencySelectRow
            CalendarNewComponent(monthDataHandle:monthDataHandle, year:$year, month:$month, selectDate:$selectDate, latestLoadTime:$latestLoadTime)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 15)
        .padding(.bottom, 8)
    }
    // 币种切换行：固定高度始终占位，无币种时显示占位提示，切换月份用透明度过渡
    var currencySelectRow: some View {
        ZStack {
            if monthCurrencies.isEmpty {
                Text("本月暂无记录")
                    .font(.system(size: 12))
                    .foregroundColor(Color("FontColor").opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .transition(.opacity)
            } else {
                currencySelectView
                    .transition(.opacity)
            }
        }
        .frame(height: 44)
        .animation(.easeInOut(duration: 0.25), value: monthCurrencies)
    }
    // 吸顶 tab 栏
    var tabBarView: some View {
        HStack(spacing: 8) {
            tabBarItem("流水记录", index: 1)
            tabBarItem("币种统计", index: 0)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color("ViewBackgroundColor"))
    }
    // tab 单项
    func tabBarItem(_ title:String, index:Int) -> some View {
        let selected = currencyTabIndex == index
        return Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(selected ? .white : Color("FontColor").opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(selected ? Color("DefaultButtonBackgroud") : Color.clear, in: Capsule())
            .onTapGesture {
                if currencyTabIndex != index {
                    currencyTabIndex = index
                }
            }
    }
    // tab 内容
    @ViewBuilder
    var tabContentView: some View {
        if currencyTabIndex == 1 {
            // 流水记录（所有币种），行间距与列表模式保持一致
            VStack(spacing: 5) {
                ForEach(dayDatas.sorted(by: { item1, item2 in
                    (item1.dateStr as NSString).longLongValue >= (item2.dateStr as NSString).longLongValue
                }),id:\.self) { item in
                    recordDayListItem(item)
                }
            }
            .padding(.horizontal, 15)
        } else {
            // 本月币种统计
            currencyMonthStatsView
                .padding(.horizontal, 15)
        }
    }
    /*
     加载每日数据
     */
    func realoadDayDatas() {
        if nil == globalModel.accountBook {
            return
        }
        do {
            assetAccounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            let year = DateUtils.findComponentsOfDate([.year], date: self.selectDate).year!
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year:year, cache: globalModel)
            if let yearDataReal = yearData {
                // 计算展示出来
                self.dayDatas = findDatesValue(self.selectDate, yearDataReal)
            } else {
                self.dayDatas = []
            }
        } catch {
            
        }
    }
    
    /*
     月度数据
     */
    func monthDataHandle(calendarShowData: CalendarShowData) {
        if nil == globalModel.accountBook {
            return
        }
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: calendarShowData.show.year, cache: globalModel)
            if let yearDataReal = yearData {
                // 刷新本月币种统计
                refreshCurrencyMonthStats(yearDataReal, ymStr: DateUtils.ymStr(calendarShowData.show.year, calendarShowData.show.month))
                // 计算展示出来
                computerMonthDataHandleShow(calendarShowData, yearDataReal)
            }
        } catch {

        }
    }
    // 刷新本月各币种统计 + 币种列表 + 确保选中币种有效
    func refreshCurrencyMonthStats(_ yearDataReal:AccountBookYearData, ymStr:String) {
        currentShowYM = ymStr
        let dayYmd = DateUtils.transDate2String(selectDate, format: "yyyyMMdd")
        let stats = computerCurrencyMonthStats(ymStr, dayYmd, yearDataReal)
        monthCurrencyStats = stats
        monthCurrencies = stats.map { $0.currency }
        if !monthCurrencies.isEmpty && !monthCurrencies.contains(selectedCurrency) {
            let bookDefault = globalModel.accountBook?.defaultCurrency ?? ""
            selectedCurrency = monthCurrencies.contains(bookDefault) ? bookDefault : monthCurrencies.first!
        }
    }
    // 选中日期变化时仅刷新统计（当日部分），不重建日历
    func refreshCurrencyMonthStatsForSelectedDate() {
        if nil == globalModel.accountBook || currentShowYM.isEmpty || currentShowYM.count < 6 {
            return
        }
        guard let year = Int(String(currentShowYM.prefix(4))) else {
            return
        }
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: year, cache: globalModel)
            if let yearDataReal = yearData {
                refreshCurrencyMonthStats(yearDataReal, ymStr: currentShowYM)
            }
        } catch {

        }
    }
    // 计算月度标点符号显示
    func computerMonthDataHandleShow(_ calendarShowData: CalendarShowData, _ yearDataReal:AccountBookYearData) {
        calendarShowData.show.datas = calendarShowDateItemsShow(calendarShowData.show, yearDataReal)
        calendarShowData.pre.datas = calendarShowDateItemsShow(calendarShowData.pre, yearDataReal)
        calendarShowData.next.datas = calendarShowDateItemsShow(calendarShowData.next, yearDataReal)
    }
    
    func calendarShowDateItemsShow(_ calendarShowDateItems: CalendarShowDateItems, _ yearDataReal:AccountBookYearData) -> [CalendarDateModel] {
        let datas = calendarShowDateItems.datas
        let ymStr = DateUtils.ymStr(calendarShowDateItems.year, calendarShowDateItems.month)
        // ym - []
        let monthDatas = yearDataReal.data[ymStr] ?? []
        // ymd:[]
        var dayDatasMap:[String:[AccountBookData]] = [:]
        
        for item in monthDatas {
            var datas = dayDatasMap[item.dateStr] ?? []
            datas.append(item)
            dayDatasMap[item.dateStr] = datas
        }
        for dataItem in datas {
            let ymd = DateUtils.transDate2String(dataItem.day, format: "yyyyMMdd")
            let dayDatas = dayDatasMap[ymd]
            dataItem.mark = false
            // 切换币种或复用格子时，先清空金额
            dataItem.desc = " "
            if nil != dayDatas && dayDatas!.count > 0 {
                dataItem.mark = true
                // 只统计选中币种的记录
                let currencyDatas = dayDatas!.filter { ($0.currency.isEmpty ? "CNY" : $0.currency) == selectedCurrency }
                if currencyDatas.count > 0 {
                    let totalMoney:Decimal = currencyDatas.reduce(Decimal(0.0)) { partialResult, item in
                        var resultTemp = partialResult
                        if item.type == 0 {
                            // 支出
                            resultTemp = partialResult - (Decimal(string:item.money) ?? Decimal(0))
                        } else  if item.type == 1 {
                            resultTemp = partialResult + (Decimal(string:item.money) ?? Decimal(0))
                        }
                        return resultTemp
                    }
                    dataItem.desc = String("\(totalMoney)")
                }
            }
        }
        return datas
    }
    // 计算某月各币种的收支统计（含所选日期的当日统计）
    func computerCurrencyMonthStats(_ ymStr:String, _ dayYmd:String, _ yearData:AccountBookYearData) -> [AccountBookCurrencyStats] {
        let monthDatas = yearData.data[ymStr] ?? []
        var map:[String:AccountBookCurrencyStats] = [:]
        for item in monthDatas {
            let currency = item.currency.isEmpty ? "CNY" : item.currency
            var stat = map[currency] ?? AccountBookCurrencyStats(currency: currency)
            let value = Decimal(string:item.money) ?? Decimal(0)
            let isDay = item.dateStr == dayYmd
            if item.type == 0 {
                stat.monthExpense += value
                if isDay {
                    stat.dayExpense += value
                }
            } else if item.type == 1 {
                stat.monthIncome += value
                if isDay {
                    stat.dayIncome += value
                }
            }
            map[currency] = stat
        }
        // 按 AssetCurrency.allCases 顺序排序，未知币种排最后
        let order:[String:Int] = Dictionary(uniqueKeysWithValues: AssetCurrency.allCases.enumerated().map { ($0.element.rawValue, $0.offset) })
        return map.values.sorted { item1, item2 in
            let o1 = order[item1.currency] ?? Int.max
            let o2 = order[item2.currency] ?? Int.max
            if o1 != o2 { return o1 < o2 }
            return item1.currency < item2.currency
        }
    }
    // 本月币种切换视图
    var currencySelectView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(monthCurrencies, id:\.self) { code in
                    currencySelectChip(code)
                }
            }.padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
    }
    // 币种切换 chip
    func currencySelectChip(_ code:String) -> some View {
        let selected = code == selectedCurrency
        return HStack(spacing: 4) {
            Text(AssetCurrency.symbol(of: code)).font(.system(size: 12, weight: .bold))
            Text(AssetCurrency.name(of: code)).font(.system(size: 12, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(selected ? Color("DefaultButtonBackgroud") : Color.clear, in: Capsule())
        .foregroundColor(selected ? .white : Color("FontColor"))
        .overlay(Capsule().stroke(selected ? Color.clear : Color("FontColor").opacity(0.2), lineWidth: 1))
        .onTapGesture {
            if code != selectedCurrency {
                selectedCurrency = code
                // 复用现有刷新机制，重建日历并刷新统计
                latestLoadTime = Date()
            }
        }
    }
    // 币种统计视图
    var currencyMonthStatsView: some View {
        VStack(spacing: 10) {
            if monthCurrencyStats.isEmpty {
                // 空状态
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 26))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("本月暂无记录")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                HStack {
                    Text("币种统计").font(.system(size: 15, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 4)
                ForEach(monthCurrencyStats) { stat in
                    currencyMonthStatsRow(stat)
                }
            }
        }
    }
    // 币种统计卡片
    func currencyMonthStatsRow(_ stat:AccountBookCurrencyStats) -> some View {
        let selected = stat.currency == selectedCurrency
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(AssetCurrency.name(of: stat.currency)).font(.system(size: 15, weight: .bold))
                Text(AssetCurrency.symbol(of: stat.currency)).font(.system(size: 13)).foregroundColor(.secondary)
                Spacer()
                if selected {
                    Text("当前").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color("DefaultButtonBackgroud"), in: Capsule())
                }
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                currencyStatCell(title: "当月支出", value: currencyAmount(stat.currency, stat.monthExpense), income: false)
                currencyStatCell(title: "当月收入", value: currencyAmount(stat.currency, stat.monthIncome), income: true)
                currencyStatCell(title: "今日支出", value: currencyAmount(stat.currency, stat.dayExpense), income: false)
                currencyStatCell(title: "今日收入", value: currencyAmount(stat.currency, stat.dayIncome), income: true)
            }
            // 当日/当月 支出、收入占比条
            HStack(spacing: 12) {
                dayMonthRatioBar(title: "支出占比(当日/当月)", color: Color("RedColor"), percent: stat.dayExpensePercent)
                dayMonthRatioBar(title: "收入占比(当日/当月)", color: Color("DefaultButtonBackgroud"), percent: stat.dayIncomePercent)
            }
        }
        .padding(12)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(selected ? Color("DefaultButtonBackgroud").opacity(0.5) : Color("MainShadowColor").opacity(0.08), lineWidth: selected ? 1.5 : 1)
        }
    }
    // 币种统计单元格
    func currencyStatCell(title:String, value:String, income:Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(income ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 8))
    }
    // 金额带币种符号
    func currencyAmount(_ currency:String, _ value:Decimal) -> String {
        return "\(AssetCurrency.symbol(of: currency))\(DecimalUtils.trans2StringOfCurrency(value))"
    }
    // 当日/当月占比进度条
    func dayMonthRatioBar(title:String, color:Color, percent:Double?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                Text(ratioPercentText(percent))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("FontColor").opacity(0.12))
                    Capsule().fill(color)
                        .frame(width: geo.size.width * CGFloat(percent ?? 0))
                }
            }.frame(height: 6)
        }
    }
    // 当日/当月占比文本
    func ratioPercentText(_ percent:Double?) -> String {
        guard let percent = percent else { return "-" }
        return String(format: "%.1f%%", percent * 100)
    }

    // 查找日期的数据
    func findDatesValue(_ date:Date, _ yearDataReal:AccountBookYearData) -> [AccountBookData] {
        if (yearDataReal.data.count <= 0) {
            return []
        }
        let ymd = DateUtils.transDate2String(date, format: "yyyyMMdd")
        let ym = DateUtils.transDate2String(date, format: "yyyyMM")
        let accountBookDatas = yearDataReal.data[ym]
        var dayValues:[AccountBookData] = []
        if (nil != accountBookDatas) {
            for item in accountBookDatas! {
                if item.dateStr == ymd {
                    dayValues.append(item)
                }
            }
        }
        return dayValues
    }

    // 每日列表中的某条记录
    /// 记录显示用的账户 + 币型文本（如「招商银行 · 人民币」）
    func recordAccountText(_ record: AccountBookData) -> String {
        let name = assetAccounts.first { $0.id.uuidString == record.accountId }?.name ?? ""
        let currency = record.currency.isEmpty ? "CNY" : record.currency
        if name.isEmpty {
            return AssetCurrency.name(of: currency)
        }
        return "\(name) · \(AssetCurrency.name(of: currency))"
    }

    func recordDayListItem(_ recordItem:AccountBookData) -> some View {
        let currencySymbol = AssetCurrency.symbol(of: recordItem.currency.isEmpty ? "CNY" : recordItem.currency)
        return HStack {
            Text(hexStr2Unicode(recordItem.iconStr))
                .font(.custom("icomoon", size: 25))
                .foregroundColor( Color("DefaultButtonBackgroud"))
                .padding(10)
                .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(recordItem.title).font(.system(size: 14,weight:.bold)).padding(.bottom,2)
                if (StringUtils.trimCount(recordItem.desc) > 0) {
                    Text(recordItem.desc).font(.system(size: 12)).foregroundColor(.secondary)
                }
            }
            Spacer()
            if (recordItem.type == 0) {
                Text("-\(currencySymbol)\(recordItem.money)").font(.system(size: 15,weight: .bold))
            } else {
                Text("+\(currencySymbol)\(recordItem.money)").font(.system(size: 15,weight: .bold))
            }
            
        }.frame(minWidth: 0,maxWidth: .infinity)
            .padding(.horizontal,10)
            .frame(height: 60)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                // 账户和币型：右上角、不参与布局、不影响金额垂直居中
                if !recordItem.accountId.isEmpty || !recordItem.currency.isEmpty {
                    Text(recordAccountText(recordItem))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }
            }
            .onTapGesture {
                self.notifaction.handleId = nil
                self.editAccountBookData = recordItem
                self.editRecord = true
            }
            .selfSwiper(id: recordItem.id.description, maxOffsetX: 62, notification: notifaction) {
                Button {
                    deleteRecord(recordItem)
                } label: {
                    Image(systemName: "trash.circle")
                        .frame(width: 60,height: 60)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .background(Color("RedColor"),in:RoundedRectangle(cornerRadius: 10))
                }
            }
    }
    
    // 删除记录真正的操作
    func deleteRecord(_ recordItem:AccountBookData) {
        do {
            try AccountBookDataOfCacheService.deleteData(globalModel.accountBook!.id.description, data: recordItem, cache: globalModel)
            self.latestLoadTime = Date()
        } catch {
            
        }
    }
}

