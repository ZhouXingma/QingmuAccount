//
//  LodingStyle.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

struct SelfLoadingStyle: ViewModifier {
    @Binding var showState:Bool
    func body(content: Content) -> some View {
        content.overlay {
            if(showState) {
                LoadingComponent()
            }
        }
    }
}

extension View {
    func selfLoading(showState:Binding<Bool>) -> some View {
        modifier(SelfLoadingStyle(showState: showState))
    }
}
