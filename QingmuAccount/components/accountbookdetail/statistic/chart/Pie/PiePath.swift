//
//  PiePathView.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/24.
//

import SwiftUI
struct PiePath : View {
    var frame:CGRect
    var index:Int
    var radius:Double
    var angle:Double
    var startAngle:Double
    var color:Color
    @Binding var selectIndex:Int
    
    var body: some View {
        Path { path in
            let endAngle = startAngle + angle
            path.move(to: CGPoint(x:frame.width/2, y: frame.height/2))
            path.addArc(center:  CGPoint(x: frame.width/2, y: frame.height/2), radius: radius+(index == selectIndex ? 5 : 0), startAngle:  Angle(degrees: startAngle), endAngle: Angle(degrees: endAngle), clockwise: false)
        }.fill(color)
            .animation(.easeInOut, value: selectIndex)
    }
}
