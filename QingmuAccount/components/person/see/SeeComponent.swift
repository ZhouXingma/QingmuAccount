//
//  SeeComponent.swift
//  QingmuAccount
//
//  外观
//  暗黑模式等视图设置
//  Created by 周荥马 on 2022/12/31.
//

import SwiftUI

struct SeeComponent : View {
    // 环境变量
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 系统当前颜色模式
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    // 全局环境
    @EnvironmentObject var globalModel:GlobalModel
    // 跟随系统
    @State private var followSystemSee:Bool = false
    
    var body: some View {
        ZStack {
            Color("ViewBackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 标题栏
                ZStack {
                    // 标题始终居中
                    Text("外观")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("FontColor"))
                    
                    // 返回按钮在左侧
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("FontColor"))
                                .padding(.leading, 20)
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 44)
                .background(Color("ViewBackgroundColor"))
                
                // 内容区域
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 跟随系统设置
                        VStack(alignment: .leading, spacing: 12) {
                            Text("主题")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("FontColor"))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                // 跟随系统开关
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("跟随系统")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color("FontColor"))
                                        Text("自动跟随系统深夜模式")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    SelfToggle(offColor: .secondary,
                                               onColor: Color("DefaultButtonBackgroud"),
                                               isOn: $followSystemSee) { newValue in
                                        if newValue {
                                            globalModel.darkModeSettings = 0
                                        } else {
                                            if (colorScheme == .dark) {
                                                globalModel.darkModeSettings = 2
                                            } else {
                                                globalModel.darkModeSettings = 1
                                            }
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color("MainBackgroundColor"))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 手动选择模式
                        if !followSystemSee {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("主题选择")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("FontColor"))
                                    .padding(.horizontal, 20)
                                
                                HStack(spacing: 12) {
                                    // 浅色模式
                                    ThemeModeButton(
                                        icon: "sun.max.fill",
                                        title: "浅色",
                                        subtitle: "明亮舒适的浅色主题",
                                        isSelected: globalModel.darkModeSettings == 1
                                    ) {
                                        globalModel.darkModeSettings = 1
                                    }
                                    
                                    // 深色模式
                                    ThemeModeButton(
                                        icon: "moon.stars.fill",
                                        title: "深色",
                                        subtitle: "护眼舒适的深色主题",
                                        isSelected: globalModel.darkModeSettings == 2
                                    ) {
                                        globalModel.darkModeSettings = 2
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .selfDragBack {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear() {
            if globalModel.darkModeSettings == 0 {
                self.followSystemSee = true
            }
        }
    }
}

// MARK: - 主题模式按钮
struct ThemeModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                
                // 标题和描述
                VStack(alignment: .center, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("FontColor"))
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color("MainBackgroundColor"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("DefaultButtonBackgroud") : Color.clear, lineWidth: 2)
            )
        }
    }
}
