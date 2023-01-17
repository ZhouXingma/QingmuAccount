//
//  RecordIconSeting.swift
//  QingmuAccount
//  图标设置
//  Created by 周荥马 on 2022/12/13.
//

import SwiftUI
struct RecordIconSeting : View {
    @EnvironmentObject var globalModel:GlobalModel
    // 图标类型
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
    // 发生改变图标
    @State var haveChangeIcons:()->Void
    // 显示图标编辑
    @State var showIconEdit:Bool = false
    // 编辑图标
    @State var editAccountBookIcon:AccountBookSetingOfIconModel? = nil
    
    var body: some View {
        VStack {
            titleView
            HStack {
                Text("长按图标可以拖动进行排序～")
                    .font(.system(size: 12,weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            VStack {
                TabView(selection: $iconType){
                    IconSetingOfIconList(showIconEdit:$showIconEdit, iconList: $iconOfExpend,handleChange: saveIconSeting,editAccountBookIcon: $editAccountBookIcon).tag(0)
                    IconSetingOfIconList(showIconEdit:$showIconEdit, iconList: $iconOfIncome,handleChange: saveIconSeting,editAccountBookIcon: $editAccountBookIcon).tag(1)
                }.tabViewStyle(.page(indexDisplayMode: .never))
            
            }.frame(minWidth: 0, maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            
        }.padding(.horizontal,15)
            .padding(.top,20)
            .frame(minWidth: 0, maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .background(Color("ViewBackgroundColor"))
            .sheet(isPresented: $showIconEdit, content: {
                RecordIconEdit(addOrUpdateIconFunc:addOrUpdateIconFunc,removeIconFunc: removeIconFunc,editAccountBookIcon: $editAccountBookIcon).environmentObject(globalModel)
            })
            .onAppear() {
                loadAccountBookSeting()
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
           
    }
    
    // 头部按钮
    var titleView:some View {
        HStack {
            VStack {
                Text("支出")
                    .foregroundColor(iconType == 0 ? Color("DefaultButtonBackgroud") : .secondary)
                    .font(.system(size: 18,weight: .bold))
                    .animation(.easeIn, value: iconType == 1)
                RoundedRectangle(cornerRadius: 10).frame(width:iconType == 0 ? 30 : 0, height: 3).foregroundColor(Color("DefaultButtonBackgroud"))
                    .animation(.easeIn, value: iconType == 1)
                    .offset(y:-5)
                
            }.frame(width: 50).onTapGesture {
                iconType = 0
            }
            VStack {
                Text("收入")
                    .foregroundColor(iconType == 1 ? Color("DefaultButtonBackgroud") : .secondary)
                    .font(.system(size: 18,weight: .bold))
                    .animation(.easeIn, value: iconType == 1)
                RoundedRectangle(cornerRadius: 10).frame(width:iconType == 1 ? 30 : 0, height: 3).foregroundColor(Color("DefaultButtonBackgroud"))
                    .animation(.easeIn, value: iconType == 1)
                    .offset(y:-5)
            }.frame(width: 50)
            .onTapGesture {
                iconType = 1
            }
            Spacer()
            VStack {
                Button {
                    editAccountBookIcon = nil
                    showIconEdit = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 25))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                }
                Spacer()
            }.frame(height: 40)
        }
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
    // 保存图标设置
    func saveIconSeting() {
        if (nil == globalModel.accountBook) {
            return
        }
        accountBookSeting?.inRecordIconSeting = iconOfIncome
        accountBookSeting?.outRecordIconSeting = iconOfExpend
        if (nil != accountBookSeting) {
            do {
                try AccountBookSetingOfCacheService.updateSetting(globalModel.accountBook!.id.description, accountBookSeting!, cache: globalModel)
                haveChangeIcons()
            } catch {
                showSaveAccountBookSetingError()
            }
        }
    }
    
    /**
     添加图标
     */
    func addOrUpdateIconFunc(_ iconStr:String, _ name:String,_ id:String) -> Bool {
        if (StringUtils.trimCount(id) > 0) {
            return updateIconFunc(iconStr, name, id)
        }
        return addIconFunc(iconStr, name)
    }
    /**
     修改图标
     */
    func updateIconFunc(_ iconStr:String, _ name:String,_ id:String) -> Bool {
        let iconList = iconType == 0 ? iconOfExpend : iconOfIncome
        if (checkIsExit(iconList,name)) {
            return false
        }
        for item in iconList {
            if (item.id == id) {
                item.iconStr = iconStr
                item.name = name
                break
            }
        }
        saveIconSeting()
        return true
    }
    
    func removeIconFunc(_ id:String) -> Bool {
        var iconList = iconType == 0 ? iconOfExpend : iconOfIncome
        let iconCount = iconList.count
        var indexId:Int? = nil
        for i in 0...iconCount-1 {
            let item = iconList[i]
            if (item.id == id) {
                indexId = i
                break
            }
        }
        if (nil != indexId) {
            iconList.remove(at: indexId!)
        } else {
            return false
        }
        if (iconType == 0) {
            iconOfExpend = iconList
        } else {
            iconOfIncome = iconList
        }
        saveIconSeting()
        return true
    }
    /**
     添加图标
     */
    func addIconFunc(_ iconStr:String, _ name:String) -> Bool {
        if iconType == 0 {
            if (checkIsExit(iconOfExpend,name)) {
                return false
            }
            iconOfExpend.append(AccountBookSetingOfIconModel(iconStr: iconStr, name: name, sort: 0))
        } else if iconType == 1 {
            if (checkIsExit(iconOfIncome,name)) {
                return false
            }
            iconOfIncome.append(AccountBookSetingOfIconModel(iconStr: iconStr, name: name, sort: 0))
        }
        saveIconSeting()
        return true
    }
    
    func checkIsExit(_ iconList:[AccountBookSetingOfIconModel], _ name:String) -> Bool {
        for item in iconList {
            if (item.name == name) {
                return true
            }
        }
        return false
    }

}

struct IconSetingOfIconList : View {
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 5), count: 5)
    // 图标列表
    // 显示图标编辑
    @Binding var showIconEdit:Bool
    @Binding var iconList:[AccountBookSetingOfIconModel]
    @State var handleChange:()->Void = {}
    @State var selectIconStr:String = ""
    @StateObject var dropData:DropData = DropData()
    @Binding var editAccountBookIcon:AccountBookSetingOfIconModel?
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: iConGridItems) {
                    ForEach(iconList,id:\.self) { item in
                        RecordItemIconButton(iconStr:item.iconStr, name:item.name, selectIconStr: $selectIconStr)
                            .opacity(dropData.draggingItem?.id == item.id ? 0.01 : 1)
                            .onDrag ({
                                keyFeedback()
                                let a = MYItemProvider(contentsOf: URL(string: "\(item.id)"))!
                                a.didEnd = {
                                    DispatchQueue.main.async {
                                        dropData.draggingItem = nil
                                        handleChange()
                                    }
                                }
                                return a
                            })
                            .onDrop(of: [.item], delegate: DropViewDelegate(currentItem: item, dropData: dropData, iconList:$iconList))
                            .onTapGesture {
                                showIconEdit = true
                                editAccountBookIcon = item
                            }
                    }
                }
            }
        }
    }
}


class MYItemProvider: NSItemProvider {
    var didEnd: (() -> Void)?
    deinit {
        didEnd?()     // << here !!
    }
}



struct DropViewDelegate: DropDelegate {
    var currentItem: AccountBookSetingOfIconModel
    var dropData: DropData
    var iconList: Binding<[AccountBookSetingOfIconModel]>
    
    func dropEntered(info: DropInfo) {
        if (nil == dropData.draggingItem) {
            dropData.draggingItem = currentItem
        }
        let from = iconList.wrappedValue.firstIndex(of: dropData.draggingItem!)!
        let to = iconList.wrappedValue.firstIndex(of: currentItem)!
        if from != to {
            keyFeedback()
           withAnimation(.default) {
               iconList.wrappedValue.move(fromOffsets: IndexSet(integer: from),
               toOffset: to > from ? to + 1 : to)
           }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        if (nil == dropData.draggingItem) {
            dropData.draggingItem = currentItem
        }
        return true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        keyFeedback()
        dropData.draggingItem = nil
        return true
    }
}


class DropData: ObservableObject {
    @Published var draggingItem:AccountBookSetingOfIconModel?
}
