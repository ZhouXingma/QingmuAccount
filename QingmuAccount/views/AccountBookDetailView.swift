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
    @State private var alterConfig = AlertComponentConfig()
    // 最后加载时间
    @State private var latestLoadTime:Date = Date()
    var body: some View {
        ZStack {
            // 底部菜单栏
            subBar
            VStack {
                if listType==0 {
                    // 列表模式
                    AccountBookDetailOfListComponent(latestLoadTime:$latestLoadTime).environmentObject(globalModel)
                } else if listType==1 {
                    // 日历模式
                    AccountBookDetailOfCalendarComponent(latestLoadTime:$latestLoadTime).environmentObject(globalModel)
                }
            }
        }.ignoresSafeArea()
            .onAppear() {
                getAccountBookSeting()
            }
            .sheet(isPresented: $showAddRecord) {
                AccountBookAddRecordComponent(newRecordUpdate: { item in
                    latestLoadTime = Date()
                }, updateRecord: nil).environmentObject(globalModel)
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
            
    }
    // 底部菜单栏
    var subBar : some View {
        VStack {
            Spacer()
            HStack(alignment:.center) {
                Spacer()
                // 列表
                Image(systemName: "list.dash")
                    .font(.system(size: 20))
                    .foregroundColor(listType == 0 ?  Color("DefaultButtonBackgroud") : Color("FontColorSecend"))
                    .onTapGesture {
                        if (listType != 0) {
                            listType = 0
                        }
                    }
                Spacer()
                // 按钮
                Button {
                    openAddRecord()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color("DefaultButtonBackgroud"),in: Circle())
                        .shadow(color: Color("MainShadowColor").opacity(0.2), radius:8, x: 0, y:-4)
                }.offset(y:-10)
                Spacer()
                // 日历
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(listType == 1 ?  Color("DefaultButtonBackgroud") : Color("FontColorSecend"))
                    .onTapGesture {
                        if (listType != 1) {
                            listType = 1
                        }
                    }
                Spacer()
            }.frame(minWidth: 0,maxWidth: .infinity)
                .padding(.vertical,10)
                .padding(.bottom,30)
                .frame(height: 80)
                .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color("MainShadowColor").opacity(0.2), radius:4, x: 0, y:-2)
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
                alterConfig.desc = "加载账本配置信息失败，无法进行后续操作"
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
            alterConfig.desc = "加载账本配置信息失败"
            alterConfig.sureButtonName = "重试"
            alterConfig.sureFun = getAccountBookSeting
            showAlter = true
        }
    }
}


struct AccountBookDetailViewTabViewSub : View {
    let currentSelection:Int
    @Binding var selection:Int
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: selection == currentSelection ? 20 : 5, height: 5)
            .foregroundColor(Color("DefaultButtonBackgroud"))
            .animation(.easeInOut,value: selection == currentSelection)
            
    }
}
