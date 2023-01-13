//
//  SelfToggle.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/29.
//

import SwiftUI

struct SelfToggle : View {
    var offColor:Color = .secondary.opacity(0.3)
    var onColor:Color = .blue
    @Binding var isOn:Bool
    var onToggleFunc:(Bool) -> Void = {_ in }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(isOn ? onColor : offColor)
                .frame(width: 50,height: 30)
                .padding(1)
                .overlay {
                    Circle().fill(.white).frame(width: 26,height: 26).offset(x:isOn ? 10 : -10)
                        .animation(.easeIn(duration: 0.2), value: isOn)
                }
                .onTapGesture {
                    isOn.toggle()
                    onToggleFunc(isOn)
                }
        }.frame(width: 50,height: 30)
    }
}

