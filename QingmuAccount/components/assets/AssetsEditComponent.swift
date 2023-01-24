//
//  AssetsEditComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/29.
//

import SwiftUI
import Combine

struct AssetsEditComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 用于关闭当前窗口
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 存款
    @Binding var depositValue:Decimal
    // 负债
    @Binding var liabilitiesValue:Decimal
    // 用于重新更新数据
    @Binding var lastUpdateTime:Date
    // 类型，true:负债，false:存款
    @State private var typeToggle : Bool = false
    // 类型，true:减少，false:增加
    @State private var payToggle : Bool = false
    // 金额
    @State private var setingValue: String = ""
    // 账目
    @State private var accountName: String = ""
    // 项目
    @State private var itemName: String = ""
    // 显示数据获取
    @State private var showDataPickerOfdeposit:Bool = false
    @State private var showDataPickerOfliabilities:Bool = false
    // 选取的数据
    @State private var dataPickerValue:DataPickerValue = DataPickerValue()
    // 选取数据集合
    @State private var pickerDatasOfdeposit:[DataPickerValue] = []
    @State private var pickerDatasOfliabilities:[DataPickerValue] = []
    
    @State private var assertsData:AssertsData = AssertsData()
    
    var body: some View {
        VStack {
            HStack {
                Text(typeToggle ? "负债" : "存款").font(.system(size: 16, weight: .bold))
                Spacer()
                SelfToggle(offColor:Color("DefaultButtonBackgroud"),onColor:Color("RedColor"),isOn: $typeToggle) { value in
                    closeAll()
                }
            }.padding(10)
            .frame(height: 50)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            HStack {
                Text(payToggle ? "减" : "增").font(.system(size: 16, weight: .bold))
                Spacer()
                SelfToggle(offColor:Color("DefaultButtonBackgroud"),onColor:Color("RedColor"),isOn: $payToggle)
            }.padding(10)
            .frame(height: 50)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            HStack {
                Text("账目").font(.system(size: 16, weight: .bold))
                Spacer()
                TextField("账目",text: $accountName)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 16, weight: .bold))
                    .onTapGesture {
                        closeAllDataPicker()
                    }
                Image(systemName: "text.book.closed")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        showSelectAccount()
                    }
            }.padding(10)
            .frame(height: 50)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            HStack {
                Text("项目").font(.system(size: 16, weight: .bold))
                Spacer()
                TextField("项目",text: $itemName)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 16, weight: .bold))
                    .onTapGesture {
                        closeAllDataPicker()
                    }
            }.padding(10)
            .frame(height: 50)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            HStack {
                Text("金额").font(.system(size: 16, weight: .bold))
                Spacer()
                TextField("金额",text: $setingValue)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .keyboardType(.decimalPad)
                    .onTapGesture {
                        closeAllDataPicker()
                    }
                    .onReceive(Just(setingValue)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        let pointIndex = inclusePointIndex(filtered)
                        let lastPointIndex = lastPointIndex(filtered)
                        if (pointIndex == 0) {
                            self.setingValue = "0."
                            return
                        }
                        if (pointIndex != lastPointIndex ) {
                            self.setingValue = String(filtered[filtered.startIndex...filtered.index(filtered.startIndex, offsetBy: (lastPointIndex-1))])
                        } else if (pointIndex > -1 && filtered.count - pointIndex > 2) {
                            self.setingValue = String(filtered[filtered.startIndex...filtered.index(filtered.startIndex, offsetBy: (pointIndex + 2))])
                        } else {
                            self.setingValue = filtered
                        }
                       
                    }
            }.padding(10)
            .frame(height: 50)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            Spacer()
            Button {
                saveData()
            } label: {
                HStack {
                    Text("保存")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                        .padding(.vertical, 15)
                }.frame(width: 250, height: 50, alignment: .center)
                    .background(Color("DefaultButtonBackgroud").opacity(canSave() ? 1: ColorConfig.UNABLE_COLOR_OPCITY), in: RoundedRectangle(cornerRadius: 10))
            }.disabled(!canSave())
                .padding(.bottom, 30)
            
        }.padding(.horizontal,15)
            .padding(.top,10)
            .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .ignoresSafeArea()
            .background(Color("ViewBackgroundColor"))
            .onTapGesture {
                toHideKeyboard()
            }
            .selfDataPicker(showState: $showDataPickerOfdeposit, param: $dataPickerValue, datas: $pickerDatasOfdeposit) { newValue in
                dataPickerValue = newValue
                accountName = newValue.data ?? ""
            }
            .selfDataPicker(showState: $showDataPickerOfliabilities, param: $dataPickerValue, datas: $pickerDatasOfliabilities) { newValue in
                dataPickerValue = newValue
                accountName = newValue.data ?? ""
            }.onAppear() {
                loadData()
                resetShowDataPicker()
            }
            
    }
    // 加载数据
    func loadData() {
        var assertsData:AssertsData? = nil
        do {
            assertsData = try AssertsDataCacheService.getAsserts(cache: globalModel)
        } catch {
            
        }
        if let assertsDataReal = assertsData {
            self.assertsData = assertsDataReal
            resetShowDataPicker()
        }
    }
    // 选择账户的显示
    func showSelectAccount() {
        toHideKeyboard()
        if (typeToggle) {
            // 负债
            if  self.pickerDatasOfliabilities.count > 0 {
                self.showDataPickerOfliabilities = true
            }
        } else {
            // 存款
            if  self.pickerDatasOfdeposit.count > 0 {
                self.showDataPickerOfdeposit = true
            }
        }
    }
    // 重置数据的选择集合
    func resetShowDataPicker() {
        
        // 负债
        var pickerDatasTemp:[DataPickerValue] = []
        for keyItem in self.assertsData.liabilities.keys {
            pickerDatasTemp.append(DataPickerValue(key: UUID().description,data: keyItem))
        }
        self.pickerDatasOfliabilities = pickerDatasTemp
        
        // 存款
        var pickerDatasTemp1:[DataPickerValue] = []
        for keyItem in self.assertsData.deposit.keys {
            pickerDatasTemp1.append(DataPickerValue(key: UUID().description,data: keyItem))
        }
        self.pickerDatasOfdeposit = pickerDatasTemp1
        
    }
    // 关闭其它的窗口
    func closeAll() {
        toHideKeyboard()
        closeAllDataPicker()
    }
    
    func closeAllDataPicker() {
        showDataPickerOfdeposit = false
        showDataPickerOfliabilities = false
    }
    // 是否可以进进行保存操作
    func canSave() -> Bool {
        return self.accountName.count > 0 && self.itemName.count > 0 && self.setingValue.count > 0 &&
        self.setingValue != "0." && self.setingValue != "0" && self.setingValue != "0.0" && self.setingValue != "0.00"
    }
    // 保存操作
    func saveData() {
        let recordDataItem = AssertsDataItem(
            accountName: self.accountName,
            itemName: self.itemName,
            gmtCreated: Date(),
            gmtModfied: Date(),
            type: self.payToggle ? 0 : 1,
            money: self.setingValue
        )
        
        let ymStr = DateUtils.ymStr(Date())
        if (self.typeToggle) {
            // 负债
            var liabilitiesDataTemp = self.assertsData.liabilitiesData[ymStr] ?? []
            liabilitiesDataTemp.append(recordDataItem)
            self.assertsData.liabilitiesData[ymStr] = liabilitiesDataTemp
            
            var liabilitiesTemp = self.assertsData.liabilities[recordDataItem.accountName] ?? "0.0"
            if (self.payToggle) {
                // 减少
                liabilitiesTemp = DecimalUtils.trans2StringOfCurrency((Decimal(string: liabilitiesTemp) ?? 0) - (Decimal(string: self.setingValue) ?? 0))
            } else {
                // 增加
                liabilitiesTemp = DecimalUtils.trans2StringOfCurrency((Decimal(string: liabilitiesTemp) ?? 0) + (Decimal(string: self.setingValue) ?? 0))
            }
            
            self.assertsData.liabilities[recordDataItem.accountName] = liabilitiesTemp
        } else {
            // 存款
            var depositDataTemp = self.assertsData.depositData[ymStr] ?? []
            depositDataTemp.append(recordDataItem)
            self.assertsData.depositData[ymStr] = depositDataTemp
            
            var depositTemp = self.assertsData.deposit[recordDataItem.accountName] ?? "0.0"
            if (self.payToggle) {
                // 减少
                depositTemp = DecimalUtils.trans2StringOfCurrency((Decimal(string: depositTemp) ?? 0) - (Decimal(string: self.setingValue) ?? 0))
            } else {
                // 增加
                depositTemp = DecimalUtils.trans2StringOfCurrency((Decimal(string: depositTemp) ?? 0) + (Decimal(string: self.setingValue) ?? 0))
            }
            self.assertsData.deposit[recordDataItem.accountName] = depositTemp
        }
        do {
            try AssertsDataCacheService.updateAsserts(self.assertsData, cache: globalModel)
            lastUpdateTime = Date()
            presentationMode.wrappedValue.dismiss()
        } catch {
            
        }
        
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
