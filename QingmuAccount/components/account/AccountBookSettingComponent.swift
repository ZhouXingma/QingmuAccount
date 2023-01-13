//
//  AccountBookSetting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

struct AccountBookSettingComponent : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 全局环境
    @EnvironmentObject var globalModel:GlobalModel
    @AppStorage("selectAccountBook") private var selectAccountBook = AccountBookHandleService.DEFAULT_NAME
    // 是否显示添加账本界面
    @State private var showAdd = false
    // 等待加载数据
    @State private var loadingWait = false
    // 显示提醒
    @State private var alterShow = false
    @State private var alterConfig = AlertComponentConfig(showCancelButton: false,sureButtonName: "我知道了")
    // 账本列表
    @State private var accountBooks:[AccountBookModel] = []
    // 删除ID
    @State private var deletedName:String = ""
    @State private var updateAccountBook:AccountBookModel? = nil
    // 列表滑动通知
    @StateObject var notifaction = SelfSwiperNotification()
    
    var body: some View {
        VStack {
            DefaultTopBarComponent {
                presentationMode.wrappedValue.dismiss()
            }
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(accountBooks, id:\.self.hashValue) { item in
                        AccountBookItem(name: item.name, iconValue: item.iconStr, bgColor: item.bgColor, selectAccountBookName:$selectAccountBook)
                            .selfSwiper(id: item.id.description, maxOffsetX: isNotSelectedOrDefault(item) ? 124 : 62, notification: notifaction) {
                                if(isNotSelectedOrDefault(item)) {
                                    Button {
                                        handleDeleted(item.name)
                                    } label: {
                                        Image(systemName: "trash.circle")
                                            .frame(width: 60,height: 60)
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .background(Color("RedColor"),in:RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                Button {
                                    notifaction.handleId = nil
                                    handleEdit(item)
                                } label: {
                                    Image(systemName: "pencil.circle")
                                        .frame(width: 60,height: 60)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .background(Color("DefaultButtonBackgroud"),in:RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .onTapGesture {
                                notifaction.handleId = nil
                            }
                    }
                }.padding(.horizontal,15)
                    .padding(.vertical,10)
            }
            
            VStack {
                Button {
                    handleEdit(nil)
                } label: {
                    HStack {
                        Text("添加")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                            .padding(.vertical, 15)
                    }.frame(width: 250, height: 50, alignment: .center)
                        .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
                }
            }.padding(.horizontal,15)
            
        }
        .onAppear() {
            readAccountBooks()
        }
        .background(Color("ViewBackgroundColor"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .selfLoading(showState: $loadingWait)
        .selfAlter(showState: $alterShow, config: alterConfig)
        .sheet(isPresented: $showAdd) {
            AccountBookAddComponent(handleAccountBookSuccessFun: handleAccountBookSuccessFun, updateAccountBook: $updateAccountBook).environmentObject(globalModel)
        }.selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    func isNotSelectedOrDefault(_ item:AccountBookModel) -> Bool {
        return item.name != AccountBookHandleService.DEFAULT_NAME && item.name != selectAccountBook
    }
    
    /**
     读取账本信息
     */
    func readAccountBooks() {
        loadingWait = true
        do {
            // 获取数据
            let data:[String:AccountBookModel]? = try AccountBookHandleOfCacheService.getAccountBooks(cache: globalModel)
            // 处理数据
            accountBooks = data!.values.sorted { item1, item2 in
                return item1.gmtCreated < item2.gmtCreated
            }
        } catch {
            openAlert("加载账本失败", .RED)
        }
        loadingWait = false
    }
    /**
      处理文件
     */
    func handleAccountBookSuccessFun(data:[String : AccountBookModel]?) {
        var dateTemp = data
        if (nil == dateTemp) {
            dateTemp = globalModel.accountBooks
        }
        accountBooks = dateTemp!.values.sorted { item1, item2 in
            return item1.gmtCreated < item2.gmtCreated
        }
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
    
    /**
     删除账本
     */
    func handleDeleted(_ name:String) {
        self.deletedName = name
        alterConfig.showCancelButton = true
        alterConfig.cancalButtonName = "取消"
        alterConfig.showSureButton = true
        alterConfig.sureButtonName = "确定"
        alterConfig.sureFun = handleDeletedSure
        openAlert("确定删除这个账本吗？")
    }
    
    func handleDeletedSure() {
        do {
            let _ = try AccountBookHandleOfCacheService.deleteAccountBook(self.deletedName, cache: globalModel)
            readAccountBooks()
        } catch AccountBookHandleError.ISNOTEXIT {
            alterConfig.showCancelButton = false
            alterConfig.showSureButton = true
            alterConfig.sureButtonName = "我知道了"
            openAlert("该账本不存在",.RED)
        } catch {
            alterConfig.showCancelButton = false
            alterConfig.showSureButton = true
            alterConfig.sureButtonName = "我知道了"
            openAlert("操作失败",.RED)
        }
    }
    
    /**
     修改账本
     */
    func handleEdit(_ data:AccountBookModel?) {
        updateAccountBook = data
        withAnimation(.easeIn) {
            showAdd = true
        }
    }
}

struct AccountBookSettingComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        AccountBookSettingComponent().ignoresSafeArea().preferredColorScheme(.light).environmentObject(GlobalModel())
        AccountBookSettingComponent().ignoresSafeArea().preferredColorScheme(.dark).environmentObject(GlobalModel())
    }
}
