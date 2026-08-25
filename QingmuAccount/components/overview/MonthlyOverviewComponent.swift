//
//  MonthlyOverviewComponent.swift
//  QingmuAccount
//
//  月度概览组件
//  Created by 周荥马 on 2024/7/3.
//

import SwiftUI

// 用于 sheet(item:) 的标识结构体
struct MonthlySheetItem: Identifiable {
    let id = UUID()
    let bookId: String
    let bookName: String
}

struct MonthlyOverviewComponent: View {
    @EnvironmentObject var globalModel: GlobalModel
    @Binding var year: Int
    @Binding var month: Int
    @Binding var thisYear: Int
    @Binding var thisMonth: Int

    // 每币种收入/支出 [currency:Decimal]
    @State private var incomeByCurrency: [String: Decimal] = [:]
    @State private var expensesByCurrency: [String: Decimal] = [:]
    // 有收支的币种（CNY 优先）
    @State private var summaryCurrencies: [String] = []
    // 合计卡片轮播当前币种
    @State private var scrolledSummaryCurrency: String? = nil
    @State private var bookDetails: [OverviewBookDetail] = []

    @State private var sheetItem: MonthlySheetItem? = nil

    // 币种配色（CNY 用主题色，其余按出现顺序取调色板）
    private let currencyColorPalette: [Color] = [
        Color("DefaultButtonBackgroud"), Color.blue, Color.orange, Color.purple, Color.pink, Color.teal, Color.green, Color.red
    ]

    func currencyColor(_ currency: String) -> Color {
        let idx = summaryCurrencies.firstIndex(of: currency) ?? 0
        return currencyColorPalette[idx % currencyColorPalette.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            monthSelector

            summaryCard
                .padding(.horizontal, 15)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    if bookDetails.isEmpty {
                        emptyView
                    } else {
                        HStack {
                            Text("各账本明细")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 5)
                        .padding(.top, 10)
                        ForEach(bookDetails.indices, id: \.self) { index in
                            bookDetailRow(bookDetails[index])
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 100)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear { 
            loadData() 
        }
        .onChange(of: month) { _ in 
            loadData() 
        }
        .onChange(of: year) { _ in 
            loadData() 
        }
        .sheet(item: $sheetItem) { item in
            AnyView(
                AccountBookStatisticComponent(
                    initYear: year,
                    initMonth: month,
                    initDateType: 0,
                    initBookId: item.bookId
                )
                .environmentObject(globalModel)
            )
        }
    }

    // 月份选择器
    var monthSelector: some View {
        // 如果是当年，只显示到当前月份
        let maxMonth = (year == thisYear) ? thisMonth : 12
        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1...maxMonth, id: \.self) { m in
                        Text("\(m)")
                            .font(.system(size: 15, weight: month == m ? .bold : .medium))
                            .foregroundColor(month == m ? .white : .secondary)
                            .frame(width: 36, height: 36)
                            .background {
                                if month == m {
                                    Circle()
                                        .fill(Color("DefaultButtonBackgroud"))
                                } else {
                                    Circle()
                                        .fill(Color("MainBackgroundColor"))
                                }
                            }
                            .id(m)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    month = m
                                }
                            }
                    }
                }
                .padding(.horizontal, 15)
            }
            .onAppear {
                proxy.scrollTo(month, anchor: .center)
            }
        }
        .padding(.vertical, 8)
    }

    // 合计卡片（多币种横向轮播 + 下方币种导航，白色背景）
    var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(month)月 · 全部账本合计")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
            }
            if summaryCurrencies.isEmpty {
                Text("暂无数据")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                summaryCarousel
                if summaryCurrencies.count > 1 {
                    summaryCurrencyChips
                }
            }
        }
        .padding(16)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("MainShadowColor").opacity(0.08), lineWidth: 1)
        }
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 8, x: 0, y: 3)
    }

    // 币种轮播：一页一个币种，左右滑动切换
    var summaryCarousel: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(summaryCurrencies, id:\.self) { currency in
                    summaryCurrencyPage(currency)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledSummaryCurrency, anchor: .leading)
        .scrollIndicators(.hidden)
        .onChange(of: summaryCurrencies) { _, newValue in
            if let current = scrolledSummaryCurrency, !newValue.contains(current) {
                scrolledSummaryCurrency = newValue.first
            }
        }
    }

    // 单个币种：结余 + 收入/支出
    func summaryCurrencyPage(_ currency: String) -> some View {
        let income = incomeByCurrency[currency] ?? 0
        let expenses = expensesByCurrency[currency] ?? 0
        let balance = income - expenses
        return VStack(spacing: 12) {
            HStack(spacing: 10) {
                Text(AssetCurrency.symbol(of: currency))
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(currencyColor(currency)))
                Text(AssetCurrency.name(of: currency))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("结余")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(amountText(currency, balance))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(balance >= 0 ? currencyColor(currency) : Color("RedColor"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            HStack(spacing: 0) {
                summaryMetric("收入", currency, income, color: .green)
                Rectangle()
                    .fill(Color("MainShadowColor").opacity(0.12))
                    .frame(width: 1, height: 30)
                summaryMetric("支出", currency, expenses, color: .red)
            }
            .padding(.vertical, 8)
            .background(currencyColor(currency).opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // 收入/支出 指标项
    func summaryMetric(_ label: String, _ currency: String, _ value: Decimal, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(amountText(currency, value))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // 币种导航 chips：激活项自动滚动到可视区域，点击切换轮播
    var summaryCurrencyChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 8) {
                    ForEach(summaryCurrencies, id:\.self) { currency in
                        summaryChip(currency)
                            .id(currency)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 3)
                .onChange(of: scrolledSummaryCurrency) { _, newValue in
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

    func summaryChip(_ currency: String) -> some View {
        let on = scrolledSummaryCurrency == currency
        return HStack(spacing: 4) {
            Text(AssetCurrency.symbol(of: currency))
                .font(.system(size: 12, weight: .bold))
            Text(AssetCurrency.name(of: currency))
                .font(.system(size: 13, weight: on ? .bold : .medium))
        }
        .foregroundColor(on ? .white : .secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(on ? currencyColor(currency) : Color("ViewBackgroundColor")))
        .overlay(Capsule().stroke(Color("MainShadowColor").opacity(0.12), lineWidth: on ? 0 : 1))
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                scrolledSummaryCurrency = currency
            }
        }
    }

    // 单个账本明细卡片（账本名 + 每个币种一个小块）
    fileprivate func bookDetailRow(_ item: OverviewBookDetail) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(item.bookName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            ForEach(item.currencySums) { cs in
                currencyBlock(cs)
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
            sheetItem = MonthlySheetItem(bookId: item.bookId, bookName: item.bookName)
        }
    }

    // 单个账本某个币种：结余 + 收入/支出
    func currencyBlock(_ cs: OverviewBookCurrencySum) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(AssetCurrency.symbol(of: cs.currency))
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(currencyColor(cs.currency)))
                Text(AssetCurrency.name(of: cs.currency))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Text("结余 \(amountText(cs.currency, cs.balance))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(cs.balance >= 0 ? currencyColor(cs.currency) : Color("RedColor"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            HStack(spacing: 0) {
                bookMetric("收入", amountText(cs.currency, cs.income), color: .green)
                Rectangle()
                    .fill(Color("MainShadowColor").opacity(0.12))
                    .frame(width: 1, height: 22)
                bookMetric("支出", amountText(cs.currency, cs.expenses), color: .red)
            }
            .padding(.vertical, 6)
            .background(currencyColor(cs.currency).opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(10)
        .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
    }

    func bookMetric(_ label: String, _ value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
    }

    func amountText(_ currency: String, _ value: Decimal) -> String {
        return "\(AssetCurrency.symbol(of: currency))\(DecimalUtils.trans2StringOfCurrency(value))"
    }

    var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.4))
            Text("暂无\(month)月数据")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    // 加载数据（按币种分组）
    func loadData() {
        var accountBooks: [String: AccountBookModel]? = nil
        do {
            accountBooks = try AccountBookHandleOfCacheService.getAccountBooks(cache: globalModel)
        } catch {}
        guard let books = accountBooks, !books.isEmpty else {
            incomeByCurrency = [:]
            expensesByCurrency = [:]
            summaryCurrencies = []
            scrolledSummaryCurrency = nil
            bookDetails = []
            return
        }

        // 一次 SQL 聚合出所有账本本月各币种的收支
        var sumsByBookCurrency: [String: [String: (income: Decimal, expenses: Decimal)]] = [:]
        var allIncome: [String: Decimal] = [:]
        var allExpenses: [String: Decimal] = [:]
        if let rows = try? AccountBookAggregateService.bookTypeSums(year: year, month: month) {
            for row in rows {
                var bookMap = sumsByBookCurrency[row.bookId] ?? [:]
                var entry = bookMap[row.currency] ?? (Decimal(0), Decimal(0))
                if row.type == 1 {
                    entry.income = row.sum
                } else {
                    entry.expenses = row.sum
                }
                bookMap[row.currency] = entry
                sumsByBookCurrency[row.bookId] = bookMap
                if row.type == 1 {
                    allIncome[row.currency, default: 0] += row.sum
                } else {
                    allExpenses[row.currency, default: 0] += row.sum
                }
            }
        }

        var details: [OverviewBookDetail] = []
        for (_, book) in books {
            let bookId = book.id.description
            guard let bookMap = sumsByBookCurrency[bookId], !bookMap.isEmpty else { continue }
            let currencySums = overviewSortedCurrencies(Set(bookMap.keys)).compactMap { currency -> OverviewBookCurrencySum? in
                guard let (income, expenses) = bookMap[currency] else { return nil }
                return OverviewBookCurrencySum(currency: currency, income: income, expenses: expenses)
            }
            details.append(OverviewBookDetail(bookName: book.name, bookId: bookId, currencySums: currencySums))
        }

        incomeByCurrency = allIncome
        expensesByCurrency = allExpenses
        bookDetails = details
        let currencies = overviewSortedCurrencies(Set(allIncome.keys).union(allExpenses.keys))
        summaryCurrencies = currencies
        if let current = scrolledSummaryCurrency, currencies.contains(current) {
            // 保持当前轮播币种
        } else {
            scrolledSummaryCurrency = currencies.first
        }
    }
}
