//
//  AssertsDetailComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2023/1/19.
//

import SwiftUI
struct AssertsDetailComponent:View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    // 要显示的详情
    @Binding var showDetailItem:String
    // 类型
    @Binding var type:Int
    // 最后更新的时间
    @Binding var lastUpdateTime:Date
    // 总金额
    @State private var totalMoney:String = "-"
    // 年份
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 数据
    @State private var showDatas:[AssertsDataItem] = []
    // 选择年份组建显示
    @State private var showYearPicker = false
    // 选择年份的数据
    @State private var showYearPickerType : DatePickerType = .Y
    // 选择年份的默认数据
    @State private var pickerYearDefaultValue: DatePickerValue = DatePickerValue()
    // 分页获取的年和月
    @State private var pageYear:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 列表滑动通知
    @StateObject var notifaction = SelfSwiperNotification()
    // 显示通知
    @State var showAlter:Bool = false
    // 显示加载
    @State var showLoading:Bool = false
    // 显示通知的配置信息
    @State var alterComponentConfig:AlertComponentConfig =  AlertComponentConfig(desc: "操作失败",
                                                                             showCancelButton: false,
                                                                             sureButtonName: "我知道了")
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    HStack {
                        Text("\(showDetailItem)")
                            .font(.system(size: 18, weight: .bold))
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "trash.circle")
                            .font(.system(size: 25))
                            .foregroundColor(Color("RedColor"))
                            .onTapGesture {
                                deleteItemDatasCheck()
                            }
                    }
                }
                VStack {
                    Spacer()
                    Text(totalMoney)
                        .font(.system(size: 25,weight: .bold))
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 100)
                    .foregroundColor(.white)
                    .background(type == 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"), in:RoundedRectangle(cornerRadius: 10))
            }
            VStack {
                HStack {
                    Image(systemName: "list.bullet").font(.system(size: 12, weight: .bold))
                    Text("记录").font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("\(String(year))年")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                        .onTapGesture {
                            closeAll()
                            self.pickerYearDefaultValue.year = self.year
                            self.showYearPicker = true
                        }
                    
                }.frame(height: 30)
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(showDatas,id:\.self) { item in
                            VStack {
                                HStack {
                                    Text("\(item.itemName)").font(.system(size: 14, weight: .bold))
                                    Spacer()
                                    Text("\(item.type == 0 ? "-" : "+")\(item.money)").font(.system(size: 14, weight: .bold))
                                }
                                HStack {
                                    Text("\(DateUtils.transDate2String(item.gmtCreated, format: "yyyy-MM-dd HH:mm:ss"))").font(.system(size: 10)).foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(item.accountName)").font(.system(size: 10)).foregroundColor(.secondary)
                                }
                            }.padding(5)
                                .frame(height: 40)
                                .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 0))
                                .onTapGesture {
                                    notifaction.handleId = nil
                                }
                                .selfSwiper(id: item.id.description, maxOffsetX: 50, notification: notifaction) {
                                    Button {
                                        deleteAssertRecordCheck(item)
                                    } label: {
                                        Image(systemName: "trash.circle")
                                            .frame(width: 40,height: 40)
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .background(Color("RedColor"),in:RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                        }
                    }
                }.onTapGesture {
                    notifaction.handleId = nil
                }
            }.padding(10)
                .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding(15)
        .safeAreaInset(edge: .bottom, content: {
            Color.clear.frame(height: 30)
        })
        .background(Color("ViewBackgroundColor"))
        .selfDatePicker(showState: $showYearPicker, type: $showYearPickerType, param: $pickerYearDefaultValue) {newVlue in
            if (newVlue.year != self.year) {
                self.year = newVlue.year!
                self.pageYear = newVlue.year!
                loadDatas()
            }
        }
        .selfLoading(showState: $showLoading)
        .onAppear() {
            if showDetailItem == "" {
                presentationMode.wrappedValue.dismiss()
            } else {
                initDatas()
                loadDatas();
            }
        }
        .selfAlter(showState: $showAlter, config: alterComponentConfig)
       
    }
    /**
     初始化数据
     */
    func initDatas() {
        let dataComponent = DateUtils.findComponentsOfDate([.year,.month], date: Date())
        self.year = dataComponent.year!
        self.pageYear = dataComponent.year!
    }
    // 加载数据并且显示数据
    func loadDatas() {
        var assertsData:AssertsData? = nil
        do {
            assertsData = try AssertsDataCacheService.getAsserts(cache: globalModel)
        } catch {
            
        }
        if let assertsDataReal = assertsData {
            showDatas(assertsDataReal)
        }
    }
    // 显示数据
    func showDatas(_ assertsDataReal: AssertsData) {
        // 总金额
        if type == 0 {
            // 存款
            self.totalMoney = assertsDataReal.deposit[showDetailItem] ?? "0.00"
            showList(assertsDataReal.depositData, self.pageYear)
        } else {
            // 负债
            self.totalMoney = assertsDataReal.liabilities[showDetailItem] ?? "0.00"
            showList(assertsDataReal.liabilitiesData, self.pageYear)
        }
    }
    // 显示列表
    func showList(_ dataList:[String:[AssertsDataItem]], _ year:Int) {
        var temp:[AssertsDataItem] = []
        var selectMoth:Int = 12
        while (selectMoth >= 1) {
            let ymStr = DateUtils.ymStr(year, selectMoth);
            let datasMonthOptional = dataList[ymStr]
            if let dataMonth = datasMonthOptional {
                // 如果存在数据，进行获取到相应的数据
                for dataItem in dataMonth {
                    if (dataItem.accountName == showDetailItem) {
                        temp.append(dataItem)
                    }
                }
            }
            selectMoth  = selectMoth - 1
        }
        self.showDatas = temp
    }
    
    func deleteAssertRecordCheck(_ deleteData:AssertsDataItem) {
        closeAll()
        alterComponentConfig.title = "删除提醒"
        alterComponentConfig.desc = "是否确定删除该记录？删除后无法进行恢复！"
        alterComponentConfig.showCancelButton = true
        alterComponentConfig.showSureButton = true
        alterComponentConfig.sureButtonName = "确定"
        showAlter = true
        alterComponentConfig.sureFun = {
            deleteAssertRecord(deleteData)
        }
    }
    
    // 删除资产数据
    func deleteAssertRecord(_ deleteData:AssertsDataItem) {
        do {
            let assertsData = try AssertsDataCacheService.getAsserts(cache: globalModel)
            if nil == assertsData {
                alterComponentConfig.title = "异常提醒"
                alterComponentConfig.desc = "读取数据异常，无法进行操作！"
                alterComponentConfig.showCancelButton = false
                alterComponentConfig.showSureButton = true
                alterComponentConfig.sureButtonName = "我知道了"
                showAlter = true
                return
            }
            // 进行更新数据
            let assertsDataReal = assertsData!
            let showDetailItemMoney = (type == 0 ? assertsDataReal.deposit[showDetailItem] : assertsDataReal.liabilities[showDetailItem]) ?? "0.00"
            var showDetailItemMoneyDecimal = Decimal(string: showDetailItemMoney) ?? Decimal(0)
            let ymStr = DateUtils.ymStr(deleteData.gmtCreated)
            if (self.type == 0) {
                // 存款
                // 删除记录
                var datas = assertsDataReal.depositData[ymStr]
                if (nil == datas) {
                    showAlter = true
                    alterComponentConfig.desc = "删除失败，该记录不存在"
                    return
                }
                var indexId:Int? = nil
                for (index,dataItem) in datas!.enumerated() {
                    if (dataItem.id.description == deleteData.id.description) {
                        indexId = index
                        break
                    }
                }
                if nil != indexId {
                    datas?.remove(at: indexId!)
                    assertsDataReal.depositData[ymStr] = datas
                    if deleteData.type == 0 {
                        // 减少，反过来，进行增加
                        showDetailItemMoneyDecimal = showDetailItemMoneyDecimal + ( Decimal(string:deleteData.money) ?? Decimal(0))
                    } else {
                        // 增加，反过来，进行减少
                        showDetailItemMoneyDecimal = showDetailItemMoneyDecimal - ( Decimal(string:deleteData.money) ?? Decimal(0))
                    }
                    assertsDataReal.deposit[showDetailItem] = DecimalUtils.trans2StringOfCurrency(showDetailItemMoneyDecimal)
                    
                }
            } else {
                // 负债
                // 删除记录
                var datas = assertsDataReal.liabilitiesData[ymStr]
                if (nil == datas) {
                    showAlter = true
                    alterComponentConfig.desc = "删除失败，该记录不存在"
                    return
                }
                var indexId:Int? = nil
                for (index,dataItem) in datas!.enumerated() {
                    if (dataItem.id.description == deleteData.id.description) {
                        indexId = index
                        break
                    }
                }
                if nil != indexId {
                    datas?.remove(at: indexId!)
                    assertsDataReal.liabilitiesData[ymStr] = datas
                    if deleteData.type == 0 {
                        // 减少，反过来，进行增加
                        showDetailItemMoneyDecimal = showDetailItemMoneyDecimal + ( Decimal(string:deleteData.money) ?? Decimal(0))
                    } else {
                        // 增加，反过来，进行减少
                        showDetailItemMoneyDecimal = showDetailItemMoneyDecimal - ( Decimal(string:deleteData.money) ?? Decimal(0))
                    }
                    assertsDataReal.liabilities[showDetailItem] = DecimalUtils.trans2StringOfCurrency(showDetailItemMoneyDecimal)
                  
                }
            }
            try AssertsDataCacheService.updateAsserts(assertsDataReal, cache: globalModel)
            loadDatas()
            lastUpdateTime = Date()
        } catch {
            
        }
    }
    
    func deleteItemDatasCheck() {
        closeAll()
        alterComponentConfig.title = "删除提醒"
        alterComponentConfig.desc = "是否确定删除该账目，并且删除所有记录？删除后无法进行恢复！"
        alterComponentConfig.showCancelButton = true
        alterComponentConfig.showSureButton = true
        alterComponentConfig.sureButtonName = "确定"
        showAlter = true
        alterComponentConfig.sureFun = {
            do {
                closeAll()
                showLoading = true
                try deleteItemDatas()
                lastUpdateTime = Date()
                presentationMode.wrappedValue.dismiss()
            } catch {
                alterComponentConfig.title = "操作异常"
                alterComponentConfig.desc = "删除失败"
                alterComponentConfig.showCancelButton = false
                alterComponentConfig.showSureButton = true
                alterComponentConfig.sureButtonName = "我知道了"
                showAlter = true
            }
           
        }
    }
    
    // 删除整个项目信息
    func deleteItemDatas() throws {
        let assertsData:AssertsData? = try AssertsDataCacheService.getAsserts(cache: globalModel)
        if (nil == assertsData) {
            return
        }
        // 1 删除这个项目的记录信息
        var dataTemp:[String:[AssertsDataItem]] = [:]
        let handleData = type == 0 ? assertsData!.depositData : assertsData!.liabilitiesData
        for (key,datas) in handleData {
            let filterDatas = datas.filter { item in
                item.accountName != showDetailItem
            }
            dataTemp[key] = filterDatas
        }
        // 2 删除当前的项目信息
        let handleItem = type == 0 ? assertsData!.deposit : assertsData!.liabilities
        let itemTemp = handleItem.filter { item in
            item.key != showDetailItem
        }
        // 3 重新整理数据
        if (type == 0) {
            assertsData!.depositData = dataTemp
            assertsData!.deposit = itemTemp
        } else {
            assertsData!.liabilitiesData = dataTemp
            assertsData!.liabilities = itemTemp
        }
        // 4 保存数据
        try AssertsDataCacheService.updateAsserts(assertsData!, cache: globalModel)
        
    }
    
    
    func closeAll() {
        self.showYearPicker = false
        self.showAlter = false
        self.showLoading = false
    }
    
}
