//
//  Setting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//  「我的」页：账本热力 + 账户热力 + 管理入口
//

import SwiftUI

struct PersonView : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("selectAccountBook") private var selectAccountBook = AccountBookHandleService.DEFAULT_NAME

    // 账本列表
    @State private var books: [AccountBookModel] = []
    // 资产账户
    @State private var accounts: [AssetAccountModel] = []
    // 正在查看的账本（只影响热力图，不切换当前账本）
    @State private var viewingBookId: UUID? = nil
    // 两张卡各自的年月
    @State private var bookYear: Int = Calendar.current.component(.year, from: Date())
    @State private var bookMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var accYear: Int = Calendar.current.component(.year, from: Date())
    @State private var accMonth: Int = Calendar.current.component(.month, from: Date())
    // 切换月份时的滑入方向
    @State private var bookDirection: Int = 1
    @State private var accDirection: Int = 1
    // 热力数据：日 -> 笔数
    @State private var bookCounts: [Int: Int] = [:]
    @State private var accountCounts: [String: [Int: Int]] = [:]
    // 账本选择
    @State private var showBookPicker = false
    // 提示
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(showCancelButton: false, sureButtonName: "我知道了")

    var body: some View {
        ZStack {
            Color("ViewBackgroundColor").ignoresSafeArea()

            NavigationView {
                VStack(spacing: 0) {
                    topBar

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            menuGroup
                            bookHeatCard
                            accountHeatCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 26)
                    }
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden()
                .background(Color("ViewBackgroundColor"))
                .selfDragBack {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationViewStyle(.stack)
            .background(Color("ViewBackgroundColor").ignoresSafeArea())
        }
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        .background(Color("ViewBackgroundColor"))
        .selfAlter(showState: $showAlter, config: alterConfig)
        .sheet(isPresented: $showBookPicker) {
            BookHeatPickerSheet(
                books: books,
                currentBookId: currentBook?.id,
                selectedId: viewingBook?.id,
                onSelect: { book in
                    viewingBookId = book.id
                    loadBookCounts()
                }
            )
        }
        .onAppear {
            loadAll()
        }
        .onChange(of: bookYear * 100 + bookMonth) { _ in
            loadBookCounts()
        }
        .onChange(of: accYear * 100 + accMonth) { _ in
            loadAccountCounts()
        }
    }

    // MARK: - 顶部栏

    private var topBar: some View {
        ZStack {
            Text("我的")
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
            }
            .padding(.leading, 13)
        }
        .frame(height: 44)
    }

    // MARK: - 账本热力

    private var bookHeatCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("账本热力")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("FontColor"))

                Spacer()

                HeatMonthSwitch(
                    year: bookYear,
                    month: bookMonth,
                    canGoNext: canShiftMonth(by: 1, year: bookYear, month: bookMonth),
                    onPrev: { shiftMonth(-1, isBook: true) },
                    onNext: { shiftMonth(1, isBook: true) }
                )
            }

            HStack(spacing: 7) {
                Button {
                    showBookPicker = true
                } label: {
                    HStack(spacing: 3) {
                        Text(viewingBook?.name ?? "账本")
                            .font(.system(size: 11.5, weight: .semibold))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color("DefaultButtonBackgroud").opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)

                if !isViewingCurrentBook {
                    Text("仅查看")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(Color("FontColorSecend"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color("FontColor").opacity(0.06), in: Capsule())
                }

                Text("共 \(bookTotal) 笔")
                    .font(.system(size: 12))
                    .foregroundColor(Color("FontColorSecend"))
                    .lineLimit(1)

                Circle()
                    .fill(Color("FontColorSecend").opacity(0.45))
                    .frame(width: 3, height: 3)

                Text("\(bookActiveDays) 天有记账")
                    .font(.system(size: 12))
                    .foregroundColor(Color("FontColorSecend"))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.top, 5)

            weekdayHeader
                .padding(.top, 14)
                .padding(.bottom, 6)

            ZStack {
                bookCalendarGrid
                    .id(bookYear * 100 + bookMonth)
                    .transition(.asymmetric(
                        insertion: .move(edge: bookDirection >= 0 ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: bookDirection >= 0 ? .leading : .trailing).combined(with: .opacity)
                    ))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: bookYear * 100 + bookMonth)
            .clipped()
            .simultaneousGesture(monthDragGesture(isBook: true))

            HStack {
                HeatLegend()
                Spacer()
                Text("单日最多 \(bookMax) 笔")
                    .font(.system(size: 10.5))
                    .foregroundColor(Color("FontColorSecend").opacity(0.85))
            }
            .padding(.top, 13)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: heatCardShadow, radius: 2, x: 0, y: 1)
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

    private var bookCalendarGrid: some View {
        let days = daysInMonth(bookYear, bookMonth)
        let offset = firstWeekdayOffset(bookYear, bookMonth)
        let total = offset + days
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                if index < offset {
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                } else {
                    bookDayCell(index - offset + 1)
                }
            }
        }
    }

    private func bookDayCell(_ day: Int) -> some View {
        let count = bookCounts[day] ?? 0
        let level = heatLevel(count)
        let future = isFuture(day: day, year: bookYear, month: bookMonth)

        return ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(future ? Color.clear : HeatPalette.color(level, colorScheme))

            if future {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color("FontColor").opacity(0.12), lineWidth: 1)
            }

            Text("\(day)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(future ? Color("FontColorSecend").opacity(0.55) : HeatPalette.ink(level, colorScheme))
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            if isToday(day: day, year: bookYear, month: bookMonth) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color("DefaultButtonBackgroud"), lineWidth: 1.5)
            }
        }
    }

    // MARK: - 账户热力

    private var accountHeatCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("账户热力")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("FontColor"))

                Spacer()

                HeatMonthSwitch(
                    year: accYear,
                    month: accMonth,
                    canGoNext: canShiftMonth(by: 1, year: accYear, month: accMonth),
                    onPrev: { shiftMonth(-1, isBook: false) },
                    onNext: { shiftMonth(1, isBook: false) }
                )
            }

            Text("每个账户当月被操作的次数，颜色越深笔数越多")
                .font(.system(size: 12))
                .foregroundColor(Color("FontColorSecend"))
                .padding(.top, 5)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(sortedAccounts) { account in
                        accountHeatRow(account)
                    }
                }
                .padding(.bottom, 10)
            }
            .id(accYear * 100 + accMonth)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: accYear * 100 + accMonth)
            .frame(maxHeight: 286)
            .padding(.top, 12)
            .simultaneousGesture(monthDragGesture(isBook: false))
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [Color("MainBackgroundColor").opacity(0), Color("MainBackgroundColor")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 22)
                .allowsHitTesting(false)
            }

            HStack {
                HeatLegend()
                Spacer()
                Text("\(accounts.count) 个账户 · \(accountTotal) 笔")
                    .font(.system(size: 10.5))
                    .foregroundColor(Color("FontColorSecend").opacity(0.85))
            }
            .padding(.top, 13)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: heatCardShadow, radius: 2, x: 0, y: 1)
    }

    private func accountHeatRow(_ account: AssetAccountModel) -> some View {
        let id = account.id.uuidString
        let counts = accountCounts[id] ?? [:]
        let days = daysInMonth(accYear, accMonth)

        return VStack(spacing: 6) {
            HStack(spacing: 7) {
                Circle()
                    .fill(accountTone(account.type))
                    .frame(width: 7, height: 7)

                Text(account.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text("\(counts.values.reduce(0, +)) 笔")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("FontColorSecend"))
                    .lineLimit(1)
                    .monospacedDigit()
            }

            HStack(spacing: 2.5) {
                ForEach(1...days, id: \.self) { day in
                    let future = isFuture(day: day, year: accYear, month: accMonth)
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                        .fill(future ? Color.clear : HeatPalette.color(heatLevel(counts[day] ?? 0), colorScheme))
                        .frame(height: 10)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            if future {
                                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                                    .strokeBorder(Color("FontColor").opacity(0.12), lineWidth: 0.8)
                            }
                        }
                }
            }
        }
    }

    // MARK: - 管理入口

    private var menuGroup: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("管理")
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(Color("FontColorSecend"))
                .padding(.leading, 4)
                .padding(.top, 10)

            VStack(spacing: 0) {
                NavigationLink {
                    AccountBookSettingComponent().environmentObject(globalModel)
                } label: {
                    PersonMenuRow(
                        icon: "book",
                        title: "账本",
                        subtitle: "共 \(books.count) 个账本",
                        tone: Color(hex: "#12C580")
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    AssetAccountSettingView().environmentObject(globalModel)
                } label: {
                    PersonMenuRow(
                        icon: "creditcard",
                        title: "资产账户",
                        subtitle: "共 \(accounts.count) 个账户",
                        tone: Color(hex: "#4696D6")
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SeeComponent().environmentObject(globalModel)
                } label: {
                    PersonMenuRow(
                        icon: "circle.lefthalf.filled",
                        title: "外观",
                        subtitle: appearanceText,
                        tone: Color(hex: "#DB9E28")
                    )
                }
                .buttonStyle(.plain)
            }
            .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func shiftMonth(_ delta: Int, isBook: Bool) {
        let currentYear = isBook ? bookYear : accYear
        let currentMonth = isBook ? bookMonth : accMonth
        var nextYear = currentYear
        var nextMonth = currentMonth + delta
        if nextMonth > 12 {
            nextMonth = 1
            nextYear += 1
        } else if nextMonth < 1 {
            nextMonth = 12
            nextYear -= 1
        }
        guard delta < 0 || canShiftMonth(by: 1, year: currentYear, month: currentMonth) else { return }
        if isBook {
            bookDirection = delta
        } else {
            accDirection = delta
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            if isBook {
                bookYear = nextYear
                bookMonth = nextMonth
            } else {
                accYear = nextYear
                accMonth = nextMonth
            }
        }
    }

    /// 允许向后翻的边界：不能进入未来月份
    private func canShiftMonth(by delta: Int, year: Int, month: Int) -> Bool {
        if delta < 0 { return true }
        let now = Calendar.current.dateComponents([.year, .month], from: Date())
        guard let nowYear = now.year, let nowMonth = now.month else { return false }
        return year < nowYear || (year == nowYear && month < nowMonth)
    }

    private func monthDragGesture(isBook: Bool) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < -60 {
                    shiftMonth(1, isBook: isBook)
                } else if value.translation.width > 60 {
                    shiftMonth(-1, isBook: isBook)
                }
            }
    }

    // MARK: - 数据

    private var currentBook: AccountBookModel? {
        if let book = globalModel.accountBook {
            return book
        }
        return books.first { $0.name == selectAccountBook }
    }

    private var viewingBook: AccountBookModel? {
        if let id = viewingBookId,
           let book = books.first(where: { $0.id == id }) {
            return book
        }
        return currentBook ?? books.first
    }

    private var isViewingCurrentBook: Bool {
        guard let viewing = viewingBook else { return true }
        return viewing.id == currentBook?.id
    }

    private var bookTotal: Int {
        bookCounts.values.reduce(0, +)
    }

    private var bookActiveDays: Int {
        bookCounts.values.filter { $0 > 0 }.count
    }

    private var bookMax: Int {
        bookCounts.values.max() ?? 0
    }

    private var accountTotal: Int {
        accountCounts.values.reduce(0) { $0 + $1.values.reduce(0, +) }
    }

    /// 账户按当月操作笔数降序，笔数相同按原有顺序
    private var sortedAccounts: [AssetAccountModel] {
        accounts.sorted { lhs, rhs in
            let lhsTotal = (accountCounts[lhs.id.uuidString] ?? [:]).values.reduce(0, +)
            let rhsTotal = (accountCounts[rhs.id.uuidString] ?? [:]).values.reduce(0, +)
            if lhsTotal != rhsTotal { return lhsTotal > rhsTotal }
            if lhs.sort != rhs.sort { return lhs.sort < rhs.sort }
            return lhs.name < rhs.name
        }
    }

    private var appearanceText: String {
        switch globalModel.darkModeSettings {
        case 1: return "浅色模式"
        case 2: return "深色模式"
        default: return "跟随系统"
        }
    }

    private var heatCardShadow: Color {
        Color.black.opacity(colorScheme == .dark ? 0.28 : 0.04)
    }

    private func accountTone(_ type: Int) -> Color {
        switch type {
        case 0: return Color(hex: "#4C8DF6")
        case 1: return Color(hex: "#C0574E")
        case 2: return Color(hex: "#4CAF50")
        case 3: return Color(hex: "#2FB3E8")
        case 4: return Color(hex: "#8B6FD1")
        default: return Color(hex: "#E0A75A")
        }
    }

    private func loadAll() {
        let loadedBooks = (try? AccountBookHandleOfCacheService.getAccountBooks(cache: globalModel)) ?? nil
        books = (loadedBooks?.values).map { Array($0) }?.sorted { $0.gmtCreated < $1.gmtCreated } ?? []

        accounts = (try? AssetAccountOfCacheService.getAccounts(cache: globalModel)) ?? globalModel.assetAccounts ?? []

        loadBookCounts()
        loadAccountCounts()
    }

    private func loadBookCounts() {
        guard let book = viewingBook else {
            bookCounts = [:]
            return
        }
        let raw = (try? AccountBookAggregateService.dayCounts(bookId: book.id.uuidString, year: bookYear, month: bookMonth)) ?? [:]
        var result: [Int: Int] = [:]
        for (dateStr, count) in raw {
            guard dateStr.count == 8, let day = Int(dateStr.suffix(2)) else { continue }
            result[day] = count
        }
        bookCounts = result
    }

    private func loadAccountCounts() {
        let records = (try? AssetAccountRecordService.getRecords(year: accYear, month: accMonth)) ?? []
        let calendar = Calendar.current
        var result: [String: [Int: Int]] = [:]
        for record in records {
            let day = calendar.component(.day, from: record.gmtCreated)
            result[record.accountId, default: [:]][day, default: 0] += 1
        }
        accountCounts = result
    }

    // MARK: - 日期

    private func daysInMonth(_ year: Int, _ month: Int) -> Int {
        let calendar = Calendar.current
        let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        return calendar.range(of: .day, in: .month, for: first)?.count ?? 30
    }

    /// 周一开始的偏移量（0 = 周一）
    private func firstWeekdayOffset(_ year: Int, _ month: Int) -> Int {
        let calendar = Calendar.current
        let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        return (calendar.component(.weekday, from: first) + 5) % 7
    }

    private func isFuture(day: Int, year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let nowYear = now.year, let nowMonth = now.month, let nowDay = now.day else {
            return false
        }
        if year != nowYear {
            return year > nowYear
        }
        if month != nowMonth {
            return month > nowMonth
        }
        return day > nowDay
    }

    private func isToday(day: Int, year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month, .day], from: Date())
        return now.year == year && now.month == month && now.day == day
    }
}

// MARK: - 热力档位与配色

/// 笔数固定档位：0 / 1 / 2 / 3-4 / 5+，跨账户、跨月份颜色含义一致
private func heatLevel(_ count: Int) -> Int {
    if count <= 0 { return 0 }
    if count == 1 { return 1 }
    if count == 2 { return 2 }
    if count <= 4 { return 3 }
    return 4
}

private enum HeatPalette {
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

// MARK: - 月份切换

private struct HeatMonthSwitch: View {
    let year: Int
    let month: Int
    let canGoNext: Bool
    let onPrev: () -> Void
    let onNext: () -> Void

    private var label: String {
        let nowYear = Calendar.current.component(.year, from: Date())
        return year == nowYear ? "\(month)月" : "\(year)年\(month)月"
    }

    var body: some View {
        HStack(spacing: 1) {
            Button(action: onPrev) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("FontColorSecend"))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(Color("FontColor"))
                .frame(minWidth: 44)
                .monospacedDigit()
                .contentTransition(.numericText())

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("FontColorSecend"))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!canGoNext)
            .opacity(canGoNext ? 1 : 0.3)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .background(Color("FontColor").opacity(0.05), in: Capsule())
    }
}

// MARK: - 图例

private struct HeatLegend: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            Text("少")
            ForEach(1...4, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(HeatPalette.color(level, colorScheme))
                    .frame(width: 9, height: 9)
            }
            Text("多")
        }
        .font(.system(size: 10.5))
        .foregroundColor(Color("FontColorSecend").opacity(0.85))
    }
}

// MARK: - 管理入口行

private struct PersonMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tone: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(tone.opacity(0.13))
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(tone)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15.5, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color("FontColorSecend"))
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("FontColorSecend").opacity(0.8))
        }
        .padding(.horizontal, 14)
        .frame(height: 60)
        .contentShape(Rectangle())
    }
}

// MARK: - 账本选择（只查看，不切换）

private struct BookHeatPickerSheet: View {
    let books: [AccountBookModel]
    let currentBookId: UUID?
    let selectedId: UUID?
    let onSelect: (AccountBookModel) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("选择要查看的账本")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Text("只切换这张热力图，不会改变当前账本")
                    .font(.system(size: 12))
                    .foregroundColor(Color("FontColorSecend"))
            }
            .padding(.horizontal, 22)
            .padding(.top, 22)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 2) {
                    ForEach(books) { book in
                        bookRow(book)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color("ViewBackgroundColor"))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func bookRow(_ book: AccountBookModel) -> some View {
        Button {
            onSelect(book)
            dismiss()
        } label: {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: book.bgColor.isEmpty ? ColorConfig.SOFT_COLORS[0] : book.bgColor))
                    Text(hexStr2Unicode(book.iconStr))
                        .font(.custom("icomoon", size: 18))
                        .foregroundColor(bookIconInk(book.bgColor))
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(book.name)
                            .font(.system(size: 14.5, weight: .semibold))
                            .foregroundColor(Color("FontColor"))
                            .lineLimit(1)

                        if book.id == currentBookId {
                            Text("当前")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color("DefaultButtonBackgroud"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("DefaultButtonBackgroud").opacity(0.12), in: Capsule())
                        }
                    }

                    if let description = book.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 11.5))
                            .foregroundColor(Color("FontColorSecend"))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                if book.id == selectedId {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// 根据封面底色选择深/浅内容色
private func bookIconInk(_ hex: String) -> Color {
    let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    guard let value = UInt64(String(cleaned.prefix(6)), radix: 16) else {
        return Color(hex: "17211B")
    }
    let r = Double((value >> 16) & 0xFF) / 255.0
    let g = Double((value >> 8) & 0xFF) / 255.0
    let b = Double(value & 0xFF) / 255.0

    func linear(_ v: Double) -> Double {
        return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
    }

    let luminance = 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    return luminance > 0.2 ? Color(hex: "17211B") : .white
}

// MARK: - 圆角扩展 (供 ViewExtensions 使用)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

