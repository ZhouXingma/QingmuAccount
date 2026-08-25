//
//  AccountBookBudgetSetting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/8.
//

import SwiftUI
import Combine

struct AccountBookBudgetDetailComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 选择的年份（当月预算 tab）
    @State var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 选择的月份
    @State var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 本年
    @State var thisYear:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 本月
    @State var thisMonth:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 本年本月，yyyyMM
    @State var thisYm:String = DateUtils.transDate2String(Date(), format: "yyyyMM")
    // 整本的配置信息
    @State private var accountBookSeting:AccountBookSetingModel? = nil
    // 显示提醒
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig()

    // 顶部 tab：0=当月预算 1=历史预算
    @State private var tabSelection:Int = 0
    // 预置币种（从汇总卡进入时带）
    var initCurrency: String? = nil

    // 当月各币种预算 [currency:Decimal]
    @State private var monthBudgets:[String:Decimal] = [:]
    // 当月各币种支出 [currency:Decimal]
    @State private var monthExpenses:[String:Decimal] = [:]
    // 历史年份各月支出 [ym:[currency:Decimal]]（在事件回调中预加载，避免视图求值期间访问缓存服务）
    @State private var historyExpenses:[String:[String:Decimal]] = [:]

    // 详情币种 sheet
    @State private var detailSheetData:BudgetCurrencyDetailData? = nil
    // 详情币种的总预算
    @State private var budget:Decimal?
    // 详情币种的总支出
    @State private var expend:Decimal = 0
    // 详情币种的预算剩余百分比
    @State private var budgetUsePercent:Double = 1
    // 详情币种总计还可以使用多少钱
    @State private var canUseMoney:String = "-"
    // 剩余天数
    @State private var dayCount:String = "-"
    // 今日预算
    @State private var dayBudget:String = "-"
    // 今日已用
    @State private var todayUseMoney:Decimal = 0
    // 今日还可以使用
    @State private var todayCanUseMoney:String = "-"

    // 设置预算 sheet 相关
    @State private var setingBudgetShow = false
    // 设置预算预置的币种
    @State private var setingCurrency:String = "CNY"
    // 设置预算预置的年月 yyyyMM
    @State private var setingYm:String = ""
    // 设置预算预填金额（添加=空，编辑=现有值）
    @State private var setingPrefill:String = ""
    var updateBudgetSeting:() -> Void = {}

    // 历史预算年份
    @State private var historyYear:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 历史预算选中的月份
    @State private var selectedHistoryMonth:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 选择年份组建显示
    @State private var showYearPicker = false
    // 选择年份的数据
    @State private var showYearPickerType : DatePickerType = .Y
    // 选择年份的默认数据
    @State private var pickerYearDefaultValue: DatePickerValue = DatePickerValue()

    var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color("DefaultButtonBackgroud"), Color("DefaultButtonBackgroud").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // 本月出现过的币种（记录 ∪ 预算 ∪ 默认币种），CNY 优先
    private var presentCurrencies:[String] {
        var set = Set<String>()
        set.formUnion(monthExpenses.keys)
        set.formUnion(monthBudgets.keys)
        if let def = globalModel.accountBook?.defaultCurrency, !def.isEmpty {
            set.insert(def)
        }
        if set.isEmpty {
            set.insert("CNY")
        }
        return sortCurrencies(set)
    }

    // 本月已设置预算的币种，CNY 优先
    private var budgetCurrencies:[String] {
        sortCurrencies(Set(monthBudgets.keys))
    }

    // 本月有预算且超支的币种数
    private var overrunCount:Int {
        monthBudgets.filter { (currency, b) in
            b > 0 && (monthExpenses[currency] ?? 0) > b
        }.count
    }

    // 本月未设置预算的币种数
    private var unsetBudgetCount:Int {
        presentCurrencies.filter { monthBudgets[$0] == nil }.count
    }

    // 本年出现的币种集合（该年有预算的币种 ∪ 默认币种）
    private var historyCurrencies:[String] {
        var set = Set<String>()
        if let setting = accountBookSeting {
            for (ym, currencyBudgets) in setting.budget where ym.hasPrefix("\(historyYear)") {
                set.formUnion(currencyBudgets.keys)
            }
        }
        if let def = globalModel.accountBook?.defaultCurrency, !def.isEmpty {
            set.insert(def)
        }
        if set.isEmpty {
            set.insert("CNY")
        }
        return sortCurrencies(set)
    }

    func sortCurrencies(_ set:Set<String>) -> [String] {
        return set.sorted { a, b in
            if a == "CNY" { return true }
            if b == "CNY" { return false }
            return a < b
        }
    }

    var body: some View {
        ZStack {
            Color("ViewBackgroundColor").ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeaderComponent()
                topTabBar
                    .padding(.top, 12)
                TabView(selection: $tabSelection) {
                    currentMonthTab.tag(0)
                    historyTab.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: tabSelection)
            }
            .padding(.horizontal, 15)
        }
        .selfDatePicker(showState: $showYearPicker, type: $showYearPickerType, param: $pickerYearDefaultValue) {newVlue in
            if let y = newVlue.year, y != historyYear {
                historyYear = y
                loadHistoryExpenses()
            }
        }
        .sheet(item: $detailSheetData) { data in
            AccountBookBudgetCurrencyDetailComponent(
                data: data,
                initYm: ymStrOf(year, month),
                onSave: { amount, currency, ym in
                    saveBudgetSeting(amount: amount, currency: currency, ym: ym)
                    detailSheetData = nil
                }
            )
            .environmentObject(globalModel)
        }
        .sheet(isPresented: $setingBudgetShow) {
            AccountBookBudgetSettingComponent(initCurrency: setingCurrency, initYm: setingYm, thisMothBugget: setingPrefill, saveBudgetSeting: saveBudgetSeting)
                .environmentObject(globalModel)
        }
        .onAppear() {
            loadData()
            loadHistoryExpenses()
            if let ic = initCurrency, monthBudgets[ic] != nil {
                DispatchQueue.main.async {
                    openDetail(ic)
                }
            }
        }
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    // 顶部 tab 切换
    var topTabBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("DefaultButtonBackgroud"))
                .frame(width: 135, height: 32)
                .offset(x: tabSelection == 0 ? -67 : 67)
                .animation(.easeInOut(duration: 0.2), value: tabSelection)
            HStack(spacing: 0) {
                tabButton(0, "当月预算")
                tabButton(1, "历史预算")
            }
        }
        .frame(width: 270, height: 32)
        .padding(3)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
    }

    func tabButton(_ code:Int, _ title:String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(tabSelection == code ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tabSelection = code
                }
            }
    }

    // MARK: - Tab1 当月预算

    var currentMonthTab: some View {
        VStack(spacing: 12) {
            // 固定：总览 + 添加预算按钮
            monthHeroCard
            addBudgetButton
            // 可滚动：预算卡片列表
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    if budgetCurrencies.isEmpty {
                        emptyBudgetView
                    } else {
                        ForEach(budgetCurrencies, id:\.self) { currency in
                            budgetCard(currency)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 12)
    }

    // 本月预算总览
    var monthHeroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(String(year))年\(month)月")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
            }
            Text("本月预算")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            HStack(spacing: 0) {
                heroStat("已设预算", "\(monthBudgets.count)")
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 1, height: 28)
                heroStat("已超支", "\(overrunCount)")
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 1, height: 28)
                heroStat("未设置", "\(unsetBudgetCount)")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(heroGradient, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("MainShadowColor").opacity(0.12), radius: 10, x: 0, y: 4)
    }

    func heroStat(_ label:String, _ value:String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
    }

    // 添加预算按钮
    var addBudgetButton: some View {
        Button {
            setingCurrency = globalModel.accountBook?.defaultCurrency ?? "CNY"
            setingYm = ymStrOf(year, month)
            setingPrefill = ""
            setingBudgetShow = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("添加预算")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(heroGradient, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // 本月尚未设置预算
    var emptyBudgetView: some View {
        VStack(spacing: 8) {
            Image(systemName: "creditcard")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.4))
            Text("本月尚未设置预算")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text("点击上方「添加预算」为币种设置月度预算")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
    }

    // 单个币种的当月预算卡（仅已设置）
    func budgetCard(_ currency:String) -> some View {
        let expenses = monthExpenses[currency] ?? 0
        let budgetValue = monthBudgets[currency] ?? 0
        let remaining = budgetValue - expenses
        let overrun = remaining < 0
        let used = budgetValue > 0 ? Double(truncating: (expenses / budgetValue) as NSNumber) : 1
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text(AssetCurrency.symbol(of: currency))
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color("DefaultButtonBackgroud")))
                VStack(alignment: .leading, spacing: 2) {
                    Text(AssetCurrency.name(of: currency))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    Text(currency)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("已用")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(amountText(currency, expenses))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            GeometryReader { reader in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("MainShadowColor").opacity(0.12))
                    Capsule().fill(overrun ? Color("RedColor") : Color("DefaultButtonBackgroud"))
                        .frame(width: reader.size.width * CGFloat(min(max(used, 0), 1)))
                }
            }.frame(height: 8)
            HStack {
                Text("预算 \(amountText(currency, budgetValue))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                Text(overrun ? "超支 \(amountText(currency, -remaining))" : "剩余 \(amountText(currency, remaining))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(overrun ? Color("RedColor") : Color("DefaultButtonBackgroud"))
                Text("\(Int(used * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.08), lineWidth: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            openDetail(currency)
        }
    }

    // MARK: - Tab2 历史预算

    var historyTab: some View {
        VStack(spacing: 12) {
            // 固定：年份 + 12 个月状态网格
            HStack {
                Button {
                    pickerYearDefaultValue.year = historyYear
                    showYearPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text("\(String(historyYear))年")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("DefaultButtonBackgroud").opacity(0.1), in: Capsule())
                }
                .buttonStyle(.plain)
                Spacer()
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(1...12, id:\.self) { m in
                    monthCell(m)
                }
            }
            // 可滚动：选中月份详情
            ScrollView(showsIndicators: false) {
                selectedMonthDetail
                    .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 12)
    }

    // 某月状态：0=未设置 1=结余 2=超支
    func monthStatus(_ m:Int) -> Int {
        let ym = ymStrOf(historyYear, m)
        let monthBudget = accountBookSeting?.budget[ym] ?? [:]
        if monthBudget.isEmpty {
            return 0
        }
        var overrun = false
        for (currency, budgetValue) in monthBudget {
            if budgetValue > 0 && monthExpenses(currency, ym: ym) > budgetValue {
                overrun = true
                break
            }
        }
        return overrun ? 2 : 1
    }

    func statusLabel(_ status:Int) -> String {
        switch status {
        case 0: return "未设置"
        case 1: return "结余"
        default: return "超支"
        }
    }

    func statusColor(_ status:Int) -> Color {
        switch status {
        case 0: return .secondary.opacity(0.6)
        case 1: return Color("DefaultButtonBackgroud")
        default: return Color("RedColor")
        }
    }

    func monthCellFill(_ status:Int, selected:Bool) -> Color {
        if selected {
            return Color("DefaultButtonBackgroud")
        }
        switch status {
        case 0: return Color("MainBackgroundColor")
        case 1: return Color("DefaultButtonBackgroud").opacity(0.08)
        default: return Color("RedColor").opacity(0.12)
        }
    }

    func monthCell(_ m:Int) -> some View {
        let status = monthStatus(m)
        let selected = selectedHistoryMonth == m
        return VStack(spacing: 4) {
            Text("\(m)月")
                .font(.system(size: 14, weight: selected ? .bold : .medium))
                .foregroundColor(selected ? .white : .primary)
            Text(statusLabel(status))
                .font(.system(size: 9))
                .foregroundColor(selected ? .white.opacity(0.9) : statusColor(status))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(monthCellFill(status, selected: selected)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("MainShadowColor").opacity(selected ? 0 : 0.08), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedHistoryMonth = m
            }
        }
    }

    // 选中月份：各币种预算使用情况
    var selectedMonthDetail: some View {
        let m = selectedHistoryMonth
        let ym = ymStrOf(historyYear, m)
        let monthBudget = accountBookSeting?.budget[ym] ?? [:]
        let currencies = sortCurrencies(Set(monthBudget.keys))
        return VStack(spacing: 12) {
            HStack {
                Text("\(m)月预算使用")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                if !currencies.isEmpty {
                    Text("\(currencies.count) 个币种")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            if currencies.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("\(m)月未设置预算")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 8) {
                    ForEach(currencies, id:\.self) { currency in
                        if let budgetValue = monthBudget[currency] {
                            historyCurrencyRow(currency, ym: ym, budgetValue: budgetValue)
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

    func historyCurrencyRow(_ currency:String, ym:String, budgetValue:Decimal) -> some View {
        let useValue = monthExpenses(currency, ym: ym)
        let overrun = useValue > budgetValue
        let used = budgetValue > 0 ? Double(truncating: (useValue / budgetValue) as NSNumber) : 1
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(AssetCurrency.symbol(of: currency))
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(overrun ? Color("RedColor") : Color("DefaultButtonBackgroud")))
                Text(currency)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("已用 \(amountText(currency, useValue))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(overrun ? Color("RedColor") : .primary)
                Text("/")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("预算 \(amountText(currency, budgetValue))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }
            GeometryReader { reader in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("MainShadowColor").opacity(0.12))
                    Capsule().fill(overrun ? Color("RedColor") : Color("DefaultButtonBackgroud"))
                        .frame(width: reader.size.width * CGFloat(min(max(used, 0), 1)))
                }
            }.frame(height: 8)
            HStack {
                if overrun {
                    Text("超支 \(amountText(currency, useValue - budgetValue))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("RedColor"))
                } else {
                    Text("结余 \(amountText(currency, budgetValue - useValue))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                }
                Spacer()
                Text("\(Int(used * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color("MainShadowColor").opacity(0.03), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - 数据逻辑

    // 打开某个币种的预算详情（弹出 sheet）
    func openDetail(_ currency:String) {
        computerSelectedData(currency)
        detailSheetData = BudgetCurrencyDetailData(
            currency: currency,
            budget: budget,
            expend: expend,
            canUseMoney: canUseMoney,
            budgetUsePercent: budgetUsePercent,
            dayCount: dayCount,
            dayBudget: dayBudget,
            todayUseMoney: todayUseMoney,
            todayCanUseMoney: todayCanUseMoney,
            isCurrentMonth: (thisYear == year && thisMonth == month)
        )
    }

    // 加载预算信息 + 各币种支出
    func loadData() {
        if nil == globalModel.accountBook {
            return
        }
        let ymStr = ymStrOf(year, month)
        do {
            accountBookSeting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
        } catch {
            alterConfig.showCancelButton = false
            alterConfig.desc = "加载账本配置信息失败，无法进行后续操作"
            alterConfig.sureButtonName = "我知道啦"
            showAlter = true
        }
        if nil != accountBookSeting {
            monthBudgets = accountBookSeting!.budget[ymStr] ?? [:]
        } else {
            monthBudgets = [:]
        }
        monthExpenses = monthExpensesOf(ymStr)
        if let currency = detailSheetData?.currency {
            computerSelectedData(currency)
        }
    }

    // 计算详情币种的展示数据
    func computerSelectedData(_ currency:String) {
        budget = monthBudgets[currency]
        expend = monthExpenses[currency] ?? 0
        if let budget = budget, budget != 0 {
            var canUseMoneyTemp = budget - expend
            if (canUseMoneyTemp < 0) {
                canUseMoneyTemp = 0
            }
            let tempValue = canUseMoneyTemp / budget
            self.canUseMoney = amountText(currency, canUseMoneyTemp)
            self.budgetUsePercent = Double(truncating: tempValue as NSNumber)
        } else {
            self.canUseMoney = "-"
            self.budgetUsePercent = 1.0
        }
        if (thisYear == year && thisMonth == month) {
            // 计算今日使用金额
            self.todayUseMoney = todayExpenses(currency)
            // 计算每日的预算信息
            computerDayBudgetInfo(currency)
        }
    }

    //  计算每日的预算信息
    func computerDayBudgetInfo(_ currency:String) {
        // 还剩下多少天
        let components = DateUtils.findComponentsOfDate([.year,.month,.day], date: Date())
        let year = components.year!
        let month = components.month!
        let day  = components.day!
        let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
        let balanceDay = dayLength - day + 1
        self.dayCount = String("\(balanceDay)")
        computerDayUseMoneyInfo(currency, balanceDay:balanceDay)
    }

    // 计算每日可用金钱
    func computerDayUseMoneyInfo(_ currency:String, balanceDay:Int){
        if (balanceDay <= 0 || nil == self.budget || self.budget! == 0) {
            // 每日可用多少钱
            self.dayBudget = "-"
            // 今日可用金额
            self.todayCanUseMoney = "-"
            return
        }
        // 可以使用的钱
        var canUseManeyTemp = self.budget! - self.expend + self.todayUseMoney
        if (canUseManeyTemp < 0) {
            canUseManeyTemp = 0
        }
        // 每天可以用的预算
        let everyDayBudget =  canUseManeyTemp / Decimal(balanceDay)
        // 今天还能用的钱
        var everyDayCanUseManey = everyDayBudget - self.todayUseMoney
        if (everyDayCanUseManey < 0) {
            everyDayCanUseManey = 0
        }
        self.dayBudget = amountText(currency, everyDayBudget)
        self.todayCanUseMoney = amountText(currency, everyDayCanUseManey)
    }

    func amountText(_ currency:String, _ value:Decimal) -> String {
        return "\(AssetCurrency.symbol(of: currency))\(DecimalUtils.trans2StringOfCurrency(value))"
    }

    // 保存预算（金额, 币种, yyyyMM）
    func saveBudgetSeting(amount:String, currency:String, ym:String) {
        guard let accountBookSeting = accountBookSeting else {
            alterConfig.showCancelButton = false
            alterConfig.desc = "加载账本配置信息失败，无法进行操作"
            alterConfig.sureButtonName = "我知道啦"
            showAlter = true
            return
        }
        var ymBudgets = accountBookSeting.budget[ym] ?? [:]
        if amount == "0" || amount == "" || amount=="0.00" || amount=="0.0" {
            ymBudgets.removeValue(forKey: currency)
        } else {
            ymBudgets[currency] = Decimal(string: amount)
        }
        accountBookSeting.budget[ym] = ymBudgets
        do {
            try AccountBookSetingOfCacheService.updateSetting(globalModel.accountBook!.id.description, accountBookSeting, cache: globalModel)
            setingBudgetShow = false
            loadData()
            updateBudgetSeting()
        } catch {
            alterConfig.showCancelButton = false
            alterConfig.desc = "操作失败！"
            alterConfig.sureButtonName = "我知道了"
            showAlter = true
        }
    }

    // MARK: - 数据聚合（按币种）

    func ymStrOf(_ y:Int, _ m:Int) -> String {
        let monthStr = m < 10 ? String("0\(m)") : String("\(m)")
        return String("\(y)\(monthStr)")
    }

    // 某月各币种支出 [currency:Decimal]
    func monthExpensesOf(_ ym:String) -> [String:Decimal] {
        guard let book = globalModel.accountBook else { return [:] }
        let y = Int(ym.prefix(4)) ?? year
        guard let yearData = try? AccountBookDataOfCacheService.getData(book.id.description, year: y, cache: globalModel),
              let records = yearData.data[ym] else { return [:] }
        var result:[String:Decimal] = [:]
        for record in records where record.type == 0 {
            let code = record.currency.isEmpty ? "CNY" : record.currency
            result[code, default: 0] += (Decimal(string: record.money) ?? 0)
        }
        return result
    }

    // 某月某币种支出（历史 tab：读预加载结果，不触发缓存服务）
    func monthExpenses(_ currency:String, ym:String) -> Decimal {
        return historyExpenses[ym]?[currency] ?? 0
    }

    // 预加载历史年份各月支出。只能在事件回调（onAppear/年份选择）中调用，
    // 因为 getData 在缓存未命中时会发布 @Published，若在视图求值期间调用会触发运行时错误。
    func loadHistoryExpenses() {
        guard let book = globalModel.accountBook else {
            historyExpenses = [:]
            return
        }
        var result:[String:[String:Decimal]] = [:]
        if let yearData = try? AccountBookDataOfCacheService.getData(book.id.description, year: historyYear, cache: globalModel) {
            for (ym, records) in yearData.data {
                var monthMap:[String:Decimal] = [:]
                for record in records where record.type == 0 {
                    let code = record.currency.isEmpty ? "CNY" : record.currency
                    monthMap[code, default: 0] += (Decimal(string: record.money) ?? 0)
                }
                result[ym] = monthMap
            }
        }
        historyExpenses = result
    }

    // 今日某币种支出
    func todayExpenses(_ currency:String) -> Decimal {
        guard let book = globalModel.accountBook else { return 0 }
        let ymd = DateUtils.transDate2String(Date(), format: "yyyyMMdd")
        let ym = DateUtils.transDate2String(Date(), format: "yyyyMM")
        let y = DateUtils.findComponentsOfDate([.year], date: Date()).year!
        guard let yearData = try? AccountBookDataOfCacheService.getData(book.id.description, year: y, cache: globalModel),
              let records = yearData.data[ym] else { return 0 }
        var total:Decimal = 0
        for record in records where record.type == 0 && record.dateStr == ymd {
            let code = record.currency.isEmpty ? "CNY" : record.currency
            if code == currency {
                total += (Decimal(string: record.money) ?? 0)
            }
        }
        return total
    }
}

// 单个币种预算详情数据（sheet item）
struct BudgetCurrencyDetailData: Identifiable {
    var id: String { currency }
    let currency: String
    let budget: Decimal?
    let expend: Decimal
    let canUseMoney: String
    let budgetUsePercent: Double
    let dayCount: String
    let dayBudget: String
    let todayUseMoney: Decimal
    let todayCanUseMoney: String
    let isCurrentMonth: Bool
}

// 单个币种预算详情 sheet
struct AccountBookBudgetCurrencyDetailComponent: View {
    @EnvironmentObject var globalModel: GlobalModel
    let data: BudgetCurrencyDetailData
    // 编辑预算的年月 yyyyMM
    var initYm: String = ""
    // 保存回调 (金额, 币种, yyyyMM)，由父级持久化并刷新
    var onSave: (String, String, String) -> Void = {_,_,_ in }
    // 是否显示设置预算 sheet
    @State private var setingBudgetShow = false

    var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color("DefaultButtonBackgroud"), Color("DefaultButtonBackgroud").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Color("ViewBackgroundColor").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    SheetHeaderComponent()
                    heroCard
                    detailCard
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $setingBudgetShow) {
            AccountBookBudgetSettingComponent(
                initCurrency: data.currency,
                initYm: initYm,
                thisMothBugget: data.budget.map { DecimalUtils.trans2StringOfCurrency($0) } ?? "",
                saveBudgetSeting: { amount, currency, ym in
                    setingBudgetShow = false
                    onSave(amount, currency, ym)
                }
            )
            .environmentObject(globalModel)
        }
    }

    // 环形卡
    var heroCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Text(AssetCurrency.symbol(of: data.currency))
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text(AssetCurrency.name(of: data.currency))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(data.currency)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Button {
                    setingBudgetShow = true
                } label: {
                    Text("设置预算")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white))
                }
                .buttonStyle(.plain)
            }
            if let budget = data.budget {
                ZStack {
                    CircleProgressComponent(size: 16, bgColor: .white.opacity(0.25), InnerColor: .white, percent: .constant(data.budgetUsePercent))
                        .frame(width: 170, height: 170)
                    VStack(spacing: 2) {
                        Text("\(DecimalUtils.trans2StringOfPercent(Decimal(data.budgetUsePercent * 100)))%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("剩余")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.85))
                    Text("未设置预算")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(height: 170)
            }
            HStack(spacing: 0) {
                statItem("已用", amountText(data.expend), color: .white.opacity(0.9))
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 1, height: 30)
                statItem("预算", data.budget.map { amountText($0) } ?? "未设置", color: .white)
            }
        }
        .padding(18)
        .background(heroGradient, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("MainShadowColor").opacity(0.12), radius: 10, x: 0, y: 4)
    }

    func statItem(_ label:String, _ value:String, color:Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(color.opacity(0.85))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // 本月明细
    var detailCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("本月明细")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                detailTile("本月总支出", amountText(data.expend))
                detailTile("本月剩余预算", data.canUseMoney,
                           color: (data.budget ?? 0) >= data.expend ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                if data.isCurrentMonth {
                    detailTile("今日预算", data.dayBudget)
                    detailTile("今日可用", data.todayCanUseMoney)
                    detailTile("今日支出", amountText(data.todayUseMoney))
                    detailTile("剩余天数", "\(data.dayCount) 天")
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

    func detailTile(_ label:String, _ value:String, color:Color = .primary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("DefaultButtonBackgroud").opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }

    func amountText(_ value:Decimal) -> String {
        return "\(AssetCurrency.symbol(of: data.currency))\(DecimalUtils.trans2StringOfCurrency(value))"
    }
}
