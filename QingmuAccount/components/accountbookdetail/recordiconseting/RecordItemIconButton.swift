//
//  RecordAddItemModel.swift
//  QingmuAccount
//
//  添加记录-收入支出的计算展示
//  Created by 周荥马 on 2022/12/7.
//

import SwiftUI

struct RecordItemIconButton : View {
    let iconStr:String
    let name:String
    var isImage:Bool = false
    @Binding var selectIconStr:String
    var body: some View {
        VStack {
            let isSelected = iconStr == selectIconStr
            if (!isImage) {
                VStack {
                    Text(hexStr2Unicode(iconStr))
                        .font(.custom("icomoon", size: 30))
                        .foregroundColor(isSelected ? Color("DefaultButtonBackgroud") : Color("FontColorSecend"))
                    Text(name).font(.system(size: 10,weight: .bold))
                        .foregroundColor(isSelected ? Color("DefaultButtonBackgroud") : Color("FontColorSecend"))
                }.frame(width: 55,height: 55)
                    .background(Color("MainBackgroundColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color("DefaultButtonBackgroud"):Color.clear,lineWidth: 3))
                
            } else {
                VStack {
                    Image(systemName: iconStr)
                        .font(.custom("icomoon", size: 30))
                        .foregroundColor(isSelected ? Color("DefaultButtonBackgroud") : Color("FontColorSecend"))
                    Text(name).font(.system(size: 10,weight: .bold))
                        .foregroundColor(isSelected ? Color("DefaultButtonBackgroud") : Color("FontColorSecend"))
                }.frame(width: 55,height: 55)
                    .background(Color("MainBackgroundColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color("DefaultButtonBackgroud"):Color.clear,lineWidth: 3))
                    
            }
        }
    }
}
