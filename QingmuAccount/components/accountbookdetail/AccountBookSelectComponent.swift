//
//  AccountBookSelectComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/31.
//

import SwiftUI
struct AccountBookSelectComponent : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    @AppStorage("selectAccountBook") private var selectAccountBook = AccountBookHandleService.DEFAULT_NAME
    // 账本列表
    @State private var accountBooks:[AccountBookModel] = []
    // 等待加载数据
    @State private var loadingWait = false
    // 显示提醒
    @State private var alterShow = false
    @State private var alterConfig = AlertComponentConfig(showCancelButton: false,sureButtonName: "我知道了")
    
    
    var body: some View {
        VStack {
            DefaultTopBarComponent {
                presentationMode.wrappedValue.dismiss()
            }
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(accountBooks, id:\.self.hashValue) { item in
                        AccountBookItem(name: item.name, iconValue: item.iconStr, bgColor: item.bgColor, selectAccountBookName:$selectAccountBook)
                            .onTapGesture {
                                if (selectAccountBook != item.name) {
                                    selectAccountBook = item.name
                                    globalModel.refreshAccountBook(item)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                    }
                }.padding(.horizontal,15)
                    .padding(.vertical,10)
            }
            Spacer()
           
        }.background(Color("ViewBackgroundColor"))
            .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .selfLoading(showState: $loadingWait)
            .selfAlter(showState: $alterShow, config: alterConfig)
            .navigationBarBackButtonHidden()
            .navigationBarHidden(true)
            .selfDragBack {
                presentationMode.wrappedValue.dismiss()
            }.onAppear() {
                readAccountBooks()
            }
    }
    
    /**
     读取账本信息
     */
    func readAccountBooks() {
        self.loadingWait = true
        do {
            // 获取数据
            let data:[String:AccountBookModel]? = try AccountBookHandleOfCacheService.getAccountBooks(cache: globalModel)
            // 处理数据
            self.accountBooks = data!.values.sorted { item1, item2 in
                return item1.gmtCreated < item2.gmtCreated
            }
        } catch {
            openAlert("加载账本失败", .RED)
        }
        self.loadingWait = false
    }
    
    /**
     开启提示
     */
    func openAlert(_ desc:String, _ style:AlertComponentTopBarColorStyle = .DEFAULT) {
        alterConfig.desc = desc
        alterConfig.topBarColorStyle = style
        withAnimation(.easeIn) {
            alterShow = true
        }
    }
}
