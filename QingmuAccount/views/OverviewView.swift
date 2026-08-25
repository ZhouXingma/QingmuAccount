//
//  OverviewView.swift
//  QingmuAccount
//
//  概览主视图
//  Created by 周荥马 on 2024/7/3.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var globalModel: GlobalModel

    @State private var year: Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    @State private var month: Int = -1
    @State private var thisYear: Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    @State private var thisMonth: Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    @State private var mode: Int = 0

    @State private var showYearPicker = false
    @State private var showYearPickerType: DatePickerType = .Y
    @State private var pickerYearDefaultValue = DatePickerValue()

    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            topBar

            // 内容区
            Group {
                if mode == 0 {
                    YearlyOverviewComponent(year: $year, thisYear: $thisYear)
                        .environmentObject(globalModel)
                } else {
                    MonthlyOverviewComponent(year: $year, month: $month,
                                              thisYear: $thisYear, thisMonth: $thisMonth)
                        .environmentObject(globalModel)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color("ViewBackgroundColor"))
        .selfDatePicker(showState: $showYearPicker, type: $showYearPickerType,
                         param: $pickerYearDefaultValue) { newValue in
            if let newYear = newValue.year, year != newYear {
                year = newYear
            }
        }
    }

    var topBar: some View {
        HStack {
            Text("\(String(year))年")
                .font(.system(size: 24, weight: .bold))
                .onTapGesture {
                    pickerYearDefaultValue.year = year
                    showYearPicker = true
                }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.leading, 2)
            Spacer()
            HStack(spacing: 0) {
                segmentButton(title: "年度", isSelected: mode == 0) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        mode = 0
                        month = -1
                    }
                }
                segmentButton(title: "月度", isSelected: mode == 1) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        mode = 1
                        month = thisMonth
                    }
                }
            }
            .padding(3)
            .background(Color("MainBackgroundColor"), in: Capsule())
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }

    func segmentButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : Color("FontColorSecend"))
                .frame(width: 50, height: 28)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color("DefaultButtonBackgroud"))
                    }
                }
        }
    }
}
