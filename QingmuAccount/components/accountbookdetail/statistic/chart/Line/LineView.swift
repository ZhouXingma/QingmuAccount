//
//  LineView.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/22.
//

import SwiftUI

public struct LineView: View {
    @ObservedObject var data: ChartData
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var lineBackgroundColor: Color
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    public var legendSpecifier: String
    public var showLineBackgroup: Bool = true
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity:Double = 0
    @State private var currentDataNumber:(String,Double) = ("",0.0)
    @State private var hideHorizontalLines: Bool = true
    @State private var showIndicator: Bool = false
    
    public init(data: ChartData,
                title: String? = nil,
                legend: String? = nil,
                lineBackgroundColor:Color,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f",
                legendSpecifier: String? = "%.2f") {
        
        self.data = data
        self.title = title
        self.legend = legend
        self.lineBackgroundColor = lineBackgroundColor
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.legendSpecifier = legendSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : style
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                if (self.title != nil || self.legend != nil){
                    Group{
                        if (self.title != nil){
                            Text(self.title!)
                                .font(.title)
                                .bold().foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        }
                        if (self.legend != nil){
                            Text(self.legend!)
                                .font(.callout)
                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                        }
                    }.offset(x: 0, y: 20)
                }
                ZStack{
                    GeometryReader{ reader in
                        Rectangle()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                        if(self.showLegend){
                            Legend(data: self.data,
                                   frame: .constant(reader.frame(in: .local)), hideHorizontalLines: self.$hideHorizontalLines, specifier: legendSpecifier)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 0.2))
                        }
                        Line(data: self.data,
                             frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - 30, height: reader.frame(in: .local).height + 25)),
                             touchLocation: self.$indicatorLocation,
                             showIndicator: self.$showIndicator,
                             minDataValue: .constant(nil),
                             maxDataValue: .constant(nil),
                             showBackground: self.showLineBackgroup,
                             lineBackgroundColor: lineBackgroundColor,
                             gradient: self.style.gradientColor
                        )
                        .offset(x: 30, y: 0)
                        .onAppear(){
                            self.showLegend = true
                        }
                        .onDisappear(){
                            self.showLegend = false
                        }
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: geometry.frame(in: .local).size.height)
                    .offset(x: 0, y: 40 )
                    MagnifierLine(indicatorLocation:$indicatorLocation,currentNumber: self.$currentDataNumber, valueSpecifier: self.valueSpecifier)
                        .opacity(self.opacity)
                        .offset(x: min((self.indicatorLocation.x - geometry.frame(in: .local).size.width/2 + 30), geometry.frame(in: .local).size.width/2), y: 36)
                }
                .frame(width: geometry.frame(in: .local).size.width, height: geometry.frame(in: .local).size.height)
                .gesture(DragGesture()
                    .onChanged({ value in
                        self.showIndicator = true
                        self.dragLocation = value.location
                        self.indicatorLocation = CGPoint(x: max(value.location.x-30,0), y: 32)
                        self.opacity = 1
                        self.closestPoint = self.getClosestDataPoint(toPoint: self.indicatorLocation, width: geometry.frame(in: .local).size.width-30, height: geometry.frame(in: .local).size.height)
                        self.hideHorizontalLines = true
                    })
                    .onEnded({ value in
                        self.opacity = 0
                        self.hideHorizontalLines = true
                        self.showIndicator = false
                    })
                )
            }
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        let halfStepWidth = stepWidth/2
        let index:Int = Int(floor((toPoint.x+1+halfStepWidth)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataNumber = self.data.points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct LineView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            LineView(data: ChartData(values: [("1",8.0),("2",23.0),("3",54.0),("4",32.0),("5",12.0),("6",37.0),("7",7.0),("8",23.0),("9",43.0)]), lineBackgroundColor: Colors.OrangeStart,style: Styles.lineChartStyleOne)
            
//            LineView(data: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188], title: "Full chart", style: Styles.lineChartStyleOne)
            
        }.frame(width: 400, height: 200)
            .background(.secondary)
    }
}
