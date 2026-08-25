//
//  AlertComponent.swift
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
struct AlertComponent : View {
    @Binding public var showSate:Bool
    public var config:AlertComponentConfig

    var body: some View {
        VStack(spacing: 0) {
            // 顶部指示条
            RoundedRectangle(cornerRadius: 2.5)
                .frame(width: 30, height: 5)
                .padding(.vertical, 10)
                .foregroundColor(config.topBarColorStyle == .DEFAULT ? Color("DefaultButtonBackgroud") : Color("RedColor"))
            // 内容区
            VStack {
                Text(config.title)
                    .font(.system(size: 18, weight: .bold))
                Text(config.desc)
                    .font(.system(size: 16))
                    .padding(.vertical, 10)
                Spacer()
                // 按钮区
                HStack {
                    Button {
                        closeShow()
                        config.cancelFun()
                    } label: {
                        HStack {
                            Text(config.cancalButtonName)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 10)
                        }.frame(maxWidth: config.showCancelButton ? .infinity : 0)
                            .background(Color("RedColor"), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal,10)
                    }.opacity(config.showCancelButton ? 1 : 0)
                        .frame(maxWidth: config.showCancelButton ? .infinity : 0)

                    Button {
                        closeShow()
                        config.sureFun()
                    } label: {
                        HStack {
                            Text(config.sureButtonName)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 10)
                        }.frame(maxWidth: config.showSureButton ? .infinity : 0)
                            .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal,10)
                    }.opacity(config.showSureButton ? 1 : 0)
                        .frame(maxWidth: config.showSureButton ? .infinity : 0)
                }.frame(minWidth: 0,maxWidth: .infinity)
                    .padding(.top, 20)
            }
            .padding(.top, 5)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(width: 300, height: 220)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color("MainShadowColor").opacity(0.3), radius: 20, x: 0, y: 10)
    }

    func closeShow() {
        withAnimation(.spring()) {
            showSate = false
        }
    }
}
