//
//  AlertStyle.swift
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

struct SelfAlterStyle: ViewModifier {
    @Binding var showState:Bool
    var config:AlertComponentConfig

    func body(content: Content) -> some View {
        ZStack {
            content
            if (showState) {
                // 半透明遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showState = false
                    }
                AlertComponent(showSate: $showState, config:config)
            }
        }
    }
}

extension View {
    func selfAlter(showState:Binding<Bool>, config:AlertComponentConfig) -> some View {
        modifier(SelfAlterStyle(showState: showState, config: config))
    }
}
