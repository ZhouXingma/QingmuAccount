//
//  RecordIconSeting.swift
//  QingmuAccount
//  图标设置
//  Created by 周荥马 on 2022/12/13.
//

import SwiftUI
struct RecordIconSeting : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    // 图标类型（0 = 支出，1 = 收入）
    @State var iconType:Int = 0
    // 收入图标
    @State var iconOfIncome:[AccountBookSetingOfIconModel] = defaultAccountBookInRecordIcon
    // 支出图标
    @State var iconOfExpend:[AccountBookSetingOfIconModel] = defaultAccountBookOutRecordIcon
    // 提醒
    @State var showAlter = false
    @State var alterConfig = AlertComponentConfig()
    // 账本配置信息
    @State var accountBookSeting:AccountBookSetingModel? = nil
    // 图标发生改变（保存后回调用刷新记账页图标）
    @State var haveChangeIcons:()->Void
    // 显示图标编辑
    @State var showIconEdit:Bool = false
    // 编辑图标
    @State var editAccountBookIcon:AccountBookSetingOfIconModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderComponent()
                .padding(.bottom, 12)
            segmentView
            tipView
            gridArea
            bottomBar
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .sheet(isPresented: $showIconEdit, content: {
            RecordIconEdit(addOrUpdateIconFunc: { iconStr, name, id in
                addOrUpdateIcon(iconStr, name, id)
            }, removeIconFunc: { id in
                removeIcon(id)
            }, editAccountBookIcon: $editAccountBookIcon).environmentObject(globalModel)
        })
        .onAppear() {
            loadAccountBookSeting()
        }
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    // 支出 / 收入 分段切换
    var segmentView: some View {
        HStack(spacing: 0) {
            segmentButton(title: "支出", type: 0)
            segmentButton(title: "收入", type: 1)
        }
        .padding(4)
        .background(Color("MainBackgroundColor"), in: Capsule())
        .padding(.horizontal, 20)
    }

    func segmentButton(title: String, type: Int) -> some View {
        let selected = iconType == type
        return Text(title)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(selected ? .white : Color("FontColor"))
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(selected ? Color("DefaultButtonBackgroud") : Color.clear, in: Capsule())
            .contentShape(Capsule())
            .onTapGesture {
                keyFeedback(0)
                withAnimation(.easeInOut(duration: 0.2)) {
                    iconType = type
                }
            }
    }

    // 操作提示
    var tipView: some View {
        HStack(spacing: 4) {
            Image(systemName: "hand.draw")
                .font(.system(size: 11))
            Text("长按图标拖动排序，点击图标可编辑，记得点保存哦～")
                .font(.system(size: 12))
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // 图标网格（支出 / 收入）
    var gridArea: some View {
        Group {
            if iconType == 0 {
                SortableIconGrid(iconList: $iconOfExpend, onTapItem: { item in
                    editAccountBookIcon = item
                    showIconEdit = true
                })
            } else {
                SortableIconGrid(iconList: $iconOfIncome, onTapItem: { item in
                    editAccountBookIcon = item
                    showIconEdit = true
                })
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding(.horizontal, 15)
        .padding(.top, 6)
    }

    // 底部操作栏：添加 + 保存（不同颜色区分，保存为主操作更大）
    var bottomBar: some View {
        GeometryReader { proxy in
            HStack(spacing: 12) {
                // 添加图标（次要操作，描边样式）
                Button {
                    keyFeedback()
                    editAccountBookIcon = nil
                    showIconEdit = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("添加")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("DefaultButtonBackgroud"), lineWidth: 1.5)
                    )
                }
                .frame(width: proxy.size.width * 0.4, height: 48)
                // 保存（主操作，实底更大）
                Button {
                    keyFeedback()
                    if saveIconSeting() {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("保存")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 24)
    }

    // 加载账本设置
    func loadAccountBookSeting() {
        if (nil != globalModel.accountBook) {
            do {
                let seting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
                accountBookSeting = seting
                if (nil != seting) {
                    iconOfExpend = seting!.outRecordIconSeting
                    iconOfIncome = seting!.inRecordIconSeting
                }
            } catch {
                showLoadAccountBookSetingError()
            }

        } else {
            showLoadAccountBookSetingError()
        }
    }
    // 显示加载账本信息失败
    func showLoadAccountBookSetingError () {
        alterConfig.showCancelButton = false
        alterConfig.desc = "加载账本信息失败，无法进行后续操作"
        alterConfig.sureButtonName = "重试"
        alterConfig.sureFun = loadAccountBookSeting
        showAlter = true
    }
    // 保存图标设置失败
    func showSaveAccountBookSetingError () {
        alterConfig.showCancelButton = false
        alterConfig.desc = "保存图标设置失败"
        alterConfig.sureButtonName = "我知道了"
        showAlter = true
    }
    // 保存图标设置（点击保存按钮时写入数据库）
    @discardableResult
    func saveIconSeting() -> Bool {
        if (nil == globalModel.accountBook) {
            return false
        }
        accountBookSeting?.inRecordIconSeting = iconOfIncome.enumerated().map { index, item in
            AccountBookSetingOfIconModel(id: item.id, iconStr: item.iconStr, name: item.name, sort: index)
        }
        accountBookSeting?.outRecordIconSeting = iconOfExpend.enumerated().map { index, item in
            AccountBookSetingOfIconModel(id: item.id, iconStr: item.iconStr, name: item.name, sort: index)
        }
        if (nil != accountBookSeting) {
            do {
                try AccountBookSetingOfCacheService.updateSetting(globalModel.accountBook!.id.description, accountBookSeting!, cache: globalModel)
                haveChangeIcons()
                return true
            } catch {
                showSaveAccountBookSetingError()
                return false
            }
        }
        return false
    }

    /**
     添加/修改图标（仅改内存，保存按钮写入数据库）
     */
    func addOrUpdateIcon(_ iconStr:String, _ name:String,_ id:String) -> Bool {
        if (StringUtils.trimCount(id) > 0) {
            return updateIcon(iconStr, name, id)
        }
        return addIcon(iconStr, name)
    }
    /**
     修改图标
     */
    func updateIcon(_ iconStr:String, _ name:String,_ id:String) -> Bool {
        if iconType == 0 {
            guard !checkIsExit(iconOfExpend, name, exceptId: id) else { return false }
            iconOfExpend = iconOfExpend.map { item in
                item.id == id ? AccountBookSetingOfIconModel(id: item.id, iconStr: iconStr, name: name, sort: item.sort) : item
            }
        } else {
            guard !checkIsExit(iconOfIncome, name, exceptId: id) else { return false }
            iconOfIncome = iconOfIncome.map { item in
                item.id == id ? AccountBookSetingOfIconModel(id: item.id, iconStr: iconStr, name: name, sort: item.sort) : item
            }
        }
        return true
    }
    /**
     删除图标
     */
    func removeIcon(_ id:String) -> Bool {
        if iconType == 0 {
            guard iconOfExpend.contains(where: { $0.id == id }) else { return false }
            iconOfExpend.removeAll { $0.id == id }
        } else {
            guard iconOfIncome.contains(where: { $0.id == id }) else { return false }
            iconOfIncome.removeAll { $0.id == id }
        }
        return true
    }
    /**
     添加图标
     */
    func addIcon(_ iconStr:String, _ name:String) -> Bool {
        if iconType == 0 {
            guard !checkIsExit(iconOfExpend, name) else { return false }
            iconOfExpend.append(AccountBookSetingOfIconModel(iconStr: iconStr, name: name, sort: 0))
        } else {
            guard !checkIsExit(iconOfIncome, name) else { return false }
            iconOfIncome.append(AccountBookSetingOfIconModel(iconStr: iconStr, name: name, sort: 0))
        }
        return true
    }

    func checkIsExit(_ iconList:[AccountBookSetingOfIconModel], _ name:String, exceptId:String = "") -> Bool {
        for item in iconList {
            if (item.name == name && item.id != exceptId) {
                return true
            }
        }
        return false
    }

}

// MARK: - 可拖动排序的图标网格

struct SortableIconGrid: View {
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 5), count: 5)
    @Binding var iconList:[AccountBookSetingOfIconModel]
    let onTapItem:(AccountBookSetingOfIconModel)->Void
    @State private var selectIconStr:String = ""
    // 拖动状态
    @StateObject private var dropData:SortableDropData = SortableDropData()

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: iConGridItems, spacing: 5) {
                ForEach(iconList, id: \.id) { item in
                    RecordItemIconButton(iconStr: item.iconStr, name: item.name, selectIconStr: $selectIconStr)
                        .opacity(dropData.draggingItem?.id == item.id ? 0.15 : 1)
                        .onDrag {
                            keyFeedback()
                            dropData.draggingItem = item
                            let provider = DragItemProvider(object: item.id as NSString)
                            provider.onDragEnd = {
                                DispatchQueue.main.async {
                                    dropData.draggingItem = nil
                                }
                            }
                            return provider
                        }
                        .onDrop(of: [.text], delegate: SortableDropDelegate(currentItem: item, dropData: dropData, iconList: $iconList))
                        .onTapGesture {
                            // 快速点击打开编辑；拖动过程中（draggingItem 非空）不触发
                            if (nil == dropData.draggingItem) {
                                onTapItem(item)
                            }
                        }
                }
            }
        }
    }
}

// 拖动过程中的状态
class SortableDropData: ObservableObject {
    @Published var draggingItem:AccountBookSetingOfIconModel? = nil
}

// 拖动会话结束（含取消）时清空状态
class DragItemProvider: NSItemProvider {
    var onDragEnd:(() -> Void)?
    deinit {
        if let onDragEnd = onDragEnd {
            DispatchQueue.main.async(execute: onDragEnd)
        }
    }
}

// 处理放入排序
struct SortableDropDelegate: DropDelegate {
    var currentItem: AccountBookSetingOfIconModel
    var dropData: SortableDropData
    var iconList: Binding<[AccountBookSetingOfIconModel]>

    func dropEntered(info: DropInfo) {
        guard let draggingItem = dropData.draggingItem else { return }
        guard let from = iconList.wrappedValue.firstIndex(where: { $0.id == draggingItem.id }) else { return }
        let to = iconList.wrappedValue.firstIndex(where: { $0.id == currentItem.id }) ?? from
        guard from != to else { return }
        keyFeedback()
        withAnimation(.easeInOut(duration: 0.15)) {
            iconList.wrappedValue.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        true
    }

    func performDrop(info: DropInfo) -> Bool {
        dropData.draggingItem = nil
        return true
    }
}
