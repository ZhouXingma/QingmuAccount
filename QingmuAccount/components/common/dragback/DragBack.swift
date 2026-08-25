//
//  DragBack.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/29.
//

import SwiftUI

struct DragBackStyle: ViewModifier {
    public var backAction: () -> Void = {}
    
    @State private var myTranslation = CGSize.zero
    @State private var startLocation:Double = 0
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if (startLocation == 0) {
                    startLocation = value.location.x
                }
                myTranslation = value.translation
                if (startLocation < 80 && myTranslation.width > 100) {
                    backAction()
                }
            }
            .onEnded { value in
                startLocation = 0
                myTranslation = CGSize.zero
            }
    }
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(drag)
        
    }
}

extension View {
    func selfDragBack(_ backAction:@escaping () -> Void = {}) -> some View {
        modifier(DragBackStyle(backAction: backAction))
    }
}
