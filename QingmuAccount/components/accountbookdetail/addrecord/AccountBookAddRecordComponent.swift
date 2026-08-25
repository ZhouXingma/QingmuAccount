//
//  AccountBookAddRecordComponent.swift
//  QingmuAccount
//  支出和收入
//  Created by 周荥马 on 2022/12/5.
//

import SwiftUI
struct  AccountBookAddRecordComponent : View {
    @EnvironmentObject var globalModel:GlobalModel
    @State var recordType:Int = 0
    //  新记录进行操作了，添加了新记录后执行的函数
    @State var newRecordUpdate:(AccountBookData)->Void = {_ in }
    // 进行更新的数据
    @State var updateRecord:AccountBookData? = nil
    // 列表进入还是日历进入
    @Binding var listType:Int;
    // 日历选择的时间
    @Binding var selectDate:Date?
    
    var body: some View {
        VStack {
            topTitleMenu
            TabView(selection: $recordType) {
                RecordAddOfExpend(newRecordUpdate:newRecordUpdate, updateRecord:$updateRecord, listType: $listType, selectDate: $selectDate).tag(0)
                RecordAddOfIncome(newRecordUpdate:newRecordUpdate, updateRecord:$updateRecord,listType: $listType, selectDate: $selectDate).tag(1)
            }.tabViewStyle(.page(indexDisplayMode: .never))
        }.ignoresSafeArea()
            .background(Color("ViewBackgroundColor"))
            .onAppear() {
                if (nil != updateRecord) {
                    recordType = updateRecord!.type == 1 ? 1 : 0
                }
            }
            .onTapGesture {
                toHideKeyboard()
            }
            
    }
    
    /**
     标题
     */
    var topTitleMenu:some View {
        HStack {
            VStack {
                Text("支出")
                    .foregroundColor(recordType == 0 ? Color("DefaultButtonBackgroud") : .secondary)
                    .font(.system(size: 18,weight: .bold))
                    .animation(.easeIn, value: recordType == 1)
                RoundedRectangle(cornerRadius: 10).frame(width:recordType == 0 ? 30 : 0, height: 3).foregroundColor(Color("DefaultButtonBackgroud"))
                    .animation(.easeIn, value: recordType == 1)
                    .offset(y:-5)
                
            }.frame(width: 100).onTapGesture {
                recordType = 0
            }
            VStack {
                Text("收入")
                    .foregroundColor(recordType == 1 ? Color("DefaultButtonBackgroud") : .secondary)
                    .font(.system(size: 18,weight: .bold))
                    .animation(.easeIn, value: recordType == 1)
                RoundedRectangle(cornerRadius: 10).frame(width:recordType == 1 ? 30 : 0, height: 3).foregroundColor(Color("DefaultButtonBackgroud"))
                    .animation(.easeIn, value: recordType == 1)
                    .offset(y:-5)
            }.frame(width: 100)
            .onTapGesture {
                recordType = 1
            }
           
        }.padding(.top,20)
       
    }
    
}
