//
//  BudgetOverviewComponent.swift
//  QingmuAccount-本月预算概括预览
//
//  Created by 周荥马 on 2022/12/1.
//

import SwiftUI

struct BudgetOverviewOfMonthComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 选择的年份
    @Binding var year:Int
    // 选择的月份
    @Binding var month:Int
    // 本年
    @State var thisYear:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 本月
    @State var thisMonth:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 整本的配置信息
    @State var accountBookSeting:AccountBookSetingModel? = nil
    // 显示预算设置
    @Binding var showBudgetSetting:Bool
    // 显示预算更新监听时间
    @Binding var budgetChangeTime:Date
    // 支出
    @State var expend:Decimal = 0
    // 预算
    @State var budget:Decimal?
    // 历史预算
    @State var budgetHistory:[String:Decimal] = [:]
    // 可以支付
    @State var canUseMoney:String = "-"
    // 预算使用百分比
    @State var budgetUsePercent:Double = 1
    
    
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("预算").font(.system(size: 16,weight: .bold))
                    Spacer()
                }
                Spacer()
                VStack {
                    Image(systemName: "chevron.right.circle.fill").font(.system(size: 18))
                        .onTapGesture {
                            showBudgetSetting = true
                        }
                    Spacer()
                }
            }.frame(height: 30)
            Spacer()
            HStack(alignment: .center) {
                VStack {
                    VStack {
                        Text(totleBudgetShow()).font(.system(size: 16, weight: .bold))
                        Text("预算").font(.system(size: 13))
                    }.padding(.vertical,5)
                    VStack {
                        Text(DecimalUtils.trans2StringOfCurrency(expend)).font(.system(size: 16, weight: .bold))
                        Text("已用").font(.system(size:  13))
                    }.padding(.vertical,5)
                }
                Spacer()
                
                VStack {
                    Text(canUseMoney).font(.system(size: 16, weight: .bold))
                    Text((thisMonth == month && thisYear == year) ? "今日还能消费":"剩余预算").font(.system(size:  13))
                }.background {
                    HalfCircleProgressComponent(size: 10, bgColor: .white.opacity(0.3),InnerColor: .white, percent: $budgetUsePercent).frame(width:150,height: 150)
                        .offset(y:10)
                }.frame(width: 150)
                    .padding(.top,50)
                    .padding(.trailing,10)
            }
        }.padding(10)
        .foregroundColor(.white)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 180)
        .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal,5)
        .onAppear() {
           initData()
        }
        .onChange(of: budgetChangeTime, perform: { newValue in
           initData()
        })
    }
    
    func initData() {
        // 加载预算信息
        loadBudgetInfo()
        // 计算预算使用情况
        computerBudgetUseInfo()
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
            }
        }
       
    }
    
    
    /**
     计算预算使用情况
     */
    func computerBudgetUseInfo() {
        if (nil == globalModel.accountBook) {
            return
        }
        computerBudgetUseInfoOfMonth()
        if thisMonth == month && thisYear == year {
            computerBudgetDerivationInfo()
        } else {
            // 计算剩余预算
            computerSurplusBudget()
        }
    }
    

    // 计算每月预算使用情况
    func computerBudgetUseInfoOfMonth() {
        let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
        let ymStr = String("\(year)\(monthStr)")
        var expendTemp = Decimal(0.0)
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: year, cache: globalModel)
            if (nil == yearData) {
                self.expend = expendTemp
                return
            }
            let dataArray = yearData!.data[ymStr]
            if (nil == dataArray) {
                self.expend = expendTemp
                return
            }
            for data in dataArray! {
                if (data.type == 1) {
                    continue
                }
                expendTemp = expendTemp + (Decimal(string: data.money) ?? 0)
            }
        } catch {
            
        }
        self.expend = expendTemp
    }
    
    // 计算剩余预算
    func computerSurplusBudget() {
        if nil == budget {
            canUseMoney = "-"
            return
        }
        let surplusBudget = budget! - expend
        let budgetUsePercentTemp = surplusBudget / self.budget!
        canUseMoney = DecimalUtils.trans2StringOfCurrency(surplusBudget)
        budgetUsePercent = Double(truncating: budgetUsePercentTemp as NSNumber)
       
    }
    
    func computerBudgetDerivationInfo() {
        if nil == self.budget || self.budget == 0 {
            self.budgetUsePercent = 1.0
            self.canUseMoney = "-"
            return
        }
        // 还剩下多少天
        let components = DateUtils.findComponentsOfDate([.year,.month,.day], date: Date())
        let year = components.year!
        let month = components.month!
        let day  = components.day!
        let dayLength = DateUtils.monthOfDayLength(year: year, month: month)
        let balanceDay = dayLength - day + 1
        computerDayUseMoneyInfo(balanceDay:balanceDay)
    }
    
    func computerDayUseMoneyInfo(balanceDay:Int) {
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
        // 可以使用的钱
        var canUseManeyTemp = self.budget! - self.expend + todayExpend
        if (canUseManeyTemp < 0) {
            canUseManeyTemp = 0
        }
        // 每天可以用的预算
        let everyDayBudget =  canUseManeyTemp / Decimal(balanceDay)
        // 今天还能用的钱
        var everyDayCanUseManey = everyDayBudget - todayExpend
        if (everyDayCanUseManey < 0) {
            everyDayCanUseManey = 0
        }
        // 余额的百分比
        let tempValue = everyDayCanUseManey / everyDayBudget
        self.canUseMoney = DecimalUtils.trans2StringOfCurrency(everyDayCanUseManey)
        self.budgetUsePercent = Double(truncating: tempValue as NSNumber)
    }
   
    
   
    // 总预算显示
    func totleBudgetShow() -> String{
        if nil == budget {
            return "-"
        }
        return DecimalUtils.trans2StringOfCurrency(budget!)
    }
    
}
