//
//  AccountBookStatisticComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/19.
//

import SwiftUI

struct AccountBookStatisticComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 查询数据的时间维度，年/月
    @State private var selectStaticDateType:Int = 0
    // 需要查询的年/月
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    @State private var month:Int =  DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 查询数据的支收维度，0:支出，1:收入
    @State private var expendIncomeType:Int = 0
    // 支收总笔数
    @State private var expendIncomeCount:Int = 0
    // 支收总金额
    @State private var expendIncomeMoney:Decimal = 0
    // 日期选择-是否显示
    @State private var showDatePickerTime:Bool = false
    // 日期选择-选择日期的类型
    @State private var showDatePickerType:DatePickerType = .YM
    // 日期选择-日期的数据暂存地点
    @State private var datePickerDateValue:DatePickerValue = DatePickerValue()
    // 数据：支出 and 收入
    @State private var staticData:StatisticsData = StatisticsData()
    // 折线图数据
    @State private var chartData:ChartData?
    // 饼图数据
    @State private var peiDataList:[PieData]?
    // 列表
    @State private var titleDataList:[ExpendIncomeTitleData] = []
    
    @State private var lineViewStyle:ChartStyle = ChartStyle(
        backgroundColor: Color("MainBackgroundColor"),
        accentColor: Color("DefaultButtonBackgroud"),
        secondGradientColor: Color("DefaultButtonBackgroud").opacity(0.5),
        textColor: Color.primary,
        legendTextColor: Color.primary,
        dropShadowColor: Color.primary
    )
    var specifier: String = "%.2f"
    
    
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("DefaultButtonBackgroud"))
                        .frame(width: 150, height: 30).offset(x:selectStaticDateType == 0 ? -75 : 75)
                        .animation(.easeInOut(duration: 0.2), value: selectStaticDateType)
                }
                HStack {
                    createTopMenuView(code: 0, title: "月")
                    createTopMenuView(code: 1, title: "年")
                }
            }.frame(width: 300, height: 30)
            .padding(3)
            .background(Color("MainBackgroundColor"),in: RoundedRectangle(cornerRadius: 10))
            
            VStack {
                HStack {
                    HStack {
                        if (selectStaticDateType == 0) {
                            Text("\(year)年\(month)月").font(.system(size: 16,weight: .bold))
                                .onTapGesture {
                                    showDatePickerType = .YM
                                    showDatePickerTime = true
                                    datePickerDateValue.year = year
                                    datePickerDateValue.month = month
                                    initData()
                                }
                        } else {
                            Text("\(year)年").font(.system(size: 16,weight: .bold))
                                .onTapGesture {
                                    showDatePickerType = .Y
                                    showDatePickerTime = true
                                    datePickerDateValue.year = year
                                    initData()
                                }
                        }
                        Image(systemName: "chevron.down").font(.system(size: 12,weight: .bold)).foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack {
                        createExpentIncomeTypeMenu(title: "支出", type: 0)
                        createExpentIncomeTypeMenu(title: "收入", type: 1)
                    }
                }.frame(minWidth: 0,maxWidth: .infinity)
                    .frame(height: 40)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack {
                            Text("共支出\(expendIncomeCount)笔，合计").font(.system(size: 14))
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Text("¥").font(.system(size: 30))
                            Text("\(DecimalUtils.trans2StringOfCurrency(expendIncomeMoney))")
                                .font(.system(size: 40, weight: .bold))
                            Spacer()
                        }
                    }.frame(minWidth: 0,maxWidth: .infinity)
                    .frame(height: 80)
                    .padding(20)
                    .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
                    
                    if (nil != chartData) {
                        VStack {
                            Group {
                                LineView(
                                    data: chartData!,
                                    lineBackgroundColor:Color("DefaultButtonBackgroud").opacity(0.5),
                                    style: lineViewStyle
                                )
                            }.frame(minWidth: 0,maxWidth: .infinity)
                                .frame(height: 150)
                                .offset(y:-30)
                        }.frame(height:210)
                            .padding(.vertical,10)
                            .padding(.horizontal,5)
                            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
                    }
                    if ((nil != peiDataList && peiDataList!.count > 0) || titleDataList.count > 0) {
                        VStack {
                            if (nil != peiDataList && peiDataList!.count > 0) {
                                HStack {
                                    Pie(peiDataList: peiDataList!)
                                }.frame(minWidth: 0, maxWidth: .infinity)
                                 .frame(height:200)
                            }
                            
                            VStack {
                                ForEach(titleDataList.indices, id:\.self) { index in
                                    let item = titleDataList[index]
                                    createListItem(iconStr: item.iconStr, title: item.title, percent: (item.value/expendIncomeMoney * 100).doubleValue, totalMoney: item.value, payCount: item.count)
                                }
                            }.padding(.horizontal, 10)
                        }.padding(.vertical,10)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
                    }
                   
                }
            }.padding(.horizontal,15)
                .safeAreaInset(edge: .bottom, content: {
                    Color.clear.frame(height: 30)
                })
                .selfDatePicker(showState: $showDatePickerTime, type: $showDatePickerType, param: $datePickerDateValue) { value in
                    self.datePickerDateValue = value
                    self.year = value.year ?? self.year
                    self.month = value.month ?? self.month
                    initData()
                }
        }.padding(.top,10)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color("ViewBackgroundColor"))
            .ignoresSafeArea()
            .onAppear() {
                initData()
            }
            
    }
    
    func initData() {
        self.loadData()
    }
    
    func loadData() {
        if nil == globalModel.accountBook {
            return
        }
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: year, cache: globalModel)
            computerAndShow(yearData)
        } catch {
            
        }
    }
    
    /**
     计算并且展示
     */
    func computerAndShow(_ yearData:AccountBookYearData?) {
        if (selectStaticDateType == 0) {
            computerAndShowOfMonth(yearData)
        } else {
            computerAndShowOfYear(yearData)
        }
        showWithExpendAndIncomeType()
    }
    /**
     计算月度
     */
    func computerAndShowOfMonth(_ yearData:AccountBookYearData?) {
        let expendMonthData = ExpendIncomeModel()
        let incomeMonthData = ExpendIncomeModel()
        if (nil == yearData) {
            self.staticData.expendData = expendMonthData
            self.staticData.incomeData = incomeMonthData
            return
        }
        // 目标1:按照日期进行分组
        let monthStr = month < 10 ? String("0\(month)") : String("\(month)")
        // 目标2:获取期望的展示数据
        let ymStr = String("\(year)\(monthStr)")
        // 月度记录
        let monthDataArray = yearData!.data[ymStr]
        if (nil != monthDataArray && monthDataArray!.count > 0) {
            for dataItem in monthDataArray! {
                // 要计算处理的对象
                let handleObj = dataItem.type == 0 ? expendMonthData : incomeMonthData
                // 1.笔数
                handleObj.totalCount += 1
                // 支出总金额
                handleObj.totalValue += (Decimal(string: dataItem.money) ?? 0)
                // 按日期统计数据
                var monthDataTemp = handleObj.monthData[dataItem.dateStr]
                if (nil == monthDataTemp) {
                    monthDataTemp = ExpendIncomeDateData(dateStr: dataItem.dateStr)
                    handleObj.monthData[dataItem.dateStr] = monthDataTemp
                }
                monthDataTemp!.value += (Decimal(string: dataItem.money) ?? 0)
                monthDataTemp!.count += 1
                // 按标题统计数据
                var titleDataTemp = handleObj.titleData[dataItem.title]
                if (nil == titleDataTemp) {
                    titleDataTemp = ExpendIncomeTitleData(title: dataItem.title)
                    handleObj.titleData[dataItem.title] = titleDataTemp
                }
                titleDataTemp!.iconStr = dataItem.iconStr
                titleDataTemp!.value += (Decimal(string: dataItem.money) ?? 0)
                titleDataTemp!.count += 1
            }
        }
        self.staticData.expendData = expendMonthData
        self.staticData.incomeData = incomeMonthData
    }
    /**
     计算年度
     */
    func computerAndShowOfYear(_ yearData:AccountBookYearData?) {
        let expendMonthData = ExpendIncomeModel()
        let incomeMonthData = ExpendIncomeModel()
        if (nil == yearData) {
            self.staticData.expendData = expendMonthData
            self.staticData.incomeData = incomeMonthData
            return
        }
        for monthItem in 1...12 {
            // 目标1:按照日期进行分组
            let monthStr = monthItem < 10 ? String("0\(monthItem)") : String("\(monthItem)")
            // 目标2:获取期望的展示数据
            let ymStr = String("\(year)\(monthStr)")
            // 月度记录
            let monthDataArray = yearData!.data[ymStr]
            if (nil != monthDataArray && monthDataArray!.count > 0) {
                for dataItem in monthDataArray! {
                    // 要计算处理的对象
                    let handleObj = dataItem.type == 0 ? expendMonthData : incomeMonthData
                    // 1.笔数
                    handleObj.totalCount += 1
                    // 支出总金额
                    handleObj.totalValue += (Decimal(string: dataItem.money) ?? 0)
                    // 按月份统计数据
                    var monthDataTemp = handleObj.monthData[ymStr]
                    if (nil == monthDataTemp) {
                        monthDataTemp = ExpendIncomeDateData(dateStr: ymStr)
                        handleObj.monthData[ymStr] = monthDataTemp
                    }
                    monthDataTemp!.value += (Decimal(string: dataItem.money) ?? 0)
                    monthDataTemp!.count += 1
                    // 按标题统计数据
                    var titleDataTemp = handleObj.titleData[dataItem.title]
                    if (nil == titleDataTemp) {
                        titleDataTemp = ExpendIncomeTitleData(title: dataItem.title)
                        handleObj.titleData[dataItem.title] = titleDataTemp
                    }
                    titleDataTemp!.iconStr = dataItem.iconStr
                    titleDataTemp!.value += (Decimal(string: dataItem.money) ?? 0)
                    titleDataTemp!.count += 1
                }
            }
        }
        self.staticData.expendData = expendMonthData
        self.staticData.incomeData = incomeMonthData
    }
    
    func showWithExpendAndIncomeType() {
        if (expendIncomeType == 0) {
            expendIncomeCount = self.staticData.expendData.totalCount
            expendIncomeMoney = self.staticData.expendData.totalValue
            chartData = self.staticData.expendData.charData(year: year, month: month, type: selectStaticDateType)
            peiDataList = self.staticData.expendData.peiDataList()
            titleDataList = self.staticData.expendData.titleDataListWithSort()
        } else {
            expendIncomeCount = self.staticData.incomeData.totalCount
            expendIncomeMoney = self.staticData.incomeData.totalValue
            chartData = self.staticData.incomeData.charData(year: year, month: month, type: selectStaticDateType)
            peiDataList = self.staticData.incomeData.peiDataList()
            titleDataList = self.staticData.incomeData.titleDataListWithSort()
        }
    }
    
    func createTopMenuView(code:Int, title:String) -> some View {
        Text(title)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 30)
            .foregroundColor(selectStaticDateType == code ? .white : .secondary)
            .font(.system(size: 14,weight: .bold))
            .background(Color.white.opacity(0.01))
            .animation(.easeInOut(duration: 0.2), value: selectStaticDateType)
            .onTapGesture {
                if (selectStaticDateType != code) {
                    self.showDatePickerTime = false
                    self.selectStaticDateType = code
                    self.year = DateUtils.findComponentsOfDate([.year], date: Date()).year!
                    self.month = DateUtils.findComponentsOfDate([.month], date: Date()).month!
                    initData()
                }
            }
    }
    
    /**
      创建之初和收入的类型按钮
     */
    func createExpentIncomeTypeMenu(title:String, type:Int) -> some View {
        Text(title)
            .padding(.horizontal,10)
            .padding(.vertical,5)
            .font(.system(size: 12,weight: .bold))
            .foregroundColor(expendIncomeType == type ? Color("DefaultButtonBackgroud") : .secondary)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color("DefaultButtonBackgroud").opacity(expendIncomeType == type ? 1 : 0),style: .init(lineWidth: 2)))
            .onTapGesture {
                if (self.expendIncomeType != type) {
                    self.showDatePickerTime = false
                    self.expendIncomeType = type
                    self.showWithExpendAndIncomeType()
                }
            }
    }
    /**
     创建列表项
     */
    func createListItem(iconStr:String, title:String, percent:Double, totalMoney:Decimal, payCount:Int) -> some View {
        HStack {
            Text(iconStr)
                .font(.custom("iconfont", size: 25))
                .foregroundColor( Color("DefaultButtonBackgroud"))
                .padding(10)
                .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 10))
            VStack {
                HStack {
                    Text("\(title)").font(.system(size: 14,weight: .bold))
                    Text("\(percent,specifier:specifier)%").font(.system(size: 12,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(DecimalUtils.trans2StringOfCurrency(totalMoney))").font(.system(size: 14,weight: .bold))
                    Text("(\(payCount)笔)").font(.system(size: 12,weight: .bold))
                        .foregroundColor(.secondary)
                }
                
                GeometryReader{ reader in
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("DefaultButtonBackgroud"))
                            .frame(width: reader.frame(in: .local).width * percent / 100)
                            .frame(height: 5)
                        Spacer()
                    }
                }
            }.padding(.vertical,5)
        }.padding(.horizontal,5)
    }
}



struct AccountBookStatisticComponent_Previews: PreviewProvider {
    static var previews: some View {
        AccountBookStatisticComponent().preferredColorScheme(.light)
    }
}
