//
//  Pie.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/24.
//

import SwiftUI

struct Pie : View {
    var peiDataList:[PieData]
    var radius:Double
    var pieWidth:Double
    @State private var colors:[Color] = [Color(hex:"#fc8251"), Color(hex:"#5470c6"), Color(hex:"#91cd77"),  Color(hex:"#ef6567"), Color(hex:"#f9c956"), Color(hex:"#75bedc")]
    @State private var selectIndex:Int = -1
    private var totalValue:Double
    var specifier: String = "%.2f"
    
    init(peiDataList: [PieData], radius:Double = 80, pieWidth:Double = 20) {
        self.peiDataList = peiDataList
        self.radius = radius
        self.pieWidth = pieWidth
        self.totalValue = 0
        for item in peiDataList {
            totalValue += item.itemValue
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(peiDataList.indices, id:\.self) { index in
                    PiePath(frame:proxy.frame(in: .local),index: index, radius: radius, angle: computerPercent(index: index), startAngle: computerStartAngle(index: index), color: computerColoer(index: index), selectIndex: $selectIndex)
                        .onTapGesture {
                            if (selectIndex == index) {
                                selectIndex = -1
                            } else {
                                selectIndex = index
                            }
                        }
                }
                PiePath(frame:proxy.frame(in: .local),index: 99999, radius: radius-pieWidth, angle: 360, startAngle: 0, color: Color("MainBackgroundColor"), selectIndex: $selectIndex)
                
                VStack {
                    Text("\(getItemName())").font(.system(size: 14))
                        .padding(.bottom,1)
                    Text("\(getItemValue(),specifier:specifier)")
                        .font(.system(size: 14,weight: .bold))
                }
            }
        }
        
    }
    
    func computerPercent(index:Int) -> Double {
        let a = peiDataList[index].itemValue / totalValue * 360
        return a
    }
    
    func computerStartAngle(index:Int) -> Double {
        var tempTotal:Double = 0
        if (index == 0) {
            return 0
        }
        for i in 0...index-1 {
            tempTotal += peiDataList[i].itemValue
        }
        let a =  tempTotal / totalValue * 360
        return a
    }
    
    func computerColoer(index:Int) -> Color {
        let ci = index % colors.count
        return colors[ci]
    }
    
    func getItemName() -> String {
        if (selectIndex == -1) {
            return "总计"
        }
        return peiDataList[selectIndex].itemName
    }
    
    func getItemValue() -> Double{
        if (selectIndex == -1) {
            return totalValue
        }
        return peiDataList[selectIndex].itemValue
    }
    
}


