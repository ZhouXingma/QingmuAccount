//
//  DefaultTopBarComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/1.
//

import SwiftUI

struct DefaultTopBarComponent : View {
    // 返回按钮的操作
    let backAction: () -> Void
    var body: some View {
        HStack {
            Button {
                backAction()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18,weight: .bold))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }.padding(.horizontal,20)
            .frame(height:20)
    }
}
