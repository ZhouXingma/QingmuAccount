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
    // 资产账户列表（用于解析默认账户名称）
    @State private var assetAccounts: [AssetAccountModel] = []
    // 等待加载数据
    @State private var loadingWait = false
    // 显示提醒
    @State private var alterShow = false
    @State private var alterConfig = AlertComponentConfig(showCancelButton: false,sureButtonName: "我知道了")


    var body: some View {
        VStack(spacing: 0) {
            // 标题栏（返回 + 居中标题 + 对称占位）
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                }
                Spacer()
                Text("选择账本")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                Spacer()
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("FontColor"))
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 6)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(accountBooks, id:\.self.hashValue) { item in
                        AccountBookItem(
                            name: item.name,
                            iconValue: item.iconStr,
                            bgColor: item.bgColor,
                            description: item.description,
                            defaultAccountName: defaultAccountName(of: item),
                            defaultCurrency: item.defaultCurrency,
                            selectAccountBookName: $selectAccountBook
                        )
                        .onTapGesture {
                            if (selectAccountBook != item.name) {
                                // 推迟到下一个 RunLoop，避免在视图更新事务内发布状态变更
                                DispatchQueue.main.async {
                                    selectAccountBook = item.name
                                    globalModel.refreshAccountBook(item)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
        }
        .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        .selfLoading(showState: $loadingWait)
        .selfAlter(showState: $alterShow, config: alterConfig)
        .onAppear() {
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
            // 资产账户（用于解析默认账户名称）
            self.assetAccounts = (try? AssetAccountOfCacheService.getAccounts(cache: globalModel)) ?? []
        } catch {
            openAlert("加载账本失败", .RED)
        }
        self.loadingWait = false
    }

    /**
     解析账本的默认账户名称（未设置时返回空串）
     */
    func defaultAccountName(of book: AccountBookModel) -> String {
        guard !book.defaultAssetAccountId.isEmpty else { return "" }
        return assetAccounts.first { $0.id.uuidString == book.defaultAssetAccountId }?.name ?? ""
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
