//
//  AccountBookDetailOfListComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/2.
//

import SwiftUI
struct AccountBookDetailOfListComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 滑动的类型
    @State var selection:Int = 0
    // 当前年份
    @State var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 当前月份
    @State var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 月度预算
    @State var monthBudget:Decimal = -1
    // 月度收入
    @State var monthIncome:Decimal = 0
    // 月度支出
    @State var monthExpend:Decimal = 0
    // 月度收支数据
    @State var monthDatas:[String:InOutOfDayModel] = [:]
    // 显示年度预算设置
    @State var showBudgetSetting:Bool = false
    @State var budgetChangeTime:Date = Date()
    // 列表滑动通知
    @StateObject var notifaction = SelfSwiperNotification()
    // 编辑记录
    @State var editRecord:Bool = false
    // 编辑的记录数据
    @State var editAccountBookData:AccountBookData? = nil
    // 最后加载时间
    @Binding var latestLoadTime:Date
    // 显示统计信息
    @State var showStatistics:Bool = false
    
    // 年月选择
    @State var showYmPicker:Bool = false
    @State var showYmPickerType:DatePickerType = .YM
    @State private var datePickerParam:DatePickerValue = DatePickerValue()
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                InOutOfMonthComponent(year: $year, month: $month, outTotal: $monthExpend, inTotal: $monthIncome, changeTime: {
                    showYmPicker = true
                    datePickerParam.year = year
                    datePickerParam.month = month
                },showStatistics:$showStatistics).environmentObject(globalModel).tag(0)
                BudgetOverviewOfMonthComponent(
                    year: $year, month: $month,
                    showBudgetSetting:$showBudgetSetting,
                    budgetChangeTime:$budgetChangeTime).environmentObject(globalModel).tag(1)
               
            }
            .frame(height: 180)
            .tabViewStyle(.page(indexDisplayMode: .never))
            HStack {
                AccountBookDetailViewTabViewSub(currentSelection: 0, selection: $selection)
                AccountBookDetailViewTabViewSub(currentSelection: 1, selection: $selection)
            }.frame(height: 5)
            ScrollView(showsIndicators: false) {
                VStack { 
                    ForEach(monthDatas.keys.sorted(by: { item1, item2 in
                        (item1 as NSString).longLongValue >= (item2 as NSString).longLongValue
                    }),id:\.self) { key in
                        recordDayList(monthDatas[key]!)
                    }
                }
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .ignoresSafeArea()
            .padding(.horizontal,15)
            .padding(.bottom,100)
            .sheet(isPresented: $showBudgetSetting, content: {
                AccountBookBudgetSettingComponent(year:year, month:month, updateBudgetSeting:updateBudgetSeting).environmentObject(globalModel)
            })
            .sheet(isPresented: $showStatistics, content: {
                AccountBookStatisticComponent().environmentObject(globalModel)
            })
            .onChange(of: latestLoadTime, perform: { newValue in
                // 初始化数据
                initData()
            })
            .onChange(of: globalModel.accountBook, perform: { newValue in
                // 初始化数据
                initData()
            })
            .onAppear() {
                // 初始化数据
                initData()
            }.selfDatePicker(showState: $showYmPicker, type: $showYmPickerType, param: $datePickerParam) { newValue in
                self.year = newValue.year ?? self.year
                self.month = newValue.month ?? self.month
                initData()
            }
        
    }
    /**
     每日列表
     item:每日的数据集合
     */
    func recordDayList(_ item:InOutOfDayModel) -> some View {
        VStack {
            HStack {
                Text(trans2ListDateInfo(item.dateStr))
                    .foregroundColor(.secondary)
                    .font(.system(size: 14,weight: .bold))
                Spacer()
                Text("\(DecimalUtils.trans2StringOfCurrency(item.balance))").foregroundColor(.secondary).font(.system(size: 14,weight: .bold))
            }.padding(.horizontal,10)
            VStack(alignment:.center,spacing: 5) {
                ForEach(item.data, id:\.self) { recordItem in
                    recordDayListItem(recordItem)
                        .onTapGesture {
                            notifaction.handleId = nil
                            editAccountBookData = recordItem
                            closeAll()
                            editRecord = true
                        }
                }
            }
        }.padding(.bottom,20)
            .sheet(isPresented: $editRecord, content: {
                AccountBookRecordEditComponent(accountBookData: editAccountBookData!, newRecordUpdate: { item in
                    initData()
                }).environmentObject(globalModel)
            })
       
    }
    // 每日列表中的某条记录
    func recordDayListItem(_ recordItem:AccountBookData) -> some View {
        HStack {
            Text(recordItem.iconStr)
                .font(.custom("iconfont", size: 25))
                .foregroundColor( Color("DefaultButtonBackgroud"))
                .padding(10)
                .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(recordItem.title).font(.system(size: 14,weight:.bold)).padding(.bottom,2)
                if (StringUtils.trimCount(recordItem.desc) > 0) {
                    Text(recordItem.desc).font(.system(size: 12)).foregroundColor(.secondary)
                }
            }
            Spacer()
            if (recordItem.type == 0) {
                Text("-\(recordItem.money)").font(.system(size: 15,weight: .bold))
            } else {
                Text("\(recordItem.money)").font(.system(size: 15,weight: .bold))
            }
            
        }.frame(minWidth: 0,maxWidth: .infinity)
            .padding(.horizontal,10)
            .frame(height: 60)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
            .selfSwiper(id: recordItem.id.description, maxOffsetX: 62, notification: notifaction) {
                Button {
                    deleteRecord(recordItem)
                } label: {
                    Image(systemName: "trash.circle")
                        .frame(width: 60,height: 60)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .background(Color("RedColor"),in:RoundedRectangle(cornerRadius: 10))
                }
            }
    }
    
    func closeAll() {
        showBudgetSetting = false
        editRecord = false
        showYmPicker = false
    }
    /**
     初始化数据
     */
    func initData() {
        // 加载数据
        loadRecordData()
        // 更新预算设置
        updateBudgetSeting()
    }
    /**
     预算发生更新
     */
    func updateBudgetSeting() {
        budgetChangeTime = Date()
    }
    /**
     加载数据
     */
    func loadRecordData() {
        if nil == globalModel.accountBook {
            return
        }
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: year, cache: globalModel)
            if let yearDataReal = yearData {
                // 计算展示出来
                computerAndShow(yearDataReal)
            } else {
                computerAndShow(AccountBookYearData(year: year))
            }
        } catch {
            
        }
    }
    /**
     计算并且展示
     */
    func computerAndShow(_ yearData:AccountBookYearData) {
        // 目标1:按照日期进行分组
        let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
        // 目标2:获取期望的展示数据
        let ymStr = String("\(year)\(monthStr)")
        // 月度收入
        var monthIncome:Decimal = 0
        // 月度支出
        var monthExpend:Decimal = 0
        // yyyyMMdd:[记录]
        var mothOfDayList:[String:InOutOfDayModel] = [:]
        // 月度记录
        let monthDataArray = yearData.data[ymStr]
        if (nil != monthDataArray && monthDataArray!.count > 0) {
            for dataItem in monthDataArray! {
                // 放入集合中
                var dayModel = mothOfDayList[dataItem.dateStr]
                if nil == dayModel {
                    dayModel = InOutOfDayModel(dateStr: dataItem.dateStr)
                    mothOfDayList[dataItem.dateStr] = dayModel
                }
                dayModel?.addData(dataItem)
                // 月度总收支
                if (dataItem.type == 0) {
                    monthExpend = monthExpend + (Decimal(string: dataItem.money) ?? 0)
                } else {
                    monthIncome = monthIncome  + (Decimal(string: dataItem.money) ?? 0)
                }
            }
        }
        // 月度（支出，收入，数据）
        self.monthExpend = monthExpend
        self.monthIncome = monthIncome
        self.monthDatas = mothOfDayList
    }

    // 删除记录真正的操作
    func deleteRecord(_ recordItem:AccountBookData) {
        do {
            try AccountBookDataOfCacheService.deleteData(globalModel.accountBook!.id.description, data: recordItem, cache: globalModel)
            latestLoadTime = Date()
        } catch {
            
        }
    }
    
     // 转换每日列表头部的日期信息
     func trans2ListDateInfo(_ dateStr:String) -> String {
         let date = DateUtils.transString2Date(dateStr, format: "yyyyMMdd")!
         // 获取月-日 星期
         let components = DateUtils.findComponentsOfDate([.month,.day,.weekday], date: date)
         return String("\(components.month!)月\(components.day!)日 星期\(DateUtils.transWeekDat2ChineseString(components.weekday!))")
     }
}



