//
//  AccountBookBudgetSettingComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2024/1/16.
//

import SwiftUI
import Combine

struct AccountBookBudgetSettingComponent: View {
    @EnvironmentObject var globalModel:GlobalModel
    // 预置币种（nil 用账本默认币种）
    var initCurrency: String? = nil
    // 预置年月 yyyyMM（nil 用当前月）
    var initYm: String? = nil
    // 预填金额
    var thisMothBugget = ""
    // 保存 (金额, 币种, yyyyMM)
    var saveBudgetSeting : (String, String, String) -> Void = {_,_,_ in }

    // 选择的币种
    @State private var selectedCurrency:String = "CNY"
    // 选择的年月 yyyyMM
    @State private var selectedYm:String = ""
    // 设置预算的参数-预算金额
    @State private var setingBugget = ""

    // 年月选择器
    @State private var showYmPicker = false
    @State private var ymPickerType:DatePickerType = .YM
    @State private var ymPickerParam:DatePickerValue = DatePickerValue()

    // 选中年月展示文案
    var selectedYmText: String {
        guard selectedYm.count == 6,
              let y = Int(selectedYm.prefix(4)),
              let m = Int(selectedYm.suffix(2)) else { return "" }
        return "\(y)年\(m)月"
    }

    var body: some View {
        VStack(spacing: 18) {
            SheetHeaderComponent(title: "设置预算")
            // 币种
            VStack(alignment: .leading, spacing: 10) {
                Text("币种")
                    .font(.system(size: 14, weight: .bold))
                currencyGrid
            }
            // 年月
            VStack(alignment: .leading, spacing: 8) {
                Text("年月")
                    .font(.system(size: 14, weight: .bold))
                ymSelector
            }
            // 金额
            VStack(alignment: .leading, spacing: 8) {
                Text("预算金额")
                    .font(.system(size: 14, weight: .bold))
                amountInput
            }
            Spacer()
            saveButton
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .ignoresSafeArea()
        .onTapGesture {
            toHideKeyboard()
        }
        .onAppear() {
            let defaultCurrency = globalModel.accountBook?.defaultCurrency ?? "CNY"
            selectedCurrency = initCurrency ?? defaultCurrency
            selectedYm = initYm ?? DateUtils.transDate2String(Date(), format: "yyyyMM")
            setingBugget = thisMothBugget
        }
        .selfDatePicker(showState: $showYmPicker, type: $ymPickerType, param: $ymPickerParam) { value in
            if let y = value.year, let m = value.month {
                selectedYm = ymStrOf(y, m)
            }
        }
    }

    // 币种选择（10 种币型，4 列网格平铺）
    var currencyGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(AssetCurrency.allCases, id:\.self) { currency in
                currencyCell(currency)
            }
        }
    }

    func currencyCell(_ currency:AssetCurrency) -> some View {
        let selected = selectedCurrency == currency.rawValue
        return VStack(spacing: 3) {
            Text(currency.name)
                .font(.system(size: 14, weight: selected ? .bold : .regular))
                .foregroundColor(selected ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(currency.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(selected ? .white.opacity(0.85) : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(selected ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("MainShadowColor").opacity(selected ? 0 : 0.1), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedCurrency = currency.rawValue
        }
    }

    // 年月选择
    var ymSelector: some View {
        Button {
            ymPickerParam.year = Int(selectedYm.prefix(4))
            ymPickerParam.month = Int(selectedYm.suffix(2))
            showYmPicker = true
        } label: {
            HStack(spacing: 6) {
                Text(selectedYmText.isEmpty ? "选择年月" : selectedYmText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // 金额输入
    var amountInput: some View {
        HStack(spacing: 8) {
            Text(AssetCurrency.symbol(of: selectedCurrency))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("DefaultButtonBackgroud"))
            TextField("输入预算金额", text: $setingBugget)
                .multilineTextAlignment(.center)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color("DefaultButtonBackgroud"))
                .keyboardType(.decimalPad)
                .onReceive(Just(setingBugget)) { newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    let pointIndex = inclusePointIndex(filtered)
                    let lastPointIndex = lastPointIndex(filtered)
                    if (pointIndex == 0) {
                        self.setingBugget = "0."
                        return
                    }
                    if (pointIndex != lastPointIndex ) {
                        self.setingBugget = String(filtered[filtered.startIndex...filtered.index(filtered.startIndex, offsetBy: (lastPointIndex-1))])
                    } else if (pointIndex > -1 && filtered.count - pointIndex > 2) {
                        self.setingBugget = String(filtered[filtered.startIndex...filtered.index(filtered.startIndex, offsetBy: (pointIndex + 2))])
                    } else {
                        self.setingBugget = filtered
                    }
                }
        }
        .padding(10)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
    }

    var saveButton: some View {
        Button {
            toHideKeyboard()
            saveBudgetSeting(setingBugget, selectedCurrency, selectedYm)
        } label: {
            Text("保存").tint(.white)
                .frame(width: 250, height: 50, alignment: .center)
                .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    func ymStrOf(_ y:Int, _ m:Int) -> String {
        let monthStr = m < 10 ? String("0\(m)") : String("\(m)")
        return String("\(y)\(monthStr)")
    }

    /**
     计算小数点位置
     */
    func inclusePointIndex(_ value:String) -> Int {
        let p = value.firstIndex(of: ".")
        if let a = p {
            return a.utf16Offset(in: value)
        }
        return -1
    }

    func lastPointIndex(_ value:String) -> Int {
        let p = value.lastIndex(of: ".")
        if let a = p {
            return a.utf16Offset(in: value)
        }
        return -1
    }
}
