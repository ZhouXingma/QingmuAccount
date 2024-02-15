//
//  Statistics.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/24.
//

import SwiftUI

struct AssetsView : View {
    @EnvironmentObject var globalModel:GlobalModel
    @State private var type = 0
    @State private var showAssert = false
    // 存款
    @State private var depositValue:Decimal = 0
    // 负债
    @State private var liabilitiesValue:Decimal = 0
    // 数据
    @State private var datas:[String:String] = [:]
    // 记录数据
    @State private var records:[AssertsDataItem] = []
    // 年
    @State private var year:Int = DateUtils.findComponentsOfDate([.year], date: Date()).year!
    // 月
    @State private var month:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 数据加载时间，用于更新数据
    @State private var lastUpdateTime = Date()
    // 显示日期选择
    @State private var showDatePicker = false
    @State private var datePickerType = DatePickerType.YM
    @State private var datePickerValue = DatePickerValue()
    // 显示详情
    @State private var showDetail = false
    // 要显示的账户信息
    @State private var showDetailItem:String = ""
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        Text("存款")
                            .font(.system(size: 14,weight: .bold))
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        Text("\(DecimalUtils.trans2StringOfCurrency(depositValue))")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "arrowtriangle.up.fill")
                            .foregroundColor(Color("MainBackgroundColor"))
                    }.offset(y:28)
                        .opacity(type == 0 ? 1 : 0)
                }.padding(10)
                    .foregroundColor(.white)
                    .frame(minWidth: 0,maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color("DefaultButtonBackgroud"),in:RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing,2.5)
                    .onTapGesture {
                        keyFeedback()
                        type = 0
                        initData()
                    }
                VStack {
                    HStack {
                        Text("负债")
                            .font(.system(size: 14,weight: .bold))
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        Text("\(DecimalUtils.trans2StringOfCurrency(liabilitiesValue))")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "arrowtriangle.up.fill")
                            .foregroundColor(Color("MainBackgroundColor"))
                    }.offset(y:28)
                        .opacity(type == 1 ? 1 : 0)
                }.padding(10)
                    .foregroundColor(.white)
                    .frame(minWidth: 0,maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color("RedColor"),in:RoundedRectangle(cornerRadius: 10))
                    .padding(.leading,2.5)
                    .onTapGesture {
                        keyFeedback()
                        type = 1
                        initData()
                    }
            }
            VStack {
                HStack {
                    Image(systemName: "eye").font(.system(size: 12, weight: .bold))
                    Text("总览").font(.system(size: 14, weight: .bold))
                    Spacer()
                }.frame(height: 30)
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(datas.keys.sorted(), id:\.self) { keyItem in
                            let item = datas[keyItem]!
                            HStack {
                                Text("\(keyItem)")
                                    .font(.system(size: 14, weight: .bold))
                                    .onTapGesture {
                                        showAssertsDetail(keyItem)
                                    }
                                Spacer()
                                Text("\(item)")
                                    .font(.system(size: 14, weight: .bold))
                            }.frame(height: 30).foregroundColor(Color("FontColor"))
                        }
                    }
                }
            }.padding(10)
                .frame(minHeight: 50)
                .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
                .padding(.top,5)
            
            VStack {
                HStack {
                    Image(systemName: "list.bullet").font(.system(size: 12, weight: .bold))
                    Text("记录").font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("\(String(year))年\(month)月").font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                        .onTapGesture {
                            datePickerValue.year = year
                            datePickerValue.month = month
                            showDatePicker = true
                        }
                }.frame(height: 30)
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(records,id:\.self) { item in
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
                        }
                    }
                }
            }.padding(10)
             .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 10))
            
            Button {
                keyFeedback()
                showAssert = true
            } label: {
                HStack {
                    Text("记一笔")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                        .padding(.vertical, 15)
                }.frame(width: 250, height: 50, alignment: .center)
                    .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
            }.padding(.bottom,30)
            
        }.padding(.horizontal,15)
            .ignoresSafeArea()
            .selfDatePicker(showState: $showDatePicker, type: $datePickerType, param: $datePickerValue,sureAction: { newValue in
                self.year = newValue.year ?? self.year
                self.month = newValue.month ?? self.month
                self.datePickerValue = newValue
                loadDataAndShow()
            })
            .sheet(isPresented: $showAssert) {
                AssetsEditComponent(depositValue: $depositValue, liabilitiesValue: $liabilitiesValue, lastUpdateTime:$lastUpdateTime, currentType: type).environmentObject(globalModel)
            }
            .sheet(isPresented: $showDetail) {
                AssertsDetailComponent(showDetailItem: $showDetailItem, type: $type, lastUpdateTime:$lastUpdateTime).environmentObject(globalModel)
            }
            .onAppear() {
                initData()
            }
            .onChange(of: lastUpdateTime) { newValue in
                initData()
            }
    }
    // 初始化数据
    func initData() {
        // 年
        self.year = DateUtils.findComponentsOfDate([.year], date: Date()).year!
        // 月
        self.month = DateUtils.findComponentsOfDate([.month], date: Date()).month!
        // 日期选择
        showDatePicker = false
        loadDataAndShow()
    }
    
    func loadDataAndShow() {
        var assertsData:AssertsData? = nil
        do {
            assertsData = try AssertsDataCacheService.getAsserts(cache: globalModel)
        } catch {
            
        }
        if let assertsDataReal = assertsData {
            refreshData(assertsDataReal)
        }
    }
    /**
     显示账户详情
     keyItem: 账户
     type: 类型
     */
    func showAssertsDetail(_ keyItem:String) {
        showDetailItem = keyItem
        showDetail = true
    }
    
    
    // 刷新数据
    func refreshData(_ assertsDataReal:AssertsData) {
        var liabilitiesTotal:Decimal = 0
        var depositTotal:Decimal = 0
        for assertsKey in assertsDataReal.deposit.keys {
            let valueStr = assertsDataReal.deposit[assertsKey]
            let value = Decimal(string: valueStr ?? "0")!
            depositTotal += value
        }
        
        for liabilitiesKey in assertsDataReal.liabilities.keys {
            let valueStr = assertsDataReal.liabilities[liabilitiesKey]
            let value = Decimal(string: valueStr ?? "0")!
            liabilitiesTotal += value
        }
        // 总数据
        self.depositValue = depositTotal
        self.liabilitiesValue = liabilitiesTotal
        let ymStr = DateUtils.ymStr(year, month)
        // 总览数据
        // 记录数据
        if self.type == 0 {
            self.datas = assertsDataReal.deposit
            self.records = assertsDataReal.depositData[ymStr] ?? []
           
        } else if type == 1 {
            self.datas = assertsDataReal.liabilities
            self.records = assertsDataReal.liabilitiesData[ymStr] ?? []
        }
        self.records = self.records.sorted { item1, item2 in
            item1.gmtModfied >= item2.gmtModfied
        }
    }
}
