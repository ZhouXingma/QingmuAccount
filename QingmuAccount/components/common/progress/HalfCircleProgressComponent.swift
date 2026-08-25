//
//  HalfCircleProgress.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/1.
//

import SwiftUI

struct HalfCircleProgressComponent : View {
    var size:Double = 20
    var bgColor:Color = Color("DefaultButtonBackgroud").opacity(0.3)
    var InnerColor:Color = Color("DefaultButtonBackgroud")
    @Binding var percent:Double
    @State var appear = false
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(style: StrokeStyle(lineWidth: size, lineCap: .round))
                .fill(bgColor)
                .rotationEffect(.degrees(180))
            Circle()
                .trim(from: 0, to: (appear ? percent/2 : 0))
                .stroke(style: StrokeStyle(lineWidth: size, lineCap: .round))
                .fill(InnerColor)
                .rotationEffect(.degrees(180))
                .onAppear {
                    withAnimation(.spring(response: 2, dampingFraction: 0.925, blendDuration: 0.925).delay(0.2)) {
                        appear = true
                    }
                }
                .onDisappear {
                    appear = false
                }
                .onChange(of: percent) { newValue in
                    appear = false
                    withAnimation(.spring(response: 2, dampingFraction: 0.925, blendDuration: 0.925).delay(0.2)) {
                        appear = true
                    }
                }
        }
    }
}
