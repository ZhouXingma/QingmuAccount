//
//  MagnifierLine.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/22.
//

import SwiftUI

public struct MagnifierLine: View {
    @Binding var indicatorLocation:CGPoint
    @Binding var currentNumber: (String,Double)
    var valueSpecifier:String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    public var body: some View {
        GeometryReader{ geometry in
            VStack{
                
                Text("\(self.currentNumber.1, specifier: valueSpecifier)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                VStack {
                    createPath(height: geometry.frame(in: .local).height).stroke(style: .init(lineWidth: 1.5))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .offset(x: 0, y:0)
                }.frame(width: 1)
                    .frame(minHeight: 0, maxHeight: .infinity)
                Text(self.currentNumber.0)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                    .offset(x: 0, y: 60)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .offset(x: 0, y: -30)
        }
    }
    func createPath(height:Double) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 1, y: 0))
        path.addLine(to: CGPoint(x: 1, y: height))
        return path
    }
}
