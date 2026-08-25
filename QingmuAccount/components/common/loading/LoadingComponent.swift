//
//  LodingComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
struct LoadingComponent : View {
    @State private var isAnimal : Bool = false
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(0...5,id:\.self) { i in
                Capsule(style: .circular)
                    .fill(Color("DefaultButtonBackgroud"))
                    .frame(width: 8,height: 40)
                    .scaleEffect(isAnimal ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.2),value: isAnimal)
            }
        }.onAppear(){
            isAnimal.toggle()
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0, maxHeight: .infinity)
            .background(.ultraThinMaterial)
    }
}
