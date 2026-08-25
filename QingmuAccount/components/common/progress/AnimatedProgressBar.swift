//
//  AnimatedProgressBar.swift
//  QingmuAccount
//  通用横向进度条：数值变化时平滑过渡，支持自定义颜色。
//  Created by 周荥马 on 2026/8/15.
//

import SwiftUI

struct AnimatedProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var trackColor: Color = Color("MainShadowColor").opacity(0.12)
    var progressColor: Color = Color("DefaultButtonBackgroud")
    var animation: Animation = .easeOut(duration: 0.6)

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                Capsule().fill(progressColor)
                    .frame(width: reader.size.width * CGFloat(min(max(animatedProgress, 0), 1)))
            }
        }
        .frame(height: height)
        .clipped()
        .onAppear {
            withAnimation(animation) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(animation) {
                animatedProgress = newValue
            }
        }
    }
}
