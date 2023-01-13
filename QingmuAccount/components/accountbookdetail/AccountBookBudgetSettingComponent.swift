//
//  AccountBookBudgetSetting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/8.
//

import SwiftUI
import Combine

struct AccountBookBudgetSettingComponent : View {
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
    
    
    // 设置预算的参数-预算金额
    @State private var setingBugget = ""
    // 设置预算的参数-预算类型
    @State private var setingBuggetType:Int = -1
    // 设置预算的参数-是否显示设置预算
    @State private var setingBudgetShow = false
    var updateBudgetSeting:() -> Void = {}

    var body: some View {
        ZStack {
            GeometryReader { geometry in
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
                    VStack {
                        HStack {
                            Text("总预算:\(totleBudgetShow())")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(Color("DefaultButtonBackgroud")).font(.system(size: 20))
                                .onTapGesture {
                                    setingBudgetShow = true
                                    setingBugget = nil != budget ?  DecimalUtils.trans2StringOfCurrency(budget!) : ""
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
                    Spacer()
                }.padding(.horizontal,15)
                if (setingBudgetShow) {
                    setingBuggetView
                }
            }.frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color("ViewBackgroundColor"))
                .onAppear() {
                    // 加载预算信息
                    loadBudgetInfo()
                    // 计算预算使用情况
                    computerBudgetUseInfo()
                }
                .selfAlter(showState: $showAlter, config: alterConfig)
        }.ignoresSafeArea()
    }
    // 设置预算的试图
    var setingBuggetView : some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .onTapGesture {
                         setingBudgetShow = false
                    }
            }.frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 20)
                .padding(.vertical, 20)
            
            VStack {
                HStack {
                    Text("\(thisMonth)月预算").font(.system(size: 16,weight: .bold))
                    Spacer()
                }
                HStack {
                    TextField("输入预算金额",text: $setingBugget)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20,weight: .bold))
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
            }.frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 60)
                .padding(10)
                .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
            
            VStack {
                HStack {
                    Text("历史预算").font(.system(size: 16,weight: .bold))
                    Spacer()
                }
                ScrollView {
                    ForEach(budgetHistory.keys.sorted(by: { item1, item2 in
                        (item1 as NSString).longLongValue >= (item2 as NSString).longLongValue
                    }),id:\.self) { key in
                        let item = budgetHistory[key]
                        if (key != thisYm && nil != item) {
                            HStack {
                                Text(key).font(.system(size: 14,weight: .bold))
                                Spacer()
                                Text(DecimalUtils.trans2StringOfCurrency(item!)).font(.system(size: 14,weight: .bold))
                            }
                        }
                       
                    }
                    
                }
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(10)
                .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
           
            VStack {
                Button{
                    saveBudgetSeting()
                } label: {
                    Text("保存").tint(.white)
                        .frame(width: 250, height: 50, alignment: .center)
                        .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
                }.padding(.vertical,20)
            }.padding(.bottom,30)
            
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding(.horizontal,15)
            .background(Color("ViewBackgroundColor"))
            .onTapGesture {
                toHideKeyboard()
            }
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
    func saveBudgetSeting() {
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



struct AccountBookBudgetSettingComponent_Previews: PreviewProvider {
    static var previews: some View {
        AccountBookBudgetSettingComponent().preferredColorScheme(.light)
    }
}
