//
//  DatePickerComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/4.
//

import SwiftUI

struct DatePickerStyle: ViewModifier {
    @Binding var showState:Bool
    @Binding var type:DatePickerType
    @Binding var param:DatePickerValue
    var sureAction: (DatePickerValue) -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            if (showState) {
                if (type == .YMD) {
                    YmdDatePickerComponent(showState:$showState, param: $param, pickerSure: sureAction)
                } else if (type == .YM) {
                    YmDatePickerComponent(showState:$showState, param: $param, pickerSure: sureAction)
                } else if (type == .Y) {
                    YearDatePickerComponent(showState: $showState, param: $param, pickerSure: sureAction)
                }
            }
        }.ignoresSafeArea()
    }
}

struct DataPickerStyle: ViewModifier {
    @Binding var showState:Bool
    @Binding var param:DataPickerValue
    @Binding var datas:[DataPickerValue]
    var sureAction: (DataPickerValue) -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            if (showState) {
                if (datas.count > 0) {
                    DataPickerComponent(showState: $showState, param: $param, datas: $datas, pickerSure: sureAction)
                }
            }
        }.ignoresSafeArea()
    }
}

extension View {
    func selfDatePicker(showState:Binding<Bool>, type:Binding<DatePickerType>, param:Binding<DatePickerValue>, sureAction:@escaping (DatePickerValue) -> Void = {a in }) -> some View {
        modifier(DatePickerStyle(showState:showState, type:type, param:param, sureAction:sureAction))
    }
    
    func selfDataPicker(showState:Binding<Bool>,param:Binding<DataPickerValue>,
                        datas:Binding<[DataPickerValue]>, sureAction:@escaping (DataPickerValue) -> Void = {a in })  -> some View {
        modifier(DataPickerStyle(showState:showState,param:param, datas:datas, sureAction:sureAction))
    }
}
