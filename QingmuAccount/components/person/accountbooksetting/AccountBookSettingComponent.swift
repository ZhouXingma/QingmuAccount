//
//  AccountBookSetting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
import Foundation

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
    // 资产账户列表（用于解析默认账户名称）
    @State private var assetAccounts: [AssetAccountModel] = []

    /// 当前账本：优先使用已选账本，其次默认账本
    private var currentBook: AccountBookModel? {
        accountBooks.first { $0.name == selectAccountBook }
            ?? accountBooks.first { $0.name == AccountBookHandleService.DEFAULT_NAME }
            ?? accountBooks.first
    }

    /// 除当前账本外的其他账本
    private var otherBooks: [AccountBookModel] {
        guard let currentBook = currentBook else { return accountBooks }
        return accountBooks.filter { $0.id != currentBook.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏（返回 + 居中标题 + 对称占位）
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
                VStack(alignment: .leading, spacing: 0) {
                    // 当前账本书封
                    if let currentBook = currentBook {
                        AccountBookCoverCard(
                            accountBook: currentBook,
                            defaultAccountName: defaultAccountName(of: currentBook),
                            onTap: { handleEdit(currentBook) }
                        )
                        .padding(.top, 6)
                    }

                    // 其他账本
                    if !otherBooks.isEmpty {
                        otherBooksHeader

                        VStack(spacing: 9) {
                            ForEach(otherBooks) { item in
                                AccountBookManageRow(
                                    accountBook: item,
                                    defaultAccountName: defaultAccountName(of: item),
                                    isCurrent: item.name == selectAccountBook,
                                    canDelete: isNotSelectedOrDefault(item),
                                    onEdit: { handleEdit(item) },
                                    onSetCurrent: { changeCurrent(item) },
                                    onDelete: { handleDeleted(item.name) }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            // 新建账本
            Button {
                handleEdit(nil)
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                    Text("新建账本")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
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

    /// 「其他账本」分组标题
    private var otherBooksHeader: some View {
        HStack(spacing: 7) {
            Text("其他账本")
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundColor(.secondary)

            Text("\(otherBooks.count)")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(minWidth: 19, minHeight: 19)
                .padding(.horizontal, 5)
                .background(Color.gray.opacity(0.14), in: Capsule())
        }
        .padding(.top, 22)
        .padding(.bottom, 10)
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
     切换当前账本
     */
    private func changeCurrent(_ item: AccountBookModel) {
        guard item.name != selectAccountBook else { return }
        selectAccountBook = item.name
        globalModel.refreshAccountBook(item)
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

// MARK: - 当前账本书封
struct AccountBookCoverCard: View {
    let accountBook: AccountBookModel
    // 默认账户名称（未设置时为空串）
    let defaultAccountName: String
    let onTap: () -> Void

    private var coverColor: Color {
        Color(hex: accountBook.bgColor.count > 0 ? accountBook.bgColor : ColorConfig.SOFT_COLORS[0])
    }

    private var textColor: Color {
        accountBookInk(for: accountBook.bgColor)
    }

    // 「当前账本」胶囊为浅色底，使用深色内容
    private var pillInk: Color { Color(hex: "17211B") }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 书页叠层
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("MainBackgroundColor"))
                .padding(.horizontal, 20)
                .offset(y: 6)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("MainBackgroundColor"))
                .padding(.horizontal, 10)
                .offset(y: 3)

            coverContent
                .padding(16)
                .background(coverColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.bottom, 6)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(perform: onTap)
    }

    private var coverContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.12))
                    Text(hexStr2Unicode(accountBook.iconStr))
                        .font(.custom("icomoon", size: 26))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.16), radius: 1.5, x: 0, y: 1)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 3) {
                    Text(StringUtils.trim(accountBook.name))
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(textColor)
                        .lineLimit(1)

                    if let description = accountBook.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 12.5))
                            .foregroundColor(textColor.opacity(0.72))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("当前账本")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(pillInk)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.62), in: Capsule())
            }

            Rectangle()
                .fill(textColor.opacity(0.18))
                .frame(height: 1)
                .padding(.top, 16)

            HStack(spacing: 12) {
                Text(defaultAccountName.isEmpty ? "未设置默认账户" : defaultAccountName)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(AssetCurrency.name(of: accountBook.defaultCurrency))
                    .lineLimit(1)
            }
            .font(.system(size: 12.5, weight: .medium))
            .foregroundColor(textColor.opacity(0.78))
            .padding(.top, 12)
        }
    }
}

// MARK: - 其他账本行
struct AccountBookManageRow: View {
    let accountBook: AccountBookModel
    // 默认账户名称（未设置时为空串）
    let defaultAccountName: String
    let isCurrent: Bool
    let canDelete: Bool
    let onEdit: () -> Void
    let onSetCurrent: () -> Void
    let onDelete: () -> Void

    private var iconColor: Color {
        Color(hex: accountBook.bgColor.count > 0 ? accountBook.bgColor : ColorConfig.SOFT_COLORS[0])
    }

    var body: some View {
        HStack(spacing: 12) {
            // 点击账本内容进入编辑
            Button(action: onEdit) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(iconColor)
                        Text(hexStr2Unicode(accountBook.iconStr))
                            .font(.custom("icomoon", size: 21))
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(StringUtils.trim(accountBook.name))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("FontColor"))
                            .lineLimit(1)

                        if let description = accountBook.description, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 11.5))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)

                    Text(accountBookTag)
                        .font(.system(size: 11.5))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 116, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // 更多操作
            Menu {
                if !isCurrent {
                    Button(action: onSetCurrent) {
                        Label("设为当前账本", systemImage: "checkmark.circle")
                    }
                }
                Button(action: onEdit) {
                    Label("编辑账本", systemImage: "pencil")
                }
                if canDelete {
                    Button(role: .destructive, action: onDelete) {
                        Label("删除账本", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 64)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
    }

    /// 默认账户 · 默认币型文案
    private var accountBookTag: String {
        if defaultAccountName.isEmpty {
            return AssetCurrency.name(of: accountBook.defaultCurrency)
        }
        return "\(defaultAccountName) · \(AssetCurrency.name(of: accountBook.defaultCurrency))"
    }
}

/// 根据封面底色选择深/浅内容色，保证浅色账本上的文字与图标可读
private func accountBookInk(for hex: String) -> Color {
    let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    guard let value = UInt64(String(cleaned.prefix(6)), radix: 16) else {
        return Color(hex: "17211B")
    }
    let r = Double((value >> 16) & 0xFF) / 255.0
    let g = Double((value >> 8) & 0xFF) / 255.0
    let b = Double(value & 0xFF) / 255.0

    func linear(_ v: Double) -> Double {
        return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
    }

    let luminance = 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    return luminance > 0.2 ? Color(hex: "17211B") : .white
}
