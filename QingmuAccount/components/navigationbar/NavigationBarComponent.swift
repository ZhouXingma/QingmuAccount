//
//  NavigationBarComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

struct NavigationBarComponent : View {
    @State var title:String
    var body: some View {
        ZStack{
            Color.clear
                .background(.ultraThinMaterial)
                .blur(radius: 10)
                .opacity(0)
            Text("\(title)")
                .font(.system(size: 30, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading,20)
        }.frame(height: 150)
            .frame(maxHeight:.infinity, alignment: .top)
    }
}
