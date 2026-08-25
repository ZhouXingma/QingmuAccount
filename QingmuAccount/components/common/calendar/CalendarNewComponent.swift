//
//  CalendarNewComponent.swift
//  QingmuAccount - 全新日历组件（样式与动画优化版，暂保留用于对比/回滚）
//
//  Created by 周荥马 on 2026/8/15.
//

import SwiftUI

/// 全新日历组件：更清爽的样式 + 平滑切换动画。
/// 复用 CalendarShowData / CalendarDateModel 数据契约，父组件通过 monthDataHandle 填充每日金额。
struct CalendarNewComponent : View {
    private let weekTitles = ["日","一","二","三","四","五","六"]
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var monthDataHandle:(CalendarShowData)->Void = {_ in }
    @Binding var year:Int
    @Binding var month:Int
    @Binding var selectDate:Date
    // 最后加载时间
    @Binding var latestLoadTime:Date

    @State private var calendarShowData:CalendarShowData = CalendarShowData()
    // 月份切换方向：-1 上个月，1 下个月（用于过渡动画）
    @State private var direction:Int = 0

    // 当前月份的标识，用于触发切换动画
    private var monthKey:Int {
        year * 12 + month
    }

    var body: some View {
        VStack(spacing: 8) {
            headerView
            weekdayRow
            monthGridView
        }
        .padding(.vertical, 4)
        .onChange(of: latestLoadTime, perform: { newValue in
            rebuild()
        })
        .onAppear() {
            rebuild()
        }
    }
    // 头部：年月 + 左右切换按钮
    var headerView: some View {
        HStack {
            Button {
                changeMonth(delta: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            Spacer()
            Text("\(String(year))年\(month)月")
                .font(.system(size: 15, weight: .bold))
                .contentTransition(.numericText())
            Spacer()
            Button {
                changeMonth(delta: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 6)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: monthKey)
    }
    // 星期标题行
    var weekdayRow: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(weekTitles.enumerated()), id:\.offset) { index, title in
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(weekdayColor(column: index))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
            }
        }
    }
    // 月份网格（带切换过渡动画）
    var monthGridView: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(calendarShowData.show.datas.indices, id:\.self) { index in
                    dayCell(calendarShowData.show.datas[index], column: index % 7)
                }
            }
            .id(monthKey)
            .transition(.asymmetric(
                insertion: .move(edge: direction >= 0 ? .trailing : .leading).combined(with: .opacity),
                removal: .move(edge: direction >= 0 ? .leading : .trailing).combined(with: .opacity)
            ))
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: monthKey)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -60 {
                        changeMonth(delta: 1)
                    } else if value.translation.width > 60 {
                        changeMonth(delta: -1)
                    }
                }
        )
    }
    // 单个日期格子
    func dayCell(_ model:CalendarDateModel, column:Int) -> some View {
        let selected = model.isSelectedDay(selectDate)
        return VStack(spacing: 3) {
            Text("\(model.dayValue)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(dayNumberColor(model: model, column: column, selected: selected))
            Text(model.isCurrentMonth ? model.desc : " ")
                .font(.system(size: 9))
                .foregroundColor(amountColor(desc: model.desc, selected: selected))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            cellBackground(model: model, selected: selected),
            in: RoundedRectangle(cornerRadius: 10)
        )
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("DefaultButtonBackgroud").opacity(0.4), lineWidth: 1.5)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if model.isSelectedDay(selectDate) {
                    selectDate = Date()
                } else {
                    selectDate = model.day
                }
            }
        }
    }
    // 日期数字颜色
    func dayNumberColor(model:CalendarDateModel, column:Int, selected:Bool) -> Color {
        if selected {
            return .white
        }
        if !model.isCurrentMonth {
            return Color("FontColor").opacity(0.25)
        }
        if model.isToday {
            return Color("DefaultButtonBackgroud")
        }
        return weekdayColor(column: column)
    }
    // 格子背景
    func cellBackground(model:CalendarDateModel, selected:Bool) -> Color {
        if selected {
            return Color("DefaultButtonBackgroud")
        }
        if model.isToday {
            return Color("DefaultButtonBackgroud").opacity(0.12)
        }
        return Color.clear
    }
    // 金额颜色：净支出（负数）偏红
    func amountColor(desc:String, selected:Bool) -> Color {
        if selected {
            return .white.opacity(0.85)
        }
        if desc.hasPrefix("-") {
            return Color(red: 0.92, green: 0.35, blue: 0.35)
        }
        return Color("FontColor").opacity(0.55)
    }
    // 星期/周末颜色：周日红、周六蓝
    func weekdayColor(column:Int) -> Color {
        if column == 0 {
            return Color(red: 0.92, green: 0.35, blue: 0.35)
        }
        if column == 6 {
            return Color(red: 0.35, green: 0.55, blue: 0.92)
        }
        return Color("FontColor")
    }
    // 刷新数据
    func rebuild() {
        calendarShowData = createCalendarShowData(year: year, month: month)
        monthDataHandle(calendarShowData)
    }
    // 切换月份
    func changeMonth(delta:Int) {
        direction = delta
        var newYear = year
        var newMonth = month + delta
        if newMonth < 1 {
            newMonth = 12
            newYear -= 1
        }
        if newMonth > 12 {
            newMonth = 1
            newYear += 1
        }
        year = newYear
        month = newMonth
        rebuild()
    }
}

struct CalendarNewComponent_Previews: PreviewProvider {
    static var previews: some View {
        CalendarNewComponent(year: .constant(2026), month: .constant(8), selectDate: .constant(Date()), latestLoadTime: .constant(Date()))
            .previewDevice("iPhone 17 Pro")
            .preferredColorScheme(.light)
    }
}
