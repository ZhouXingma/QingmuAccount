//
//  SeeComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/31.
//

import SwiftUI

struct SeeComponent : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 系统当前颜色模式
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    // 全局环境
    @EnvironmentObject var globalModel:GlobalModel
    // 跟随系统
    @State private var followSystemSee:Bool = false
    
    var body: some View {
        VStack {
            DefaultTopBarComponent {
                presentationMode.wrappedValue.dismiss()
            }
            VStack {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("跟随系统").font(.system(size: 16,weight: .bold))
                                Spacer()
                            }.padding(.vertical,5)
                            HStack {
                                Text("开启后，将跟随系统打开或关闭深夜模式").font(.system(size: 10,weight: .bold))
                                Spacer()
                            }
                        }
                        Spacer()
                        SelfToggle(offColor: .secondary,
                                   onColor:Color("DefaultButtonBackgroud"),
                                   isOn: $followSystemSee) {newValue in
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
                }.padding(10)
                    .frame(height: 70)
                    .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
                    .padding(15)
                if !self.followSystemSee {
                    VStack {
                        HStack {
                            Text("手动选择").font(.system(size: 12,weight: .bold)).foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack {
                            Text("浅色").font(.system(size: 16,weight: .bold))
                            Spacer()
                            Image(systemName: "checkmark").font(.system(size: 14,weight: .bold))
                                .foregroundColor(self.globalModel.darkModeSettings == 1 ? Color("DefaultButtonBackgroud") : Color.clear)
                        }.padding(10).frame(height: 50)
                            .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                globalModel.darkModeSettings = 1
                            }
                        HStack {
                            Text("深色").font(.system(size: 16,weight: .bold))
                            Spacer()
                            Image(systemName: "checkmark").font(.system(size: 14,weight: .bold))
                                .foregroundColor(self.globalModel.darkModeSettings == 2 ? Color("DefaultButtonBackgroud") : Color.clear)
                        }.padding(10).frame(height: 50)
                            .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                globalModel.darkModeSettings = 2
                            }
                    }.padding(.horizontal,15)
                }
                
            }.onAppear() {
                
            }
            Spacer()
        }.background(Color("ViewBackgroundColor"))
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .selfDragBack {
                presentationMode.wrappedValue.dismiss()
            }.onAppear() {
                if globalModel.darkModeSettings == 0 {
                    self.followSystemSee = true
                }
            }
    }
}
