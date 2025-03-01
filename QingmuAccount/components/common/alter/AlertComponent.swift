//
//  AlertComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
struct AlertComponent : View {
    @Binding public  var showSate:Bool
    @State public var config:AlertComponentConfig
    @State private var offsetY:Double = 0
    @State private var isHidenOfText = false
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                offsetY = value.translation.height
            }
            .onEnded { value in
                if (value.translation.height > 100) {
                    closeShow()
                } else {
                    offsetY = 0
                }
            }
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 30, height: 5)
                    .padding(.vertical,10)
                    .foregroundColor(config.topBarColorStyle == .DEFAULT ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                VStack {
                    VStack {
                        Text(config.title)
                            .font(.system(size: 18, weight: .bold))
                        Text(config.desc)
                            .font(.system(size: 16))
                            .padding(.vertical, 10)
                    }
                    Spacer()
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
                    
                }.padding(.top, 5)
                    .padding(.horizontal,20)
                    .padding(.bottom,30)
                
            }.frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 200, maxHeight: 250)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color("MainShadowColor").opacity(0.3), radius:20,x: 1,y:-10)
            .offset(y: computerOffSetY())
            .gesture(drag)
            .animation(.spring(), value: showSate)
        
        }.ignoresSafeArea()
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)
    }
    
    func computerOffSetY() -> Double{
        if (!showSate) {
            return 300.0
        }
        return offsetY > 0 ? offsetY : 0
    }
    
    func closeShow() {
        withAnimation(.spring()) {
            showSate = false
            offsetY = 0
        }
    }
}
