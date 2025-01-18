//
//  AccountBookAddRecordOfInComponent.swift
//  QingmuAccount
//
//  账本记录-支出
//  Created by 周荥马 on 2022/12/7.

import SwiftUI

struct RecordAddOfExpend : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 5), count: 5)
    // 该支付类型
    let payType:Int = 0
    /**
     新记录进行操作了，添加了新记录后执行的函数
     */
    @State var newRecordUpdate:(AccountBookData)->Void = {_ in }
    // 数据
    @State var money:String = "0.00"
    @State var title:String = defaultAccountBookOutRecordIcon[0].name
    @State var desc:String = ""
    @State var iconStr:String = defaultAccountBookOutRecordIcon[0].iconStr
    @State var computerStr = ""
    @State var dateStr = DateUtils.transDate2String(Date(), format: "yyyyMMdd")
    // 提醒
    @State var showAlter = false
    @State var alterConfig = AlertComponentConfig()
    // 图标
    @State var outRecordIcons:[AccountBookSetingOfIconModel] = defaultAccountBookOutRecordIcon
    // 账本配置信息
    @State var accountBookSeting:AccountBookSetingModel? = nil
    @State var selectAccountBook:AccountBookModel? = nil
    // 进行更新的数据
    @Binding var updateRecord:AccountBookData?
    // 显示图标编辑
    @State var showEditIcon:Bool = false
    
    
    var body: some View {
        VStack {
            HStack {
                RecordAddItemShow(iconStr: $iconStr, money: $money, title: $title, desc: $desc, computerDesc: $computerStr)
            }.padding(.horizontal,15)
                .padding(.vertical,5)
           
            ScrollView(.vertical,showsIndicators: false) {
                LazyVGrid(columns: iConGridItems) {
                    ForEach(outRecordIcons ,id:\.self) { item in
                        
                        RecordItemIconButton(iconStr:item.iconStr, name:item.name, selectIconStr: $iconStr)
                            .highPriorityGesture(
                                TapGesture().onEnded({ _ in
                                    keyFeedback()
                                    iconStr = item.iconStr
                                    title = item.name
                                })
                            )
                    }
                    RecordItemIconButton(iconStr:"plus.circle", name:"编辑",isImage: true, selectIconStr: $iconStr)
                        .highPriorityGesture(
                            TapGesture().onEnded({ _ in
                                keyFeedback()
                                showEditIcon = true
                            })
                        )
                }.padding(.horizontal,15)
                    .padding(.vertical,5)
            }
            keyBoard
        }.ignoresSafeArea()
            .sheet(isPresented: $showEditIcon, content: {
                RecordIconSeting(iconType: payType,haveChangeIcons: {
                    loadAccountBookInfo()
                    initUpdateData()
                }).environmentObject(globalModel)
            })
            .onAppear() {
                loadAccountBookInfo()
                initUpdateData()
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
    }

    /**
     键盘
     */
    var keyBoard:some View {
        AcountKeyBoard(date: trans2KeyDateStrFormat(updateRecord?.dateStr), desc: updateRecord?.desc ?? "") { newDesc in
            desc = newDesc
        } dateChangeFun: { newDate in
            dateStr = DateUtils.transDate2String(DateUtils.transString2Date(newDate, format: "yyyy-MM-dd") ?? Date(), format: "yyyyMMdd")
        } keyTabFun: { keyId in
            if (keyId == 15) {
                // 完成
                if ((money as NSString).doubleValue < 0) {
                    alterConfig.cancalButtonName = "清空"
                    alterConfig.desc="您这金额该是收入了"
                    alterConfig.cancelFun = reset
                    showAlter = true
                    return
                }
                if ((money as NSString).doubleValue == 0) {
                    alterConfig.cancalButtonName = "清空"
                    alterConfig.desc="请输入正常的金额"
                    alterConfig.cancelFun = reset
                    showAlter = true
                    return
                }
                // 完成其它操作
                if (nil != updateRecord) {
                    updateData()
                } else {
                    addData()
                }
            }
            if (computerStr.count >= 49 && keyId != 12) {
                // 超长计算
                alterConfig.cancalButtonName = "清空"
                alterConfig.desc="暂不支持超长计算"
                alterConfig.cancelFun = reset
                showAlter = true
                return
            }
            AcountKeyComputerHandle.handleAccountKeyTab(keyId: keyId, computerDesc: &computerStr, value: &money)
        }.frame(height: 260).padding(.bottom,25)
    }
    /**
     重置计算信息
     */
    func reset() {
        self.computerStr = ""
        self.money = "0.00"
    }
    
    
    func initUpdateData() {
        if nil == updateRecord {
            return 
        }
        if updateRecord!.type == payType {
            title = updateRecord!.title
            desc = updateRecord!.desc
            iconStr = updateRecord!.iconStr
            money = updateRecord!.money
            dateStr = updateRecord!.dateStr
            computerStr = ""
        } else {
            desc = updateRecord!.desc
            money = updateRecord!.money
            dateStr = updateRecord!.dateStr
            computerStr = ""
        }
    }
    
    func updateData() {
        if nil == updateRecord {
            return
        }
        let data = AccountBookData(id:updateRecord!.id,dateStr: dateStr, gmtCreated:updateRecord!.gmtCreated, type: payType, money: money, iconStr: iconStr, title: title, desc: desc)
        do {
            try AccountBookDataOfCacheService.updateData(globalModel.accountBook!.id.description, oldData: updateRecord!, newData: data, cache: globalModel)
            newRecordUpdate(data)
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "更新记录失败，您可以退出程序重试"
            alterConfig.showCancelButton = true
            alterConfig.cancalButtonName="取消"
            alterConfig.sureButtonName = "重试"
            alterConfig.sureFun = updateData
            showAlter = true
        }
    }
    
    /**
     添加记录
     */
    func addData() {
        if nil == globalModel.accountBook {
            showLoadAccountBookInfoError()
            return
        }
        let data = AccountBookData(dateStr: dateStr, type: payType, money: money, iconStr: iconStr, title: title, desc: desc)
        do {
            try AccountBookDataOfCacheService.addData(globalModel.accountBook!.id.description, data: data, cache: globalModel)
            newRecordUpdate(data)
            presentationMode.wrappedValue.dismiss()
        } catch {
            alterConfig.desc = "添加记录失败，您可以退出程序重试"
            alterConfig.showCancelButton = true
            alterConfig.cancalButtonName="取消"
            alterConfig.sureButtonName = "重试"
            alterConfig.sureFun = addData
            showAlter = true
        }
    }
    
    
    /**
     加载账本信息
     */
    func loadAccountBookInfo() {
        if (nil != globalModel.accountBook) {
            do {
                let seting = try AccountBookSetingOfCacheService.getSeting(globalModel.accountBook!.id.description, cache: globalModel)
                accountBookSeting = seting
                if (nil != seting) {
                    outRecordIcons = seting!.outRecordIconSeting
                    if (outRecordIcons.count > 0) {
                        iconStr = outRecordIcons[0].iconStr
                        title = outRecordIcons[0].name
                    }
                }
            } catch {
                showLoadAccountBookInfoError()
            }
            
        } else {
            showLoadAccountBookInfoError()
        }
    }
    
    func showLoadAccountBookInfoError () {
        alterConfig.showCancelButton = false
        alterConfig.desc = "加载账本信息失败，无法进行后续操作"
        alterConfig.sureButtonName = "重试"
        alterConfig.sureFun = loadAccountBookInfo
        showAlter = true
    }
    
    // dataStr(yyyyMMdd)转换为（yyyy-MM-dd）
    func trans2KeyDateStrFormat(_ dateStr:String?) -> String{
        if nil == dateStr {
            return "今天"
        }
        var tempValue = dateStr!
        tempValue.insert(contentsOf: "-", at: tempValue.index(tempValue.startIndex, offsetBy: 4))
        tempValue.insert(contentsOf: "-", at: tempValue.index(tempValue.startIndex, offsetBy: 7))
        let dateStr = DateUtils.transDate2String(Date(), format: "yyyy-MM-dd")
        if tempValue == dateStr {
            return "今天"
        }
        return tempValue
    }
}


