//
//  AccountBookItemComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/28.
//

import SwiftUI

struct AccountBookItem : View {
    @State var name: String
    @State var iconValue: String
    @State var bgColor: String
    @Binding var selectAccountBookName:String
    
    var body: some View {
        HStack {
            Text(iconValue).font(.custom("iconfont", size: 25))
                .foregroundColor(.white)
                .padding(10)
                .background(bgColor.count<=0 ? Color("DefaultButtonBackgroud") : Color(hex: bgColor), in: RoundedRectangle(cornerRadius: 10))
            Text(StringUtils.trim(name))
                .font(.system(size: 14, weight: .bold))
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 18))
                .foregroundColor(Color("DefaultButtonBackgroud"))
                .opacity(selectAccountBookName == name ? 1 : 0)
        }.padding(10)
        .frame(minWidth: 0,maxWidth: .infinity,alignment: .center)
        .frame(height: 60)
        .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
        
       
        
    }
}
