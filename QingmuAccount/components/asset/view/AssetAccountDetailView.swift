//
//  AssetAccountDetailView.swift
//  QingmuAccount
//  资产账户详情：余额头部 + 月度收支 + 笔数热力 + 流水预览 + 全部流水。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI

struct AssetAccountDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel
    @Environment(\.colorScheme) private var colorScheme
    // 宽屏（如 iPhone Duo 展开）时余额/月度统计与流水左右分栏
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isWideLayout: Bool { horizontalSizeClass == .regular }

    let accountId: String
    var onAccountChanged: () -> Void = {}

    @State private var account: AssetAccountModel? = nil
    @State private var balances: [(currency: String, totalCents: Int64)] = []
    @State private var monthRecords: [AssetAccountRecordModel] = []

    @State private var year: Int = AssetMonthMath.current.year
    @State private var month: Int = AssetMonthMath.current.month
    @State private var selectedDay: Int? = Calendar.current.component(.day, from: Date())

    @State private var showRecordEdit = false
    @State private var showAccountEdit = false
    // 流水备注编辑弹窗
    @State private var editingRemarkRecord: AssetAccountRecordModel? = nil
    @State private var showDeleteAccountAlter = false
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")
    @State private var showDatePicker = false
    @State private var datePickerType: DatePickerType = .YM
    @State private var datePickerValue = DatePickerValue()
    @StateObject private var notifaction = SelfSwiperNotification()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("ViewBackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                if isWideLayout {
                    // 宽屏：左列余额头部 + 月度统计，右列流水，两列各自独立滚动；
                    // 悬浮操作条贴右列底部居中
                    HStack(alignment: .top, spacing: 12) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                if let account = account {
                                    accountHero(account)
                                    monthSummary
                                } else {
                                    ProgressView()
                                        .padding(.top, 80)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.leading, 15)
                        .padding(.vertical, 4)
                        .padding(.bottom, 40)
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                if account != nil {
                                    flowSection
                                } else {
                                    ProgressView()
                                        .padding(.top, 80)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.trailing, 15)
                        .padding(.vertical, 4)
                        .padding(.bottom, 80)
                    }
                    .overlay(alignment: .trailing) {
                        if account != nil {
                            floatingDock
                                .padding(.bottom, 12)
                                .padding(.trailing, 15)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if let account = account {
                                accountHero(account)
                                monthSummary
                                flowSection
                            } else {
                                ProgressView()
                                    .padding(.top, 80)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 4)
                        .padding(.bottom, 126)
                    }
                }
            }

            if account != nil && !isWideLayout {
                floatingDock
                    .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { reload(resetSelection: true) }
        .onChange(of: year * 100 + month) { _ in
            loadMonthRecords(resetSelection: true)
        }
        .selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        .sheet(isPresented: $showRecordEdit) {
            AssetAccountRecordEditView(accountId: accountId, onSave: { reload(resetSelection: false) })
                .environmentObject(globalModel)
        }
        .sheet(isPresented: $showAccountEdit) {
            if let account = account {
                AssetAccountEditView(mode: .edit, account: account, onSave: { reload(resetSelection: false) })
                    .environmentObject(globalModel)
            }
        }
        .sheet(item: $editingRemarkRecord) { record in
            AssetRecordRemarkEditView(record: record, onSaved: { reload(resetSelection: false) })
                .environmentObject(globalModel)
        }
        .selfDatePicker(showState: $showDatePicker, type: $datePickerType, param: $datePickerValue) { value in
            guard let pickYear = value.year, let pickMonth = value.month else { return }
            if AssetMonthMath.isFuture(year: pickYear, month: pickMonth) {
                year = AssetMonthMath.current.year
                month = AssetMonthMath.current.month
            } else {
                year = pickYear
                month = pickMonth
            }
        }
        .selfAlter(showState: $showDeleteAccountAlter, config: deleteAccountConfig)
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    // MARK: - 顶栏

    private var topBar: some View {
        ZStack {
            Text("账户详情")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("FontColor"))

            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    keyFeedback()
                    showAccountEdit = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
        }
        .frame(height: 44)
    }

    // MARK: - 余额头部

    private func accountHero(_ account: AssetAccountModel) -> some View {
        let primary = primaryBalance
        let typeName = AssetAccountType(rawValue: account.type)?.name ?? "账户"

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                AssetAccountIconView(icon: account.icon, iconSize: 38, textCornerRadius: 13)
                    .padding(9)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .shadow(color: Color("MainShadowColor").opacity(0.12), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(account.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                        .lineLimit(1)
                    Text("\(typeName) · \(AssetCurrency.name(of: primary.currency))")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color("FontColorSecend"))
                }

                Spacer(minLength: 6)

                if sortedBalances.count > 1 {
                    Text("\(String(sortedBalances.count)) 种币")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color("DefaultButtonBackgroud").opacity(0.12), in: Capsule())
                }
            }

            Divider()
                .overlay(Color("MainShadowColor").opacity(0.08))
                .padding(.vertical, 13)

            // 多币种平铺：主币种金额稍大，其余币种等权展示
            VStack(spacing: 0) {
                ForEach(Array(sortedBalances.enumerated()), id: \.element.currency) { index, item in
                    if index > 0 {
                        Rectangle()
                            .fill(Color("MainShadowColor").opacity(0.06))
                            .frame(height: 0.7)
                    }
                    currencyBalanceRow(item, isPrimary: index == 0)
                }
            }
        }
        .padding(16)
        .background { heroBackground }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        }
        .shadow(color: Color("MainShadowColor").opacity(colorScheme == .dark ? 0.28 : 0.08), radius: 8, x: 0, y: 3)
    }

    private var heroBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("MainBackgroundColor"),
                    Color("MainBackgroundColor"),
                    Color("DefaultButtonBackgroud").opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color("DefaultButtonBackgroud").opacity(0.16))
                .frame(width: 190, height: 190)
                .blur(radius: 46)
                .offset(x: 100, y: -90)
        }
    }

    /// 单币种余额行：名称+编码居左，金额居右；主币种字号稍大
    private func currencyBalanceRow(_ item: (currency: String, totalCents: Int64), isPrimary: Bool) -> some View {
        let symbol = AssetCurrency.symbol(of: item.currency)
        let amount = SQLiteManager.money(fromCents: abs(item.totalCents))
        let negative = item.totalCents < 0
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            HStack(spacing: 5) {
                Text(AssetCurrency.name(of: item.currency))
                    .font(.system(size: isPrimary ? 14 : 13, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                    .lineLimit(1)
                Text(item.currency + (isPrimary ? " · 主币种" : ""))
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(Color("FontColorSecend"))
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(negative ? "-" + symbol : symbol)
                    .font(.system(size: isPrimary ? 16 : 13, weight: .semibold))
                Text(amount)
                    .font(.system(size: isPrimary ? 26 : 20, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .foregroundColor(negative ? Color("RedColor") : Color("FontColor"))
            .monospacedDigit()
        }
        .padding(.vertical, isPrimary ? 4 : 9)
    }

    // MARK: - 月度收支（月份导航 + 币种统计 + 热力图 合并为一张卡）

    private var monthSummary: some View {
        AssetAccountMonthSummaryView(
            year: year,
            month: month,
            totalCount: monthRecords.count,
            stats: monthCurrencyStats,
            daily: dailyStats,
            selectedDay: selectedDay,
            onSelectDay: { day in
                keyFeedback(0)
                selectedDay = day
            },
            canGoNext: AssetMonthMath.canGoNext(year: year, month: month),
            onPrev: { shiftMonth(-1) },
            onNext: { shiftMonth(1) },
            onPick: openMonthPicker
        )
    }

    // MARK: - 流水预览

    private var flowSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("流水")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Text("共 \(String(monthRecords.count)) 笔")
                    .font(.system(size: 10.5))
                    .foregroundColor(Color("FontColorSecend"))

                Spacer(minLength: 6)

                NavigationLink {
                    AssetAccountFlowView(accountId: accountId, year: year, month: month)
                        .environmentObject(globalModel)
                } label: {
                    HStack(spacing: 1) {
                        Text("查看全部")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
            .padding(.top, 4)
            .padding(.bottom, 8)

            if monthRecords.isEmpty {
                emptyFlowView
            } else {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("DefaultButtonBackgroud"))
                        .frame(width: 5, height: 5)
                    Text("\(String(year))年\(String(month))月")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color("FontColorSecend"))
                    Spacer()
                }
                .padding(.horizontal, 2)
                .padding(.top, 2)
                .padding(.bottom, 6)

                VStack(spacing: 7) {
                    ForEach(Array(monthRecords.prefix(4)), id: \.id) { record in
                        Button {
                            keyFeedback(0)
                            editingRemarkRecord = record
                        } label: {
                            AssetAccountRecordRow(record: record, showDate: true)
                        }
                        .buttonStyle(.plain)
                            .selfSwiper(id: record.id.uuidString, maxOffsetX: 62, notification: notifaction) {
                                Button {
                                    deleteRecord(record)
                                } label: {
                                    Image(systemName: "trash.circle")
                                        .frame(width: 60, height: 58)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .background(Color("RedColor"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                    }
                }
            }
        }
    }

    private var emptyFlowView: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 32))
                .foregroundColor(Color("FontColorSecend").opacity(0.55))
            Text("本月暂无流水，点下方「记一笔」添加")
                .font(.system(size: 12))
                .foregroundColor(Color("FontColorSecend"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 悬浮底部操作

    private var floatingDock: some View {
        HStack(spacing: 8) {
            Button {
                showDeleteAccountAlter = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("RedColor"))
                    .frame(width: 44, height: 44)
                    .background(Color("RedColor").opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)

            Button {
                keyFeedback()
                showRecordEdit = true
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                    Text("记一笔")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .frame(height: 46)
                .background(Color("DefaultButtonBackgroud"), in: Capsule())
                .shadow(color: Color("DefaultButtonBackgroud").opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(Color("MainBackgroundColor"), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color("MainShadowColor").opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.16), radius: 18, x: 0, y: 8)
    }

    // MARK: - 数据

    private var sortedBalances: [(currency: String, totalCents: Int64)] {
        let list: [(currency: String, totalCents: Int64)]
        if balances.isEmpty {
            let code = account?.currency ?? "CNY"
            list = [(code.isEmpty ? "CNY" : code, account?.totalCents ?? 0)]
        } else {
            list = balances.map { ($0.currency.isEmpty ? "CNY" : $0.currency, $0.totalCents) }
        }
        return list.sorted { a, b in
            if a.currency == "CNY" { return b.currency != "CNY" }
            if b.currency == "CNY" { return false }
            return a.currency < b.currency
        }
    }

    private var primaryBalance: (currency: String, totalCents: Int64) {
        sortedBalances.first ?? ("CNY", 0)
    }

    private var monthCurrencyStats: [AssetMonthCurrencyStat] {
        var codes = Set<String>()
        for r in monthRecords {
            codes.insert(r.currency.isEmpty ? "CNY" : r.currency)
        }
        return codes.sorted { a, b in
            if a == "CNY" { return b != "CNY" }
            if b == "CNY" { return false }
            return a < b
        }.map { code in
            var income: Int64 = 0
            var expense: Int64 = 0
            for r in monthRecords where (r.currency.isEmpty ? "CNY" : r.currency) == code {
                if r.moneyCents >= 0 {
                    income += r.moneyCents
                } else {
                    expense += abs(r.moneyCents)
                }
            }
            return AssetMonthCurrencyStat(code: code, incomeCents: income, expenseCents: expense)
        }
    }

    private var dailyStats: [Int: AssetDayStat] {
        let calendar = Calendar.current
        var map: [Int: AssetDayStat] = [:]
        for record in monthRecords {
            let day = calendar.component(.day, from: record.gmtCreated)
            var stat = map[day] ?? AssetDayStat()
            stat.count += 1
            if record.moneyCents >= 0 {
                stat.incomeCount += 1
            } else {
                stat.expenseCount += 1
            }
            map[day] = stat
        }
        return map
    }

    private var deleteAccountConfig: AlertComponentConfig {
        AlertComponentConfig(
            title: "删除提醒",
            desc: "确定删除该账户吗？其全部流水将一并删除，且无法恢复！",
            sureButtonName: "删除",
            topBarColorStyle: .RED,
            sureFun: { deleteAccount() }
        )
    }

    private func reload(resetSelection: Bool) {
        do {
            let accounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            account = accounts.first { $0.id.uuidString == accountId }
            balances = (try? AssetAccountBalanceService.getBalances(accountId: accountId)) ?? []
            loadMonthRecords(resetSelection: resetSelection)
            onAccountChanged()
        } catch {
            alterConfig.desc = "加载失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }

    private func loadMonthRecords(resetSelection: Bool) {
        monthRecords = (try? AssetAccountRecordOfCacheService.getMonthlyRecords(accountId: accountId, year: year, month: month)) ?? []
        if resetSelection {
            selectedDay = defaultSelectedDay()
        }
    }

    private func defaultSelectedDay() -> Int? {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month, .day], from: Date())
        if now.year == year && now.month == month {
            return now.day
        }
        return monthRecords.map { calendar.component(.day, from: $0.gmtCreated) }.max()
    }

    // MARK: - 月份

    private func shiftMonth(_ delta: Int) {
        let target = AssetMonthMath.shifted(year: year, month: month, delta: delta)
        guard !AssetMonthMath.isFuture(year: target.year, month: target.month) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            year = target.year
            month = target.month
        }
    }

    private func openMonthPicker() {
        keyFeedback()
        datePickerValue.year = year
        datePickerValue.month = month
        showDatePicker = true
    }

    // MARK: - 操作

    private func deleteRecord(_ record: AssetAccountRecordModel) {
        do {
            try AssetAccountRecordOfCacheService.deleteRecord(recordId: record.id.uuidString, cache: globalModel)
            reload(resetSelection: false)
        } catch {
            alterConfig.desc = "删除失败"
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }

    private func deleteAccount() {
        do {
            try AssetAccountOfCacheService.deleteAccount(id: accountId, cache: globalModel)
            onAccountChanged()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "删除失败"
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }
}

// MARK: - 全部流水

private struct AssetAccountFlowView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    let accountId: String

    @State private var year: Int
    @State private var month: Int
    @State private var records: [AssetAccountRecordModel] = []
    @State private var filter: AssetFlowFilter = .all
    @State private var showDatePicker = false
    @State private var datePickerType: DatePickerType = .YM
    @State private var datePickerValue = DatePickerValue()
    // 备注编辑弹窗
    @State private var editingRemarkRecord: AssetAccountRecordModel? = nil

    init(accountId: String, year: Int, month: Int) {
        self.accountId = accountId
        _year = State(initialValue: year)
        _month = State(initialValue: month)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            monthRow
            filterRow

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    if groups.isEmpty {
                        emptyView
                    } else {
                        ForEach(groups) { group in
                            daySection(group)
                        }
                        endNote
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 2)
                .padding(.bottom, 24)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { reload() }
        .onChange(of: year * 100 + month) { _ in reload() }
        .selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        .selfDatePicker(showState: $showDatePicker, type: $datePickerType, param: $datePickerValue) { value in
            guard let pickYear = value.year, let pickMonth = value.month else { return }
            if AssetMonthMath.isFuture(year: pickYear, month: pickMonth) {
                year = AssetMonthMath.current.year
                month = AssetMonthMath.current.month
            } else {
                year = pickYear
                month = pickMonth
            }
        }
        // 点击流水 → 编辑备注（弹窗内只有备注可改）
        .sheet(item: $editingRemarkRecord) { record in
            AssetRecordRemarkEditView(record: record, onSaved: { reload() })
        }
    }

    private var topBar: some View {
        ZStack {
            Text("全部流水")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("FontColor"))

            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Color.clear
                    .frame(width: 34, height: 34)
            }
            .padding(.horizontal, 14)
        }
        .frame(height: 44)
    }

    private var monthRow: some View {
        ZStack {
            AssetMonthNav(
                year: year,
                month: month,
                canGoNext: AssetMonthMath.canGoNext(year: year, month: month),
                onPrev: { shiftMonth(-1) },
                onNext: { shiftMonth(1) },
                onPick: openMonthPicker
            )

            HStack {
                Spacer()
                Text("共 \(String(records.count)) 笔")
                    .font(.system(size: 10.5))
                    .foregroundColor(Color("FontColorSecend"))
                    .padding(.trailing, 18)
            }
        }
        .frame(height: 44)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(AssetFlowFilter.allCases) { item in
                    filterChip(item)
                }
            }
            .padding(.horizontal, 15)
        }
        .padding(.bottom, 10)
    }

    private func filterChip(_ item: AssetFlowFilter) -> some View {
        let isOn = filter == item
        let count = item.count(in: records)
        return Button {
            keyFeedback()
            filter = item
        } label: {
            HStack(spacing: 3) {
                Text(item.label)
                    .font(.system(size: 12, weight: .semibold))
                Text("\(String(count))")
                    .font(.system(size: 10))
                    .opacity(0.65)
            }
            .foregroundColor(isOn ? .white : Color("FontColorSecend"))
            .padding(.horizontal, 13)
            .frame(height: 30)
            .background(isOn ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"), in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Color("MainShadowColor").opacity(isOn ? 0 : 0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func daySection(_ group: AssetFlowDayGroup) -> some View {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.month, .day], from: group.day)
        let weekday = DateUtils.transWeekDat2ChineseString(calendar.component(.weekday, from: group.day))

        return VStack(spacing: 7) {
            HStack(spacing: 6) {
                Text("\(String(comps.month ?? month))月\(String(comps.day ?? 1))日")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("FontColorSecend"))
                Text("星期\(weekday)")
                    .font(.system(size: 10))
                    .foregroundColor(Color("FontColorSecend").opacity(0.85))
                Text("\(String(group.records.count)) 笔")
                    .font(.system(size: 9.5))
                    .foregroundColor(Color("FontColorSecend").opacity(0.8))

                Spacer(minLength: 6)

                Text("支出 \(String(group.expenseCount))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("RedColor"))
                Text("收入 \(String(group.incomeCount))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            }
            .monospacedDigit()
            .padding(.horizontal, 3)

            ForEach(group.records, id: \.id) { record in
                Button {
                    keyFeedback(0)
                    editingRemarkRecord = record
                } label: {
                    AssetAccountRecordRow(record: record, showDate: false)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 32))
                .foregroundColor(Color("FontColorSecend").opacity(0.55))
            Text("没有符合条件的流水")
                .font(.system(size: 13))
                .foregroundColor(Color("FontColorSecend"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }

    private var endNote: some View {
        HStack(spacing: 9) {
            Rectangle()
                .fill(Color("MainShadowColor").opacity(0.2))
                .frame(width: 26, height: 1)
            Text("没有更多了")
                .font(.system(size: 10.5))
                .foregroundColor(Color("FontColorSecend"))
            Rectangle()
                .fill(Color("MainShadowColor").opacity(0.2))
                .frame(width: 26, height: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var filteredRecords: [AssetAccountRecordModel] {
        guard let type = filter.changeTypeValue else { return records }
        return records.filter { $0.changeType == type }
    }

    private var groups: [AssetFlowDayGroup] {
        let calendar = Calendar.current
        var map: [Date: [AssetAccountRecordModel]] = [:]
        for record in filteredRecords {
            let day = calendar.startOfDay(for: record.gmtCreated)
            map[day, default: []].append(record)
        }
        return map.keys.sorted(by: >).map { day in
            AssetFlowDayGroup(day: day, records: map[day] ?? [])
        }
    }

    private func reload() {
        records = (try? AssetAccountRecordOfCacheService.getMonthlyRecords(accountId: accountId, year: year, month: month)) ?? []
    }

    private func shiftMonth(_ delta: Int) {
        let target = AssetMonthMath.shifted(year: year, month: month, delta: delta)
        guard !AssetMonthMath.isFuture(year: target.year, month: target.month) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            year = target.year
            month = target.month
        }
    }

    private func openMonthPicker() {
        keyFeedback()
        datePickerValue.year = year
        datePickerValue.month = month
        showDatePicker = true
    }
}

// MARK: - 月度收支卡（月份导航做卡片头，币种统计 + 热力图同卡联动）

private struct AssetAccountMonthSummaryView: View {
    @Environment(\.colorScheme) private var colorScheme

    let year: Int
    let month: Int
    let totalCount: Int
    let stats: [AssetMonthCurrencyStat]
    let daily: [Int: AssetDayStat]
    let selectedDay: Int?
    let onSelectDay: (Int) -> Void
    let canGoNext: Bool
    let onPrev: () -> Void
    let onNext: () -> Void
    let onPick: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 卡片头：月份导航（管辖下方统计与热力）
            HStack(spacing: 8) {
                AssetMonthNav(
                    year: year,
                    month: month,
                    canGoNext: canGoNext,
                    onPrev: onPrev,
                    onNext: onNext,
                    onPick: onPick
                )
                Spacer(minLength: 6)
                Text("共 \(String(totalCount)) 笔")
                    .font(.system(size: 10.5))
                    .foregroundColor(Color("FontColorSecend"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("DefaultButtonBackgroud").opacity(0.055))

            Rectangle()
                .fill(Color("MainShadowColor").opacity(0.06))
                .frame(height: 0.7)

            // 币种收支统计
            statSection
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 14)

            Rectangle()
                .fill(Color("MainShadowColor").opacity(0.06))
                .frame(height: 0.7)

            // 记账热力（随月份切换联动）
            AssetAccountHeatmapView(
                year: year,
                month: month,
                daily: daily,
                totalCount: totalCount,
                selectedDay: selectedDay,
                onSelect: onSelectDay
            )
        }
        .padding(.bottom, 14)
        .assetCard()
        // 左右滑动切换上/下个月（同日历操作）
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < -30 {
                        onNext()
                    } else if value.translation.width > 30 {
                        onPrev()
                    }
                }
        )
    }

    private var statSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if stats.isEmpty {
                Text("本月暂无流水")
                    .font(.system(size: 12))
                    .foregroundColor(Color("FontColorSecend"))
                    .padding(.top, 2)
            } else {
                HStack(spacing: 6) {
                    Text("币种")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("支出")
                        .frame(width: 84, alignment: .trailing)
                    Text("收入")
                        .frame(width: 84, alignment: .trailing)
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color("FontColorSecend"))
                .padding(.horizontal, 2)

                ForEach(stats) { stat in
                    currencyRow(stat)
                }

                if stats.count > 1 {
                    Text("各币种独立统计，不做汇率换算")
                        .font(.system(size: 10))
                        .foregroundColor(Color("FontColorSecend").opacity(0.85))
                        .padding(.top, 9)
                }
            }
        }
    }

    private func currencyRow(_ stat: AssetMonthCurrencyStat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color("MainShadowColor").opacity(0.08))
                .frame(height: 0.5)

            HStack(spacing: 6) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color("DefaultButtonBackgroud").opacity(0.12))
                        Text(AssetCurrency.symbol(of: stat.code))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color("DefaultButtonBackgroud"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal, 2)
                    }
                    .frame(width: 24, height: 24)

                    Text(AssetCurrency.name(of: stat.code))
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                        .lineLimit(1)

                    Text(stat.code)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color("FontColorSecend").opacity(0.8))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(currencyAmount(stat.expenseCents, code: stat.code))
                    .frame(width: 84, alignment: .trailing)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("RedColor"))

                Text(currencyAmount(stat.incomeCents, code: stat.code))
                    .frame(width: 84, alignment: .trailing)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            }
            .padding(.horizontal, 2)
            .frame(height: 35)
            .monospacedDigit()
        }
    }

    private func currencyAmount(_ cents: Int64, code: String) -> String {
        return AssetCurrency.symbol(of: code) + SQLiteManager.money(fromCents: abs(cents))
    }
}

// MARK: - 记账热力卡

private struct AssetAccountHeatmapView: View {
    @Environment(\.colorScheme) private var colorScheme

    let year: Int
    let month: Int
    let daily: [Int: AssetDayStat]
    let totalCount: Int
    let selectedDay: Int?
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("记账热力")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                Text("共 \(String(totalCount)) 笔 · \(String(activeDays)) 天有记录")
                    .font(.system(size: 11))
                    .foregroundColor(Color("FontColorSecend"))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            weekdayHeader
                .padding(.top, 14)
                .padding(.bottom, 6)
                .padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(0..<(weekdayOffset + daysInMonth), id: \.self) { index in
                    if index < weekdayOffset {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    } else {
                        dayCell(index - weekdayOffset + 1)
                    }
                }
            }
            .padding(.horizontal, 16)

            detailStrip
                .padding(.top, 11)
                .padding(.horizontal, 16)

            HStack {
                legend
                Spacer()
                Text(maxCount > 0 ? "单日最多 \(String(maxCount)) 笔" : "本月还没有记录")
                    .font(.system(size: 10))
                    .foregroundColor(Color("FontColorSecend").opacity(0.85))
            }
            .padding(.top, 11)
            .padding(.horizontal, 16)
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 6) {
            ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { title in
                Text(title)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(Color("FontColorSecend"))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let stat = daily[day]
        let count = stat?.count ?? 0
        let level = assetHeatLevel(count)
        let future = isFuture(day)
        let selected = selectedDay == day
        let today = isToday(day)

        return Button {
            guard !future else { return }
            onSelect(day)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(AssetHeatPalette.color(future ? 0 : level, colorScheme))

                Text("\(String(day))")
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(AssetHeatPalette.ink(future ? 0 : level, colorScheme))
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .strokeBorder(Color("DefaultButtonBackgroud"), lineWidth: 2)
                } else if today {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .strokeBorder(Color("DefaultButtonBackgroud"), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(future)
    }

    private var detailStrip: some View {
        HStack(spacing: 6) {
            if let day = selectedDay {
                let stat = daily[day] ?? AssetDayStat()
                Text("\(String(month))月\(String(day))日")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Text("\(String(stat.count)) 笔")
                    .font(.system(size: 10.5))
                    .foregroundColor(Color("FontColorSecend"))
                Spacer(minLength: 6)
                if stat.count == 0 {
                    Text("当天无记录")
                        .font(.system(size: 10.5))
                        .foregroundColor(Color("FontColorSecend"))
                } else {
                    Text("支出 \(String(stat.expenseCount)) 笔")
                        .font(.system(size: 10.5))
                        .foregroundColor(Color("RedColor"))
                    Text("收入 \(String(stat.incomeCount)) 笔")
                        .font(.system(size: 10.5))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                }
            } else {
                Text("点选日期查看当天记录")
                    .font(.system(size: 11))
                    .foregroundColor(Color("FontColorSecend"))
                Spacer(minLength: 0)
            }
        }
        .monospacedDigit()
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(Color("FontColor").opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var legend: some View {
        HStack(spacing: 4) {
            Text("少")
            ForEach(1...4, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(AssetHeatPalette.color(level, colorScheme))
                    .frame(width: 9, height: 9)
            }
            Text("多")
        }
        .font(.system(size: 10))
        .foregroundColor(Color("FontColorSecend").opacity(0.85))
    }

    private var daysInMonth: Int {
        let calendar = Calendar.current
        let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        return calendar.range(of: .day, in: .month, for: first)?.count ?? 30
    }

    private var weekdayOffset: Int {
        let calendar = Calendar.current
        let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        return (calendar.component(.weekday, from: first) + 5) % 7
    }

    private var activeDays: Int {
        daily.values.filter { $0.count > 0 }.count
    }

    private var maxCount: Int {
        daily.values.map { $0.count }.max() ?? 0
    }

    private func isToday(_ day: Int) -> Bool {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return comps.year == year && comps.month == month && comps.day == day
    }

    private func isFuture(_ day: Int) -> Bool {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        guard let nowYear = comps.year, let nowMonth = comps.month, let nowDay = comps.day else {
            return false
        }
        if year != nowYear { return year > nowYear }
        if month != nowMonth { return month > nowMonth }
        return day > nowDay
    }
}

// MARK: - 流水行

private struct AssetAccountRecordRow: View {
    let record: AssetAccountRecordModel
    let showDate: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tone.opacity(0.12))
                Image(systemName: symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(tone)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(changeType.name)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color("FontColorSecend"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            // 右上角时间，金额在其下方右对齐
            VStack(alignment: .trailing, spacing: 3) {
                Text(timeText)
                    .font(.system(size: 9.5))
                    .foregroundColor(Color("FontColorSecend"))
                    .monospacedDigit()
                    .fixedSize()
                Text(amountText)
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundColor(record.moneyCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: 140, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 58)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        }
    }

    private var changeType: AssetRecordChangeType {
        AssetRecordChangeType(rawValue: record.changeType) ?? .adjust
    }

    private var tone: Color {
        switch changeType {
        case .transferIn: return Color("DefaultButtonBackgroud")
        case .transferOut: return Color("RedColor")
        case .transfer: return Color(hex: "#3B82F6")
        case .adjust: return Color(hex: "#E09A20")
        }
    }

    private var symbolName: String {
        switch changeType {
        case .transferIn: return "arrow.down.left"
        case .transferOut: return "arrow.up.right"
        case .transfer: return "arrow.left.arrow.right"
        case .adjust: return "slider.horizontal.3"
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        if !record.remark.isEmpty {
            parts.append(record.remark)
        }
        if !record.relatedAccountName.isEmpty {
            let verb = record.moneyCents >= 0 ? "转入从" : "转出至"
            parts.append(verb + record.relatedAccountName)
        }
        return parts.isEmpty ? "账户变更" : parts.joined(separator: " · ")
    }

    private var timeText: String {
        DateUtils.transDate2String(record.gmtCreated, format: showDate ? "MM-dd HH:mm" : "HH:mm")
    }

    private var amountText: String {
        let code = record.currency.isEmpty ? "CNY" : record.currency
        let value = SQLiteManager.money(fromCents: abs(record.moneyCents))
        return (record.moneyCents >= 0 ? "+" : "-") + AssetCurrency.symbol(of: code) + value
    }
}

// MARK: - 流水备注编辑（仅备注可改，金额/类型/时间不可编辑）

private struct AssetRecordRemarkEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    let record: AssetAccountRecordModel
    var onSaved: () -> Void = {}

    @State private var remark = ""
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")

    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderComponent(title: "编辑备注")

            // 流水信息（只读展示）
            AssetAccountRecordRow(record: record, showDate: true)
                .padding(.horizontal, 15)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // 备注（唯一可编辑项）
            HStack(spacing: 8) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                TextField("备注（选填）", text: $remark)
                    .font(.system(size: 15))
                    .foregroundColor(Color("FontColor"))
                    .onTapGesture { toHideKeyboard() }
            }
            .padding(.horizontal, 16)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 54)
            .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
            )
            .padding(.horizontal, 15)

            Spacer()

            // 悬浮保存按钮
            Button {
                save()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                    Text("保存")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 44)
                .frame(height: 50)
                .background(Color("DefaultButtonBackgroud"), in: Capsule())
                .shadow(color: Color("DefaultButtonBackgroud").opacity(0.35), radius: 10, x: 0, y: 6)
            }
            .padding(.bottom, 20)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .onTapGesture { toHideKeyboard() }
        .onAppear { remark = record.remark }
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    private func save() {
        keyFeedback()
        do {
            try AssetAccountRecordOfCacheService.updateRecordRemark(
                recordId: record.id.uuidString, remark: StringUtils.trim(remark), cache: globalModel)
            onSaved()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            alterConfig.topBarColorStyle = .RED
            showAlter = true
        }
    }
}

// MARK: - 月份导航

private struct AssetMonthNav: View {
    let year: Int
    let month: Int
    let canGoNext: Bool
    let onPrev: () -> Void
    let onNext: () -> Void
    let onPick: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            Button(action: onPrev) {
                chevron("chevron.left")
            }
            .buttonStyle(.plain)

            Button(action: onPick) {
                HStack(spacing: 3) {
                    Text("\(String(year))年\(String(month))月")
                        .font(.system(size: 15.5, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                        .monospacedDigit()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color("FontColorSecend"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color("FontColor").opacity(0.05), in: Capsule())
            }
            .buttonStyle(.plain)

            Button(action: onNext) {
                chevron("chevron.right")
            }
            .buttonStyle(.plain)
            .disabled(!canGoNext)
            .opacity(canGoNext ? 1 : 0.28)
        }
    }

    private func chevron(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(Color("FontColorSecend"))
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
    }
}

// MARK: - 数据模型

private struct AssetMonthCurrencyStat: Identifiable {
    let code: String
    let incomeCents: Int64
    let expenseCents: Int64

    var id: String { code }
}

private struct AssetDayStat {
    var count = 0
    var incomeCount = 0
    var expenseCount = 0
}

private enum AssetFlowFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case transferIn = "in"
    case transferOut = "out"
    case transfer = "transfer"
    case adjust = "adjust"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "全部"
        case .transferIn: return "转入"
        case .transferOut: return "转出"
        case .transfer: return "转移"
        case .adjust: return "调账"
        }
    }

    var changeTypeValue: Int? {
        switch self {
        case .all: return nil
        case .transferIn: return AssetRecordChangeType.transferIn.rawValue
        case .transferOut: return AssetRecordChangeType.transferOut.rawValue
        case .transfer: return AssetRecordChangeType.transfer.rawValue
        case .adjust: return AssetRecordChangeType.adjust.rawValue
        }
    }

    func count(in records: [AssetAccountRecordModel]) -> Int {
        guard let type = changeTypeValue else { return records.count }
        return records.filter { $0.changeType == type }.count
    }
}

private struct AssetFlowDayGroup: Identifiable {
    let day: Date
    let records: [AssetAccountRecordModel]

    var id: Date { day }
    var incomeCount: Int { records.filter { $0.moneyCents >= 0 }.count }
    var expenseCount: Int { records.filter { $0.moneyCents < 0 }.count }
}

// MARK: - 月份计算

private enum AssetMonthMath {
    static var current: (year: Int, month: Int) {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return (comps.year ?? 2026, comps.month ?? 1)
    }

    static func isFuture(year: Int, month: Int) -> Bool {
        let now = current
        return year > now.year || (year == now.year && month > now.month)
    }

    /// 是否还能切换到下个月（当前已是当月时不可再往后）
    static func canGoNext(year: Int, month: Int) -> Bool {
        let next = shifted(year: year, month: month, delta: 1)
        return !isFuture(year: next.year, month: next.month)
    }

    static func shifted(year: Int, month: Int, delta: Int) -> (year: Int, month: Int) {
        let calendar = Calendar.current
        guard let base = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let target = calendar.date(byAdding: .month, value: delta, to: base) else {
            return (year, month)
        }
        let comps = calendar.dateComponents([.year, .month], from: target)
        return (comps.year ?? year, comps.month ?? month)
    }
}

// MARK: - 热力档位与配色（与「我的」页账本热力同口径）

private func assetHeatLevel(_ count: Int) -> Int {
    if count <= 0 { return 0 }
    if count == 1 { return 1 }
    if count == 2 { return 2 }
    if count <= 4 { return 3 }
    return 4
}

private enum AssetHeatPalette {
    static func color(_ level: Int, _ scheme: ColorScheme) -> Color {
        switch level {
        case 1:
            return Color(hex: scheme == .dark ? "#1A4234" : "#C9EDDA")
        case 2:
            return Color(hex: scheme == .dark ? "#1F6249" : "#8FDFC0")
        case 3:
            return Color(hex: scheme == .dark ? "#278D67" : "#46C996")
        case 4:
            return Color(hex: scheme == .dark ? "#45C391" : "#0FAE74")
        default:
            return scheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.055)
        }
    }

    static func ink(_ level: Int, _ scheme: ColorScheme) -> Color {
        if level >= 2 {
            return scheme == .dark ? Color(hex: "#EAFAF2") : Color(hex: "#06271A")
        }
        return Color("FontColorSecend")
    }
}

// MARK: - 卡片样式

private struct AssetCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.04), radius: 3, x: 0, y: 1)
    }
}

private extension View {
    func assetCard() -> some View {
        modifier(AssetCardStyle())
    }
}
