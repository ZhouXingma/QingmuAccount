//
//  AlertStyle.swift
//  QingmuAccount
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
            AlertComponent(showSate: $showState, config:config)
        }
    }
}

extension View {
    func selfAlter(showState:Binding<Bool>, config:AlertComponentConfig) -> some View {
        modifier(SelfAlterStyle(showState: showState, config: config))
    }
}
