//
//  AccountBookMonthSummaryComponent.swift
//  QingmuAccount
//  账本-列表模式-当月汇总（多币种）：卡片内按币种堆叠展示 支出/收入/结余/预算。
//  Created by 周荥马 on 2026/8/15.
//

import SwiftUI

struct AccountBookMonthSummaryComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 选择的年份
    @Binding var year:Int
    // 选择的月份
    @Binding var month:Int
    // 预算更新监听时间
    @Binding var budgetChangeTime:Date
    // 重新选择时间
    var changeTime: ()-> Void = {}
    // 显示统计
    var showStatistics:() -> Void = {}
    // 显示某个币种的预算详情
    var showBudgetDetail:(String) -> Void = { _ in }

    // 每币种收入 [currency:Decimal]
    @State private var monthIncome:[String:Decimal] = [:]
    // 每币种支出 [currency:Decimal]
    @State private var monthExpenses:[String:Decimal] = [:]
    // 每币种预算 [currency:Decimal]
    @State private var currencyBudgets:[String:Decimal] = [:]
    // 今日各币种已支出（loadData 中预计算，避免 body 中调用缓存服务）
    @State private var todayUsage:[String:Decimal] = [:]
    // 轮播当前币种
    @State private var scrolledCurrency:String? = nil

    var body: some View {
        VStack(spacing: 12) {
            headerRow
            currencyCarousel
            if sortedCurrencies.count > 1 {
                currencyChips
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 12)
        .padding(.horizontal, 14)
        .foregroundColor(.white)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background {
            LinearGradient(
                colors: [
                    Color("DefaultButtonBackgroud"),
                    Color("DefaultButtonBackgroud").opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("MainShadowColor").opacity(0.15), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 5)
        .onAppear() {
            loadData()
            if nil == scrolledCurrency {
                scrolledCurrency = sortedCurrencies.first
            }
        }
        .onChange(of: budgetChangeTime) { _ in
            loadData()
        }
    }

    // 币种轮播：单页一个币种，左右滑动切换
    var currencyCarousel: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(sortedCurrencies, id:\.self) { currency in
                    currencyBlock(currency)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledCurrency, anchor: .leading)
        .scrollIndicators(.hidden)
        .onChange(of: sortedCurrencies) { _, newValue in
            if let current = scrolledCurrency, !newValue.contains(current) {
                scrolledCurrency = newValue.first
            }
        }
    }

    // 币种指示 chips：横向可滚动，激活项自动滚动到可视区域
    var currencyChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 8) {
                    ForEach(sortedCurrencies, id:\.self) { currency in
                        chipView(currency)
                            .id(currency)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 3)
                .onChange(of: scrolledCurrency) { _, newValue in
                    if let target = newValue {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(target, anchor: .center)
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
    }

    func chipView(_ currency:String) -> some View {
        Text(AssetCurrency.name(of: currency))
            .font(.system(size: 13, weight: scrolledCurrency == currency ? .bold : .medium))
            .foregroundColor(scrolledCurrency == currency ? Color("DefaultButtonBackgroud") : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(scrolledCurrency == currency ? Color.white : Color.white.opacity(0.18)))
            .contentShape(Capsule())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    scrolledCurrency = currency
                }
            }
    }

    // 头部：年月选择 + 统计入口
    var headerRow: some View {
        HStack {
            HStack(spacing: 6) {
                Text("\(String(year))年\(month)月")
                    .font(.system(size: 17,weight: .bold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10,weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.18), in: Capsule())
            .contentShape(Rectangle())
            .onTapGesture {
                changeTime()
            }
            Spacer()
            Button(action: showStatistics) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.18), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 2)
    }

    // 展示的币种集合：本月记录 ∪ 本月预算 ∪ 账本默认币种，CNY 优先
    private var sortedCurrencies:[String] {
        var set = Set<String>()
        set.formUnion(monthIncome.keys)
        set.formUnion(monthExpenses.keys)
        set.formUnion(currencyBudgets.keys)
        if let def = globalModel.accountBook?.defaultCurrency, !def.isEmpty {
            set.insert(def)
        }
        if set.isEmpty {
            set.insert("CNY")
        }
        return set.sorted { a, b in
            if a == "CNY" { return true }
            if b == "CNY" { return false }
            return a < b
        }
    }

    // 单个币种的收支 + 预算
    func currencyBlock(_ currency:String) -> some View {
        let income = monthIncome[currency] ?? 0
        let expenses = monthExpenses[currency] ?? 0
        let balance = income - expenses
        let budget = currencyBudgets[currency]
        let usedPercent = budget.map { b -> Double in
            guard b > 0 else { return 1 }
            let percent = expenses / b
            return Double(truncating: percent as NSNumber)
        } ?? 0
        return VStack(spacing: 12) {
            // 第一行：币种徽章 + 名称 | 结余
            HStack(spacing: 10) {
                Text(AssetCurrency.symbol(of: currency))
                    .font(.system(size: 13,weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 32,height: 32)
                    .background(Circle().fill(Color("DefaultButtonBackgroud")))
                Text(AssetCurrency.name(of: currency))
                    .font(.system(size: 16,weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("结余")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    rollingAmount(currency, balance, font: .system(size: 20, weight: .bold), color: balance >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                }
            }
            // 第二行：支出 / 收入
            HStack(spacing: 0) {
                metricAmountItem("支出", currency, expenses)
                Rectangle()
                    .fill(Color("MainShadowColor").opacity(0.12))
                    .frame(width: 1,height: 30)
                metricAmountItem("收入", currency, income)
            }
            .padding(.vertical, 8)
            .background(Color("DefaultButtonBackgroud").opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            // 第三行：预算
            budgetRow(currency, budget: budget, expenses: expenses, usedPercent: usedPercent)
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.08), lineWidth: 1)
        }
        .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 8, x: 0, y: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            showBudgetDetail(currency)
        }
    }

    func metricAmountItem(_ label:String, _ currency:String, _ value:Decimal) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            rollingAmount(currency, value, font: .system(size: 18, weight: .bold), color: .primary)
        }
        .frame(maxWidth: .infinity)
    }

    // 支出/收入 指标
    func metricItem(_ label:String, _ value:String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 18,weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // 预算行：有预算显示进度，无预算显示设置入口
    @ViewBuilder
    func budgetRow(_ currency:String, budget:Decimal?, expenses:Decimal, usedPercent:Double) -> some View {
        if let budget = budget {
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Text("预算")
                        .font(.system(size: 12,weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(amountText(currency, expenses)) / \(amountText(currency, budget))")
                        .font(.system(size: 14,weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                    Text("\(Int(usedPercent * 100))%")
                        .font(.system(size: 14,weight: .bold))
                        .foregroundColor(usedPercent > 1 ? Color("RedColor") : Color("DefaultButtonBackgroud"))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10,weight: .bold))
                        .foregroundColor(.secondary)
                }
                AnimatedProgressBar(
                    progress: min(max(usedPercent, 0), 1),
                    height: 8,
                    progressColor: usedPercent > 1 ? Color("RedColor") : Color("DefaultButtonBackgroud")
                )
                if isCurrentMonth {
                    todayProgressRow(currency, budget: budget, expenses: expenses)
                }
            }
        } else {
            VStack(spacing: 7) {
                HStack(spacing: 5) {
                    Text("预算未设置")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("设置预算")
                        .font(.system(size: 12,weight: .semibold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color("DefaultButtonBackgroud").opacity(0.1), in: Capsule())
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10,weight: .bold))
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 5) {
                    Text("今日进度")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.7))
                    Spacer()
                    Text("设置预算后显示")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                AnimatedProgressBar(
                    progress: 0,
                    height: 8,
                    trackColor: Color("MainShadowColor").opacity(0.08),
                    progressColor: Color.clear
                )
            }
        }
    }

    // 今日预算进度：今日预算 / 今日已用 / 今日剩余
    func todayProgressRow(_ currency:String, budget:Decimal, expenses:Decimal) -> some View {
        let todayBudgetValue = todayBudget(currency, budget: budget, expenses: expenses)
        let todayUsed = todayUseMoney(currency)
        let todayRemaining = max(todayBudgetValue - todayUsed, 0)
        let overrun = todayUsed > todayBudgetValue
        let percent = todayBudgetValue > 0 ? Double(truncating: (todayUsed / todayBudgetValue) as NSNumber) : (todayUsed > 0 ? 1 : 0)
        return VStack(spacing: 7) {
            HStack(spacing: 5) {
                Text("今日预算")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Text("\(amountText(currency, todayUsed)) / \(amountText(currency, todayBudgetValue))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(overrun ? Color("RedColor") : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer()
                Text(overrun ? "超支 \(amountText(currency, todayUsed - todayBudgetValue))" : "剩余 \(amountText(currency, todayRemaining))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(overrun ? Color("RedColor") : Color("DefaultButtonBackgroud"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            AnimatedProgressBar(
                progress: min(max(percent, 0), 1),
                height: 8,
                progressColor: overrun ? Color("RedColor") : Color("DefaultButtonBackgroud")
            )
        }
        .padding(.top, 4)
    }

    // 今日预算目标：本月剩余预算按剩余天数均摊
    func todayBudget(_ currency:String, budget:Decimal, expenses:Decimal) -> Decimal {
        let todayUse = todayUseMoney(currency)
        let components = DateUtils.findComponentsOfDate([.year, .month, .day], date: Date())
        let currentYear = components.year ?? year
        let currentMonth = components.month ?? month
        let day = components.day ?? 1
        let dayLength = DateUtils.monthOfDayLength(year: currentYear, month: currentMonth)
        let balanceDay = dayLength - day + 1
        guard balanceDay > 0, budget > 0 else { return 0 }
        var remainingIncludingToday = budget - expenses + todayUse
        if remainingIncludingToday < 0 { remainingIncludingToday = 0 }
        return remainingIncludingToday / Decimal(balanceDay)
    }

    func rollingAmount(_ currency:String, _ value:Decimal, font:Font, color:Color) -> some View {
        let cents = Int64((NSDecimalNumber(decimal: value).doubleValue * 100).rounded())
        return RollingAmountText(
            cents: cents,
            prefix: AssetCurrency.symbol(of: currency),
            font: font,
            color: color
        )
    }

    func amountText(_ currency:String, _ value:Decimal) -> String {
        return "\(AssetCurrency.symbol(of: currency))\(DecimalUtils.trans2StringOfCurrency(value))"
    }

    // 是否正在查看当前月（今日信息只在当前月展示）
    private var isCurrentMonth: Bool {
        let thisYear = DateUtils.findComponentsOfDate([.year], date: Date()).year ?? year
        let thisMonth = DateUtils.findComponentsOfDate([.month], date: Date()).month ?? month
        return thisYear == year && thisMonth == month
    }

    // 今日某币种已支出（读自状态，不在 body 中调用缓存服务，避免 Publishing during view updates）
    func todayUseMoney(_ currency:String) -> Decimal {
        return todayUsage[currency] ?? 0
    }

    // 今日还能用多少（预算剩余按剩余天数均摊，扣除今日已用）
    func todayCanUse(_ currency:String, budget:Decimal, expenses:Decimal) -> Decimal {
        let todayUse = todayUseMoney(currency)
        let today = Date()
        let year = DateUtils.findComponentsOfDate([.year], date: today).year ?? 1
        let month = DateUtils.findComponentsOfDate([.month], date: today).month ?? 1
        let day = DateUtils.findComponentsOfDate([.day], date: today).day ?? 1
        let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
        let balanceDay = dayLength - day + 1
        guard balanceDay > 0, budget > 0 else { return 0 }
        var canUseTemp = budget - expenses + todayUse
        if canUseTemp < 0 { canUseTemp = 0 }
        let everyDayBudget = canUseTemp / Decimal(balanceDay)
        var canUse = everyDayBudget - todayUse
        if canUse < 0 { canUse = 0 }
        return canUse
    }

    func loadData() {
        guard let book = globalModel.accountBook else { return }
        let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
        let ymStr = String("\(year)\(monthStr)")
        let todayYmd = DateUtils.transDate2String(Date(), format: "yyyyMMdd")
        var incomeTemp:[String:Decimal] = [:]
        var expensesTemp:[String:Decimal] = [:]
        var todayUsageTemp:[String:Decimal] = [:]
        if let yearData = try? AccountBookDataOfCacheService.getData(book.id.description, year: year, cache: globalModel),
           let monthRecords = yearData.data[ymStr] {
            for record in monthRecords {
                let code = record.currency.isEmpty ? "CNY" : record.currency
                if record.type == 0 {
                    expensesTemp[code, default: 0] += (Decimal(string: record.money) ?? 0)
                    if record.dateStr == todayYmd {
                        todayUsageTemp[code, default: 0] += (Decimal(string: record.money) ?? 0)
                    }
                } else {
                    incomeTemp[code, default: 0] += (Decimal(string: record.money) ?? 0)
                }
            }
        }
        monthIncome = incomeTemp
        monthExpenses = expensesTemp
        todayUsage = todayUsageTemp
        // 本月预算（按币种）
        var budgetsTemp:[String:Decimal] = [:]
        if let setting = try? AccountBookSetingOfCacheService.getSeting(book.id.description, cache: globalModel),
           let monthBudgets = setting.budget[ymStr] {
            budgetsTemp = monthBudgets
        }
        currencyBudgets = budgetsTemp
    }
}
