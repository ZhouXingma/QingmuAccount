//
//  AccountBookBudgetSetting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/8.
//

import SwiftUI
import Combine

struct AccountBookBudgetDetailComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 选择的年份
    @State var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 选择的月份
    @State var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 本年
    @State var thisYear:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 本月
    @State var thisMonth:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 本年本月，yyyyMM
    @State var thisYm:String = DateUtils.transDate2String(Date(), format: "yyyyMM")
    // 整本的配置信息
    @State private var accountBookSeting:AccountBookSetingModel? = nil
    // 显示提醒
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig()
    // 预算总计
    @State private var budget:Decimal?
    // 历史预算
    @State var budgetHistory:[String:Decimal] = [:]
    // 总支出
    @State private var expend:Decimal = 0
    // 预算剩余百分比
    @State private var budgetUsePercent:Double = 1
    // 总计还可以使用多少钱
    @State private var canUseMoney:String = "-"
    // 剩余天数
    @State private var dayCount:String = "-"
    // 今日预算
    @State private var dayBudget:String = "-"
    // 今日已用
    @State private var todayUseMoney:Decimal = 0
    // 今日还可以使用
    @State private var todayCanUseMoney:String = "-"
    
    
   
    // 设置预算的参数-是否显示设置预算
    @State private var setingBudgetShow = false
    var updateBudgetSeting:() -> Void = {}
    
    // 历史预算年份
    @State private var budgetYear:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 选择年份组建显示
    @State private var showYearPicker = false
    // 选择年份的数据
    @State private var showYearPickerType : DatePickerType = .Y
    // 选择年份的默认数据
    @State private var pickerYearDefaultValue: DatePickerValue = DatePickerValue()
    // 历史预算使用情况
    @State private var historyBudgetUse : HistoryBudgetUse = HistoryBudgetUse()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                mouthBuggetUse
                mouthBuggetUseDetail
                historyBuggetUse
            }
        }.padding(.bottom, 30)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea()
            .padding(.horizontal,15)
            .background(Color("ViewBackgroundColor"))
            .selfDatePicker(showState: $showYearPicker, type: $showYearPickerType, param: $pickerYearDefaultValue) {newVlue in
                if (budgetYear != newVlue.year!) {
                    budgetYear = newVlue.year!
                    loadHistoryBudget()
                }
            }
            .sheet(isPresented: $setingBudgetShow) {
                AccountBookBudgetSettingComponent(thisMothBugget: totleBudgetShow(), saveBudgetSeting: saveBudgetSeting)
            }
            .onAppear() {
                // 加载预算信息
                loadBudgetInfo()
                // 计算预算使用情况
                computerBudgetUseInfo()
                // 记载历史预算
                loadHistoryBudget()
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
    }
    
    // 当月预算使用情况
    var mouthBuggetUse :some View {
        VStack {
            HStack {
                Text("您本月预算剩余情况如下").font(.system(size: 18,weight: .bold))
            }.padding(.vertical,20)
                .padding(.top,40)
            ZStack {
                CircleProgressComponent(size: 16,percent: $budgetUsePercent).frame(width: 180, height: 180)
                VStack {
                    Text("\(DecimalUtils.trans2StringOfPercent(Decimal(budgetUsePercent * 100)))%").font(.system(size: 26,weight: .bold)).foregroundColor(Color("DefaultButtonBackgroud"))
                    
                }.frame(width: 180, height: 180)
            }.padding(.bottom,20)
        }
    }
    
    // 当月预算使用详情
    var mouthBuggetUseDetail :some View {
        VStack {
            HStack {
                Text("总预算:\(totleBudgetShow())")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: "square.and.pencil")
                    .foregroundColor(Color("DefaultButtonBackgroud")).font(.system(size: 20))
                    .onTapGesture {
                        setingBudgetShow = true
                    }
                
            }.padding(.vertical,10)
            VStack {
                HStack {
                    Text("本月总支出")
                        .font(.system(size: 14,weight: .bold))
                    Spacer()
                    Text("\(DecimalUtils.trans2StringOfCurrency(expend))")
                        .font(.system(size: 14,weight: .bold))
                }.padding(.vertical,10)
                HStack {
                    Text("本月剩余预算")
                        .font(.system(size: 14,weight: .bold))
                    Spacer()
                    Text("\(canUseMoney)")
                        .font(.system(size: 14,weight: .bold))
                }.padding(.vertical,10)
                if thisMonth == month && thisYear == year {
                    HStack {
                        Text("本月剩余天数")
                            .font(.system(size: 14,weight: .bold))
                        Spacer()
                        Text("\(dayCount)")
                            .font(.system(size: 14,weight: .bold))
                    }.padding(.vertical,10)
                    HStack {
                        Text("今日预算")
                            .font(.system(size: 14,weight: .bold))
                        Spacer()
                        Text("\(dayBudget)")
                            .font(.system(size: 14,weight: .bold))
                    }.padding(.vertical,10)
                    HStack {
                        Text("今日支出")
                            .font(.system(size: 14,weight: .bold))
                        Spacer()
                        Text("\(DecimalUtils.trans2StringOfCurrency(todayUseMoney))")
                            .font(.system(size: 14,weight: .bold))
                    }.padding(.vertical,10)
                    HStack {
                        Text("今日可用")
                            .font(.system(size: 14,weight: .bold))
                        Spacer()
                        Text("\(todayCanUseMoney)")
                            .font(.system(size: 14,weight: .bold))
                    }.padding(.vertical,10)
                }
                
            }
            
        }.frame(minWidth: 0,maxWidth: .infinity)
            .padding(.vertical,10)
            .padding(.horizontal,20)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 15))
    }
    
    // 历史预算使用情况
    var historyBuggetUse: some View {
        VStack {
            HStack {
                Text("历史预算").font(.system(size: 16, weight: .bold))
                Spacer()
                Text("\(String(budgetYear))年")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        pickerYearDefaultValue.year = budgetYear
                        showYearPicker = true
                    }
            }.padding(.vertical,10)
            ScrollView(showsIndicators: false) {
                ForEach(historyBudgetUse.historyList,id:\.self) { item in
                    HStack {
                        Text("\(item.getMothDateOfMoth())月").font(.system(size: 14,weight: .bold))
                        Spacer()
                        Text(DecimalUtils.trans2StringOfCurrency(item.useValue))
                            .font(.system(size: 14,weight: .bold))
                            .foregroundColor(item.useValue > item.budgetValue ? Color("RedColor") : .primary)
                        Text("/")
                            .font(.system(size: 14,weight: .bold))
                        Text(DecimalUtils.trans2StringOfCurrency(item.budgetValue))
                            .font(.system(size: 14,weight: .bold))
                    }.frame(height: 25)
                }
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 450, maxHeight: 450)
            .padding(.vertical,10)
            .padding(.horizontal,20)
            .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
    }

    /**
     加载预算信息
     */
    func loadBudgetInfo() {
        if nil != globalModel.accountBook {
            let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
            let ymStr = String("\(year)\(monthStr)")
            do {
                accountBookSeting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
                if (nil != accountBookSeting) {
                    budgetHistory = accountBookSeting!.budget
                    budget = budgetHistory[ymStr]
                }
            } catch {
                alterConfig.showCancelButton = false
                alterConfig.desc = "加载账本配置信息失败，无法进行后续操作"
                alterConfig.sureButtonName = "我知道啦"
                showAlter = true
            }
        }
    }
    
    // 总预算显示
    func totleBudgetShow() -> String{
        if nil == budget {
            return ""
        }
        return DecimalUtils.trans2StringOfCurrency(budget!)
    }

    // 保存预算
    func saveBudgetSeting(setingBugget:String) {
        if (nil == accountBookSeting) {
            alterConfig.showCancelButton = false
            alterConfig.desc = "加载账本配置信息失败，无法进行操作"
            alterConfig.sureButtonName = "我知道啦"
            showAlter = true
            return
        }
        if setingBugget == "0" || setingBugget == "" || setingBugget=="0.00" || setingBugget=="0.0"{
            budgetHistory.removeValue(forKey: thisYm)
        } else {
            budgetHistory[thisYm] = Decimal(string: setingBugget)
        }
        accountBookSeting?.budget = budgetHistory
        do {
            try  AccountBookSetingOfCacheService.updateSetting(globalModel.accountBook!.id.description, accountBookSeting!, cache: globalModel)
            setingBudgetShow = false
            budget = budgetHistory[thisYm]
            computerBudgetUseInfo()
            loadHistoryBudget()
            updateBudgetSeting()
        } catch {
            alterConfig.showCancelButton = false
            alterConfig.desc = "操作失败！"
            alterConfig.sureButtonName = "我知道了"
            showAlter = true
        }
    }
    // 计算预算使用情况
    func computerBudgetUseInfo() {
        if (nil == globalModel.accountBook) {
            return
        }
        // 默认按月来算
        computerBudgetUseInfoOfMonth()
        if nil != self.budget && self.budget! != 0 {
            var canUseMoneyTemp = self.budget! - self.expend
            if (canUseMoneyTemp < 0) {
                canUseMoneyTemp = 0
            }
            let tempValue = canUseMoneyTemp / self.budget!
            self.canUseMoney = DecimalUtils.trans2StringOfCurrency(canUseMoneyTemp)
            self.budgetUsePercent = Double(truncating: tempValue as NSNumber)
        } else {
            self.canUseMoney = "-"
            self.budgetUsePercent = 1.0
        }
        if (thisYear == year && thisMonth == month) {
            // 计算今日使用今日
            let todayUseMoney = getTodayUseMoney()
            self.todayUseMoney = todayUseMoney
            // 计算每日的预算信息
            computerDayBudgetInfo()
        }
    }

    //  计算每日的预算信息
    func computerDayBudgetInfo() {
        // 还剩下多少天
        let components = DateUtils.findComponentsOfDate([.year,.month,.day], date: Date())
        let year = components.year!
        let month = components.month!
        let day  = components.day!
        let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
        let balanceDay = dayLength - day + 1
        self.dayCount = String("\(balanceDay)")
        computerDayUseMoneyInfo(balanceDay:balanceDay)
    }

    // 计算预算为每月的情况
    func computerBudgetUseInfoOfMonth() {
        let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
        let ymStr = String("\(year)\(monthStr)")
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: year, cache: globalModel)
            if (nil == yearData) {
                return
            }
            let dataArray = yearData!.data[ymStr]
            if (nil == dataArray) {
                return
            }
            // 初始化
            self.expend = 0
            for data in dataArray! {
                if (data.type == 1) {
                    continue
                }
                self.expend = self.expend + (Decimal(string: data.money) ?? 0)
            }
        } catch {

        }
    }

    // 计算每日可用金钱
    func computerDayUseMoneyInfo(balanceDay:Int){
        if (balanceDay <= 0 || nil == self.budget || self.budget! == 0) {
            // 每日可用多少钱
            self.dayBudget = "-"
            // 今日可用金额
            self.todayCanUseMoney = "-"
            return
        }
        // 可以使用的钱
        var canUseManeyTemp = self.budget! - self.expend + self.todayUseMoney
        if (canUseManeyTemp < 0) {
            canUseManeyTemp = 0
        }
        // 每天可以用的预算
        let everyDayBudget =  canUseManeyTemp / Decimal(balanceDay)
        // 今天还能用的钱
        var everyDayCanUseManey = everyDayBudget - self.todayUseMoney
        if (everyDayCanUseManey < 0) {
            everyDayCanUseManey = 0
        }
        self.dayBudget = DecimalUtils.trans2StringOfCurrency(everyDayBudget)
        self.todayCanUseMoney = DecimalUtils.trans2StringOfCurrency(everyDayCanUseManey)
    }
    
    // 获取今日支付费用
    func getTodayUseMoney() -> Decimal {
        // 今日支出金额
        var todayExpend:Decimal = 0
        // 剩余的余额
        let year = DateUtils.findComponentsOfDate([.year], date: Date()).year!
        let ymStr = DateUtils.transDate2String(Date(), format: "yyyyMM")
        let ymdStr = DateUtils.transDate2String(Date(), format: "yyyyMMdd")
        do {
            // 年度数据
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: year, cache: globalModel)
            if (nil != yearData) {
                // 月度数据
                let dataArray = yearData!.data[ymStr]
                if (nil != dataArray) {
                    // 遍历月度数据
                    for data in dataArray! {
                        if (data.type == 1) {
                            continue
                        }
                        // 如果是今天的数据
                        if (data.dateStr == ymdStr) {
                            todayExpend = todayExpend + (Decimal(string: data.money) ?? 0)
                        }
                    }
                }
            }
        } catch {

        }
        return todayExpend
    }
    
    // 加载历史预算
    func loadHistoryBudget() {
        if nil != globalModel.accountBook {
            do {
                accountBookSeting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
                if (nil != accountBookSeting) {
                    budgetHistory = accountBookSeting!.budget
                    buildHistoryData(budgetHistory: budgetHistory)
                }
            } catch {
                alterConfig.showCancelButton = false
                alterConfig.desc = "加载历史预算失败!"
                alterConfig.sureButtonName = "我知道啦"
                showAlter = true
            }
        }
    }
    
    func buildHistoryData(budgetHistory:[String:Decimal]) {
        var historyBudgetUse = HistoryBudgetUse()
        var historyList:[HistoryBudgetUseDetail] = []
        for (key,value) in budgetHistory {
            if (key.contains("\(budgetYear)")) {
                var yearData:AccountBookYearData? = nil
                do {
                    yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: budgetYear, cache: globalModel)
                } catch {
                }
                var useValue:Decimal = 0
                if yearData != nil {
                    var incomeExpensesTotal = yearData!.total[key]
                    if nil != incomeExpensesTotal {
                        useValue = incomeExpensesTotal!.expenses
                    }
                }
                var detail = HistoryBudgetUseDetail(monthDate: key, budgetValue: value, useValue: useValue)
                historyList.append(detail)
            }
        }
        historyBudgetUse.historyList = historyList.sorted { item1, item2 in
            item1.monthDate > item2.monthDate
        }
        self.historyBudgetUse = historyBudgetUse
    }
}
