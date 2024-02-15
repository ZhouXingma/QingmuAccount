//
//  AccountBookDetailOfCalendarComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/2.
//

import SwiftUI
struct AccountBookDetailOfCalendarComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    @State private var dayDatas:[AccountBookData] = []
    // 列表滑动通知
    @StateObject var notifaction = SelfSwiperNotification()
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    @State private var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    @State private var selectDate:Date = Date()
    // 编辑记录
    @State var editRecord:Bool = false
    // 编辑的记录数据
    @State var editAccountBookData:AccountBookData? = nil
    // 最后加载时间
    @Binding var latestLoadTime:Date
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                CalendarComponent(monthDataHandle:monthDataHandle, year:$year, month:$month, selectDate:$selectDate, latestLoadTime:$latestLoadTime)
            }.padding(.vertical,10)
                .padding(.horizontal,10)
                .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(dayDatas.sorted(by: { item1, item2 in
                        (item1.dateStr as NSString).longLongValue >= (item2.dateStr as NSString).longLongValue
                    }),id:\.self) { item in
                        recordDayListItem(item)
                    }
                }
            }.padding(.top,10)
        }.ignoresSafeArea()
        .padding(.horizontal,15)
        .padding(.bottom,100)
        .sheet(isPresented: $editRecord, content: {
            AccountBookRecordEditComponent(accountBookData: editAccountBookData!, newRecordUpdate: { item in
                self.latestLoadTime = Date()
            }).environmentObject(globalModel)
        })
        .onChange(of: latestLoadTime, perform: { newValue in
            realoadDayDatas()
        })
        .onChange(of: globalModel.accountBook, perform: { newValue in
            // 初始化数据
            realoadDayDatas()
        })
        .onChange(of: selectDate, perform: { newValue in
            realoadDayDatas()
        })
        .onAppear() {
            realoadDayDatas()
        }
    }
    /*
     加载每日数据
     */
    func realoadDayDatas() {
        if nil == globalModel.accountBook {
            return
        }
        do {
            let year = DateUtils.findComponentsOfDate([.year], date: self.selectDate).year!
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year:year, cache: globalModel)
            if let yearDataReal = yearData {
                // 计算展示出来
                self.dayDatas = findDatesValue(self.selectDate, yearDataReal)
            } else {
                self.dayDatas = []
            }
        } catch {
            
        }
    }
    
    /*
     月度数据
     */
    func monthDataHandle(calendarShowData: CalendarShowData) {
        if nil == globalModel.accountBook {
            return
        }
        do {
            let yearData = try AccountBookDataOfCacheService.getData(globalModel.accountBook!.id.description, year: calendarShowData.show.year, cache: globalModel)
            if let yearDataReal = yearData {
                // 计算展示出来
                computerMonthDataHandleShow(calendarShowData, yearDataReal)
            }
        } catch {
            
        }
    }
    // 计算月度标点符号显示
    func computerMonthDataHandleShow(_ calendarShowData: CalendarShowData, _ yearDataReal:AccountBookYearData) {
        calendarShowData.show.datas = calendarShowDateItemsShow(calendarShowData.show, yearDataReal)
        calendarShowData.pre.datas = calendarShowDateItemsShow(calendarShowData.pre, yearDataReal)
        calendarShowData.next.datas = calendarShowDateItemsShow(calendarShowData.next, yearDataReal)
    }
    
    func calendarShowDateItemsShow(_ calendarShowDateItems: CalendarShowDateItems, _ yearDataReal:AccountBookYearData) -> [CalendarDateModel] {
        let datas = calendarShowDateItems.datas
        let ymStr = DateUtils.ymStr(calendarShowDateItems.year, calendarShowDateItems.month)
        // ym - []
        let monthDatas = yearDataReal.data[ymStr] ?? []
        // ymd:[]
        var dayDatasMap:[String:[AccountBookData]] = [:]
        
        for item in monthDatas {
            var datas = dayDatasMap[item.dateStr] ?? []
            datas.append(item)
            dayDatasMap[item.dateStr] = datas
        }
        for dataItem in datas {
            let ymd = DateUtils.transDate2String(dataItem.day, format: "yyyyMMdd")
            let dayDatas = dayDatasMap[ymd]
            dataItem.mark = false
            if nil != dayDatas && dayDatas!.count > 0 {
                dataItem.mark = true
                let totalMoney:Decimal = dayDatas!.reduce(Decimal(0.0)) { partialResult, item in
                    var resultTemp = partialResult
                    if item.type == 0 {
                        // 支出
                        resultTemp = partialResult - (Decimal(string:item.money) ?? Decimal(0))
                    } else  if item.type == 1 {
                        resultTemp = partialResult + (Decimal(string:item.money) ?? Decimal(0))
                    }
                    return resultTemp
                }
                dataItem.desc = String("\(totalMoney)")
            }
        }
        return datas
    }
    // 查找日期的数据
    func findDatesValue(_ date:Date, _ yearDataReal:AccountBookYearData) -> [AccountBookData] {
        if (yearDataReal.data.count <= 0) {
            return []
        }
        let ymd = DateUtils.transDate2String(date, format: "yyyyMMdd")
        let ym = DateUtils.transDate2String(date, format: "yyyyMM")
        let accountBookDatas = yearDataReal.data[ym]
        var dayValues:[AccountBookData] = []
        if (nil != accountBookDatas) {
            for item in accountBookDatas! {
                if item.dateStr == ymd {
                    dayValues.append(item)
                }
            }
        }
        return dayValues
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
            .onTapGesture {
                self.notifaction.handleId = nil
                self.editAccountBookData = recordItem
                self.editRecord = true
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
    
    // 删除记录真正的操作
    func deleteRecord(_ recordItem:AccountBookData) {
        do {
            try AccountBookDataOfCacheService.deleteData(globalModel.accountBook!.id.description, data: recordItem, cache: globalModel)
            self.latestLoadTime = Date()
        } catch {
            
        }
    }
}

