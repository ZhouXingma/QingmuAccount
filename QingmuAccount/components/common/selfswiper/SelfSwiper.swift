//
//  SelfSwiper.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/28.
//

import SwiftUI

struct SelfSwiperStyle<T>: ViewModifier where T:View{
    @State var id:String
    @State var maxOffsetX:Double
    @ObservedObject var notification:SelfSwiperNotification
    var actions: T
    @State private var offsetX:Double = 0
  
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: SelfSwiperNotification.notificationName), object: id, userInfo: nil)
                if (value.translation.width > 0) {
                    offsetX = 0
                } else {
                    offsetX = value.translation.width < -20 ? -maxOffsetX : 0
                }
            }
            .onEnded { value in
                if (value.translation.width >= -50) {
                    offsetX = 0
                } else {
                    offsetX = -maxOffsetX
                }
            }
    }

    func body(content: Content) -> some View {
        ZStack {
            HStack(spacing:2) {
                Spacer()
                actions
            }.padding(1).offset(x:-offsetX)
            content
        }.offset(x:offsetX)
            .simultaneousGesture(drag)
            .onChange(of: notification.handleId, perform: { newValue in
                if (nil == newValue || newValue != id) {
                    offsetX = 0
                }
            })
//            .onTapGesture {
//                var notificationId:String? = id
//                if (notification.handleId == id) {
//                    notificationId = nil
//                }
//                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: SelfSwiperNotification.notificationName), object: notificationId, userInfo: nil)
//            }
            .animation(.easeInOut(duration: 0.1), value: offsetX)
    }
}
extension View {
    func selfSwiper<T>(id:String, maxOffsetX:Double,notification:SelfSwiperNotification,@ViewBuilder actions: () -> T) -> some View where T:View {
        modifier(SelfSwiperStyle(id:id, maxOffsetX: maxOffsetX, notification:notification, actions: actions()))
    }
}
