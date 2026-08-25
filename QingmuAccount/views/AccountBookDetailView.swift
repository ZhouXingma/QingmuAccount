//
//  Records.swift
//  QingmuAccount
//
//  账本明细
//  Created by 周荥马 on 2022/11/24.
//

import SwiftUI

struct AccountBookDetailView : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 列表类型
    @State private var listType:Int = 0
    // 显示添加记录
    @State private var showAddRecord:Bool = false
    // 整本的配置信息
    @State private var accountBookSeting:AccountBookSetingModel? = nil
    // 显示提醒
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc:"加载账本配置信息失败")
    // 最后加载时间
    @State private var latestLoadTime:Date = Date()
    @State private var calendarSelectDate:Date? = nil
    // subBar 选中滑块动画命名空间
    @Namespace private var subBarNamespace
    var body: some View {
        ZStack {
            VStack {
                if listType==0 {
                    // 列表模式
                    AccountBookDetailOfListComponent(latestLoadTime:$latestLoadTime).environmentObject(globalModel)
                } else if listType==1 {
                    // 日历模式
                    AccountBookDetailOfCalendarComponent(latestLoadTime:$latestLoadTime,calendarSelectDate:$calendarSelectDate).environmentObject(globalModel)
                }
            }.ignoresSafeArea(.all,edges: .bottom)
                .padding(.top, 10)
            // 底部菜单栏
            subBar
        }.ignoresSafeArea(.all,edges: .bottom)
            .onAppear() {
                getAccountBookSeting()
            }
            .sheet(isPresented: $showAddRecord) {
                AccountBookAddRecordComponent(newRecordUpdate: { item in
                    latestLoadTime = Date()
                }, updateRecord: nil, listType:$listType, selectDate: $calendarSelectDate).environmentObject(globalModel)
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
            
    }
    // 底部菜单栏
    var subBar : some View {
        VStack {
            Spacer()
            HStack(alignment: .center, spacing: 12) {
                // 左侧椭圆胶囊：列表 / 日历（绿色背景胶囊滑动切换）
                HStack(spacing: 0) {
                    ZStack {
                        Capsule()
                            .fill(Color("DefaultButtonBackgroud"))
                            .frame(width: 82, height: 38)
                            .offset(x: listType == 0 ? -43 : 43)
                            .animation(.easeInOut(duration: 0.2), value: listType)
                        HStack(spacing: 0) {
                            subBarSegment(type: 0, icon: "list.dash", title: "列表")
                            subBarSegment(type: 1, icon: "calendar", title: "日历")
                        }
                    }
                    .frame(width: 172, height: 48)
                }
                .padding(4)
                .background(Color("MainBackgroundColor"), in: Capsule())
                .shadow(color: Color("MainShadowColor").opacity(0.2), radius: 4, x: 0, y: -2)
                Spacer()
                // 右侧圆形：添加记录
                Button {
                    openAddRecord()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color("DefaultButtonBackgroud"), in: Circle())
                        .shadow(color: Color("MainShadowColor").opacity(0.2), radius: 8, x: 0, y: -4)
                }
            }
        }.frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 20)
    }

    // 左侧胶囊内的切换按钮（高亮由滑动背景胶囊提供）
    func subBarSegment(type: Int, icon: String, title: String) -> some View {
        let selected = listType == type
        return HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(.system(size: 15, weight: .bold))
        }
        .foregroundColor(selected ? .white : Color("FontColorSecend"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if listType != type {
                listType = type
            }
        }
    }
    /**
     获取账本的基本配置
     */
    func getAccountBookSeting() {
        if nil != globalModel.accountBook {
            do {
                accountBookSeting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
            } catch {
                alterConfig.showCancelButton = false
                alterConfig.sureButtonName = "重试"
                alterConfig.sureFun = getAccountBookSeting
                showAlter = true
            }
        }
    }
    
    func openAddRecord() {
        keyFeedback()
        if (nil != accountBookSeting) {
            showAddRecord = true
        } else  {
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "重试"
            alterConfig.sureFun = getAccountBookSeting
            showAlter = true
        }
    }
}
