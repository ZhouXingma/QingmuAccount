//
//  AccountBookDetailOfListComponent.swift
//  QingmuAccount
//  账本-列表模式
//  Created by 周荥马 on 2022/12/2.
//

import SwiftUI
struct AccountBookDetailOfListComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 当前年份
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 当前月份
    @State private var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 月度收支数据
    @State private var monthDatas:[String:InOutOfDayModel] = [:]
    // 显示年度预算设置
    @State private var showBudgetSetting:Bool = false
    // 打开预算详情时预置的币种
    @State private var budgetDetailCurrency:String? = nil
    @State private var budgetChangeTime:Date = Date()
    // 列表滑动通知
    @StateObject var notifaction = SelfSwiperNotification()
    // 编辑记录
    @State private var editRecord:Bool = false
    // 编辑的记录数据
    @State private var editAccountBookData:AccountBookData? = nil
    // 最后加载时间
    @Binding var latestLoadTime:Date
    // 显示统计信息
    @State private var showStatistics:Bool = false
    // 资产账户（用于显示记录对应的账户名）
    @State private var assetAccounts:[AssetAccountModel] = []
    
    // 年月选择
    @State private var showYmPicker:Bool = false
    @State private var showYmPickerType:DatePickerType = .YM
    @State private var datePickerParam:DatePickerValue = DatePickerValue()
    
    var body: some View {
        VStack {
            // 当月汇总（多币种）
            AccountBookMonthSummaryComponent(
                year: $year,
                month: $month,
                budgetChangeTime: $budgetChangeTime,
                changeTime: {
                    closeAll()
                    datePickerParam.year = year
                    datePickerParam.month = month
                    showYmPicker = true
                },
                showStatistics: {
                    closeAll()
                    showStatistics = true
                },
                showBudgetDetail: { currency in
                    closeAll()
                    budgetDetailCurrency = currency
                    showBudgetSetting = true
                }
            ).environmentObject(globalModel)
            // 列表
            ScrollView(showsIndicators: false) {
                VStack { 
                    ForEach(monthDatas.keys.sorted(by: { item1, item2 in
                        (item1 as NSString).longLongValue >= (item2 as NSString).longLongValue
                    }),id:\.self) { key in
                        recordDayList(monthDatas[key]!)
                    }
                }
                Color.clear.frame(height: 60)
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .ignoresSafeArea()
            .padding(.horizontal,15)
            .sheet(isPresented: $showBudgetSetting, content: {
                AccountBookBudgetDetailComponent(year:year, month:month, initCurrency:budgetDetailCurrency, updateBudgetSeting:updateBudgetSeting).environmentObject(globalModel)
            })
            .sheet(isPresented: $showStatistics, content: {
                AccountBookStatisticComponent().environmentObject(globalModel)
            })
            .onChange(of: latestLoadTime, perform: { newValue in
                // 初始化数据
                initData()
            })
            .onChange(of: globalModel.accountBook, perform: { newValue in
                // 推迟到下一个 RunLoop，避免重载时同步回写缓存状态（Publishing during view update）
                DispatchQueue.main.async {
                    initData()
                }
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
            Text(hexStr2Unicode(recordItem.iconStr))
                .font(.custom("icomoon", size: 25))
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
            .overlay(alignment: .topTrailing) {
                // 账户和币型：右上角、不参与布局、不影响金额垂直居中
                if !recordItem.accountId.isEmpty || !recordItem.currency.isEmpty {
                    Text(recordAccountText(recordItem))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }
            }
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
    
    /// 记录显示用的账户 + 币型文本（如「招商银行 · 人民币」）
    func recordAccountText(_ record: AccountBookData) -> String {
        let name = assetAccounts.first { $0.id.uuidString == record.accountId }?.name ?? ""
        let currency = record.currency.isEmpty ? "CNY" : record.currency
        if name.isEmpty {
            return AssetCurrency.name(of: currency)
        }
        return "\(name) · \(AssetCurrency.name(of: currency))"
    }

    func closeAll() {
        showBudgetSetting = false
        editRecord = false
        showYmPicker = false
        showStatistics = false
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
            assetAccounts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
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
            }
        }
        // 月度数据
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



