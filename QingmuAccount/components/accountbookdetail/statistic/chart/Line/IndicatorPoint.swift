//
//  IndicatorPoint.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/21.
//
import SwiftUI

struct IndicatorPoint: View {
    var body: some View {
        ZStack{
            Circle()
                .fill(Color("DefaultButtonBackgroud"))
            Circle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2))
        }
        .frame(width: 12, height: 12)
    }
}

struct IndicatorPoint_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorPoint()
    }
}
