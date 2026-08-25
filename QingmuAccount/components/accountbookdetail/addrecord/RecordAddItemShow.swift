//
//  RecordAddItemModel.swift
//  QingmuAccount
//
//  添加记录-收入支出的计算展示
//  Created by 周荥马 on 2022/12/7.
//

import SwiftUI

struct RecordAddItemShow : View {
    @Binding var iconStr:String
    @Binding var money:String
    @Binding var title:String
    @Binding var desc:String
    @Binding var computerDesc:String
    var body: some View {
        HStack {
            Text(hexStr2Unicode(iconStr))
                .font(.custom("icomoon", size: 35))
                .foregroundColor( Color("DefaultButtonBackgroud"))
                .padding(10)
                .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 16)).padding(.bottom,2)
                if (desc != "") {
                    Text(desc).font(.system(size: 12)).foregroundColor(.secondary)
                }
            }
            Spacer()
            ZStack {
                HStack{
                    Spacer()
                    Text("¥")
                    Text(money).font(.system(size: 20,weight: .bold))
                }
                VStack {
                    HStack {
                        Spacer()
                        Text(computerDesc).font(.system(size: 12,weight: .bold)).foregroundColor(.secondary)
                            .padding(.top,5)
                    }
                    Spacer()
                }
                
            }
        }.frame(minWidth: 0,maxWidth: .infinity)
            .frame(height: 80)
            .padding(.horizontal,10)
            .frame(height: 80)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 15))
    }
}
