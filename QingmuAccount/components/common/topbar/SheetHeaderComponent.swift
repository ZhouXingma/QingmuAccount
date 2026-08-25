//
//  SheetHeaderComponent.swift
//  QingmuAccount
//  通用 sheet 顶部：指示条 + 可选居中标题（标题为空则不显示）。
//  Created by 周荥马 on 2026/8/15.
//

import SwiftUI

struct SheetHeaderComponent: View {
    // 可选标题（为空则只显示指示条）
    var title: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            // 顶部指示条
            RoundedRectangle(cornerRadius: 2.5)
                .frame(width: 30, height: 5)
                .foregroundColor(Color("DefaultButtonBackgroud"))
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .padding(.top, 10)
    }
}
