//
//  AccountBookRecordEditComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/11.
//

import SwiftUI

struct AccountBookRecordEditComponent : View {
    // 环境
    @EnvironmentObject var globalModel:GlobalModel
    // 用于关闭当前窗口
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 账本的记录信息
    @State var accountBookData: AccountBookData
    // 是否开启更新数据
    @State var updateData = false
    // 是否有数据进行编辑，删除或者修改
    @State var newRecordUpdate:(AccountBookData) -> Void = {_ in }
    // 显示提醒
    @State var showAlter = false
    @State var alterConfig = AlertComponentConfig()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    deleteRecordAlter()
                } label: {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 25))
                        .foregroundColor(Color("RedColor"))
                }
            }.padding(.horizontal,15)
                .padding(.top,20)
                .padding(.bottom,5)
            
            VStack {
                HStack {
                    Text("图标").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(hexStr2Unicode(accountBookData.iconStr))
                        .frame(width: 35,height: 35)
                        .font(.custom("icomoon", size: 25))
                        .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                }.frame(height: 40)
                HStack {
                    Text("标题").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(accountBookData.title).font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
                HStack {
                    Text("金额").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(accountBookData.money).font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
                HStack {
                    Text("类型").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(accountBookData.type == 0 ? "支出":"收入")").font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
                HStack {
                    Text("日期").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(transDateStrFormat(accountBookData.dateStr)).font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
                HStack {
                    Text("创建时间").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(DateUtils.transDate2String(accountBookData.gmtCreated, format: "yyyy-MM-dd HH:mm:ss")).font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
                HStack {
                    Text("修改时间").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(DateUtils.transDate2String(accountBookData.gmtModfied, format: "yyyy-MM-dd HH:mm:ss")).font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
                HStack {
                    Text("备注").font(.system(size: 14,weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(accountBookData.desc).font(.system(size: 14,weight: .bold))
                }.frame(height: 40)
            }.frame(minWidth: 0,maxWidth: .infinity)
                .padding(20)
                .background(Color("MainBackgroundColor"),in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal,15)
               
            Spacer()
            Button {
                updateData = true
            } label: {
                Text("编辑").tint(.white)
                    .font(.system(size: 16,weight: .bold))
                    .frame(width: 250, height: 50, alignment: .center)
                    .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
            }.padding(.vertical,20)
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .background(Color("ViewBackgroundColor"))
            .sheet(isPresented: $updateData) {
                AccountBookAddRecordComponent(newRecordUpdate: haveEditRecord, updateRecord: accountBookData)
            }
            .selfAlter(showState: $showAlter, config: alterConfig)
    }
    // 有内容进行编辑
    func haveEditRecord(_ changeAccountBookData: AccountBookData) {
        accountBookData = changeAccountBookData
        newRecordUpdate(changeAccountBookData)
    }
    // 删除记录提醒
    func deleteRecordAlter() {
        alterConfig.desc = "确定删除改记录吗？"
        alterConfig.sureFun = deleteRecord
        showAlter = true
    }
    // 删除记录真正的操作
    func deleteRecord() {
        do {
            try AccountBookDataOfCacheService.deleteData(globalModel.accountBook!.id.description, data: accountBookData, cache: globalModel)
            newRecordUpdate(accountBookData)
            presentationMode.wrappedValue.dismiss()
        } catch {
            
        }
    }
    
    // 日期格式转换：dataStr(yyyyMMdd)转换为（yyyy-MM-dd）
    func transDateStrFormat(_ dataStr:String) -> String{
        var tempValue = dataStr
        tempValue.insert(contentsOf: "-", at: dataStr.index(dataStr.startIndex, offsetBy: 4))
        tempValue.insert(contentsOf: "-", at: dataStr.index(dataStr.startIndex, offsetBy: 7))
        return tempValue
    }
}
