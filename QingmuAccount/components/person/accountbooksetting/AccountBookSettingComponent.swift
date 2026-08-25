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
    // 资产账户列表（用于解析默认账户名称）
    @State private var assetAccounts: [AssetAccountModel] = []
    
    var body: some View {
        VStack {
            // 标题栏
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                }
                
                Spacer()
                
                Text("账本")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                
                Spacer()
                
                // 占位符，保持居中
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                    .opacity(0)
            }
            .frame(height: 44)
            .padding(.horizontal, 15)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(accountBooks, id: \.self.hashValue) { item in
                        VStack {
                            AccountBookCardItem(
                                accountBook: item,
                                isSelected: item.name == selectAccountBook,
                                onEdit: { handleEdit(item) },
                                onDelete: { handleDeleted(item.name) },
                                notification: notifaction,
                                selectAccountBookName: $selectAccountBook,
                                onTap: { handleEdit(item) },
                                defaultAccountName: defaultAccountName(of: item),
                                defaultCurrency: item.defaultCurrency
                            )
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
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 16)
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
            // 资产账户（用于解析默认账户名称）
            assetAccounts = (try? AssetAccountOfCacheService.getAccounts(cache: globalModel)) ?? []
        } catch {
            openAlert("加载账本失败", .RED)
        }
        loadingWait = false
    }
    /**
     解析账本的默认账户名称（未设置时返回空串）
     */
    func defaultAccountName(of book: AccountBookModel) -> String {
        guard !book.defaultAssetAccountId.isEmpty else { return "" }
        return assetAccounts.first { $0.id.uuidString == book.defaultAssetAccountId }?.name ?? ""
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

// MARK: - 新账本卡片组件
struct AccountBookCardItem: View {
    let accountBook: AccountBookModel
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let notification: SelfSwiperNotification
    @Binding var selectAccountBookName: String
    let onTap: () -> Void
    // 默认账户名称（未设置时为空串）
    let defaultAccountName: String
    // 默认币型（ISO 代码）
    let defaultCurrency: String

    var body: some View {
        HStack(spacing: 12) {
            // 左侧图标
            ZStack {
                Color(hex: accountBook.bgColor.count > 0 ? accountBook.bgColor : ColorConfig.SOFT_COLORS[0])
                    .cornerRadius(8)

                Text(hexStr2Unicode(accountBook.iconStr))
                    .font(.custom("icomoon", size: 20))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)

            // 中间内容：名称 + 备注
            VStack(alignment: .leading, spacing: 3) {
                Text(accountBook.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                    .lineLimit(1)

                if let description = accountBook.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 右侧：默认账户 · 默认币型（不占用名称下方备注的位置）
            Text(accountBookTag)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 60)
        .background(Color("MainBackgroundColor"))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }

    /// 默认账户 · 默认币型文案
    private var accountBookTag: String {
        if defaultAccountName.isEmpty {
            return AssetCurrency.name(of: defaultCurrency)
        }
        return "\(defaultAccountName) · \(AssetCurrency.name(of: defaultCurrency))"
    }
}



