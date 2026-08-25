//
//  MultiScrollChartLine.swift
//  QingmuAccount
//  多线可滚动折线图（参考组件）：平滑 Catmull-Rom 曲线、渐变填充、长按拖动查看各线数值。
//  Created by 周荥马 on 2026/8/15.
//

import SwiftUI

// MARK: - 线条数据模型
public struct MultiScrollChartDataPoint: Identifiable, Equatable {
    public let id = UUID()
    public let label: String
    public let values: [Double?]

    // 实现 Equatable 协议
    public static func == (lhs: MultiScrollChartDataPoint, rhs: MultiScrollChartDataPoint) -> Bool {
        lhs.label == rhs.label && lhs.values == rhs.values
    }
}
// MARK: - 线条样式配置
public struct MultiScrollChartLineStyle: Equatable {
    var name: String = "Line"
    var lineColor: [Color] = [.red, .purple]
    var lineWidth: CGFloat = 3
    var gradientColors: [Color] = [.red.opacity(0.3), .red.opacity(0.05)]
    var pointColor: Color = .red
    var pointBackgroundColor: Color = .white
    var showPointCircle: Bool = false
    var showAverageLine: Bool = true
    var averageLineWidth: CGFloat = 2

    // 实现 Equatable 协议
    public static func == (lhs: MultiScrollChartLineStyle, rhs: MultiScrollChartLineStyle) -> Bool {
        lhs.name == rhs.name &&
        lhs.lineColor == rhs.lineColor &&
        lhs.lineWidth == rhs.lineWidth &&
        lhs.gradientColors == rhs.gradientColors &&
        lhs.pointColor == rhs.pointColor &&
        lhs.pointBackgroundColor == rhs.pointBackgroundColor &&
        lhs.showPointCircle == rhs.showPointCircle &&
        lhs.showAverageLine == rhs.showAverageLine &&
        lhs.averageLineWidth == rhs.averageLineWidth
    }

    public init(
        name: String = "Line",
        lineColor: [Color] = [.red, .purple],
        lineWidth: CGFloat = 3,
        gradientColors: [Color] = [.red.opacity(0.3), .red.opacity(0.05)],
        pointColor: Color = .red,
        pointBackgroundColor: Color = .white,
        showPointCircle: Bool = false,
        showAverageLine: Bool = true,
        averageLineWidth: CGFloat = 2
    ) {
        self.name = name
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
        self.pointColor = pointColor
        self.pointBackgroundColor = pointBackgroundColor
        self.showPointCircle = showPointCircle
        self.showAverageLine = showAverageLine
        self.averageLineWidth = averageLineWidth
    }
}

// MARK: - 图表样式配置
public struct MultiScrollChartStyle {
    var animationDuration: Double = 1.5
    var showXAxis = true
    var showYAxis = true
    var showGradient = true
    var xAxisMinSpace: Double = 50
    var xAxisHeight: CGFloat = 20
    var yAxisSep:Int = 5
    var smoothness:CGFloat =  0.5
    var showYLines = false
    var minValue: Double? = nil
    var maxValue: Double? = nil

    public init(
        animationDuration: Double = 1.5,
        showXAxis: Bool = true,
        showYAxis: Bool = true,
        showGradient: Bool = true,
        xAxisMinSpace: Double = 50,
        xAxisHeight: CGFloat = 20,
        yAxisSep: Int = 5,
        smoothness: CGFloat = 0.5,
        showYLines: Bool = false,
        minValue: Double? = nil,
        maxValue: Double? = nil
    ) {
        self.animationDuration = animationDuration
        self.showXAxis = showXAxis
        self.showYAxis = showYAxis
        self.showGradient = showGradient
        self.xAxisMinSpace = xAxisMinSpace
        self.xAxisHeight = xAxisHeight
        self.yAxisSep = yAxisSep
        self.smoothness = smoothness
        self.showYLines = showYLines
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

// MARK: - 线条数据
public struct MultiScrollChartLineData: Equatable {
    var points:[MultiScrollChartDataPoint]
    var lineStyle:[MultiScrollChartLineStyle]

    // 实现 Equatable 协议
    public static func == (lhs: MultiScrollChartLineData, rhs: MultiScrollChartLineData) -> Bool {
        lhs.points == rhs.points && lhs.lineStyle == rhs.lineStyle
    }
}

// MARK: - ChartLine View
public struct MultiScrollChartLine: View {
    var data: MultiScrollChartLineData
    var style: MultiScrollChartStyle
    var chartHeight: CGFloat = 300
    @State private var locations: [CGPoint] = []
    @State private var selected: MultiScrollChartDataPoint? = nil
    @State private var animationProgress: CGFloat = 0
    @State private var scollSize:CGSize = .zero

    public init(data:MultiScrollChartLineData, style: MultiScrollChartStyle = MultiScrollChartStyle(), chartHeight: CGFloat = 300) {
        self.data = data
        self.style = style
        self.chartHeight = chartHeight
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                let rect = geometry.frame(in: .local)
                chartContent(rect: rect)
            }
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: data) {
            startAnimation()
        }
        .frame(height: chartHeight)
    }

    // 启动动画
    private func startAnimation() {
        // 重置动画进度
        animationProgress = 0
        // 立即开始动画
        withAnimation(.easeInOut(duration: style.animationDuration)) {
            animationProgress = 1
        }
    }
}

// MARK: - 辅助视图
private extension MultiScrollChartLine {
    // MARK: - 图表内容
   @ViewBuilder
    private func chartContent(rect: CGRect) -> some View {
       ZStack(alignment: .topLeading) {
           if style.showYAxis {
               yAxisGrid()
                   .frame(height: style.showXAxis ? rect.height - style.xAxisHeight : rect.height)
                   .offset(y: -6)
           }
           ScrollView(.horizontal, showsIndicators: false) {
               ZStack {
                   GeometryReader { proxy in
                       Color.clear
                           .onAppear {
                               self.scollSize = proxy.size
                           }
                           .onChange(of: proxy.size) { _, new in
                               self.scollSize = new
                           }
                   }
                   .frame(maxWidth: .infinity)
                   .frame(height: style.showXAxis ? rect.height - style.xAxisHeight : rect.height)
                   VStack {
                       ZStack(alignment: .topLeading) {
                           Color.white.opacity(0.001).frame(width: self.scollSize.width, height: self.scollSize.height)
                           if style.showGradient {
                               gradientFill()
                           }

                           linePath()

                           averageLine()

                            pointCircle()

                          if let _ = selected {
                              interactionPoint()
                          }
                       }
                       .frame(width: self.scollSize.width, height: self.scollSize.height)
                       .gesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .onEnded{value in
                                }
                                .sequenced(before:
                                    DragGesture(minimumDistance: 0)
                                       .onChanged({ value in
                                          updateSelection(at: value.location, width: scollSize.width, height: scollSize.height)
                                       })
                                        .onEnded({ value in
                                           self.selected = nil
                                       })
                                  )
                       )
                       xAxisLabels()
                   }
                   if let s = selected, let firstLocation = locations.first {
                       VStack(alignment: .center, spacing: 3) {
                           // 显示x轴标签
                           Text(s.label)
                               .font(.system(size: 12, weight: .bold))
                               .foregroundColor(.primary)

                           // 显示各线条的数据
                           ForEach(Array(data.lineStyle.enumerated()), id: \.offset) { lineIndex, lineStyle in
                               if s.values.indices.contains(lineIndex), let value = s.values[lineIndex] {
                                   Text("\(lineStyle.name):\(formatDoubleWithoutTrailingZeros(value))")
                                       .font(.system(size: 11, weight: .medium))
                                       .foregroundColor(lineStyle.lineColor.first ?? lineStyle.pointColor)
                                       .padding(.horizontal, 4)
                               }
                           }
                       }
                       .padding(6)
                       .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("MainBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                       )
                       .zIndex(100) // 确保提示框显示在最上层
                       .position(x: min(max(firstLocation.x, 70), max(scollSize.width - 70, 70)), y: calculateTooltipYPosition(rect: rect, y: firstLocation.y))
                   }
               }.frame(minWidth: rect.size.width)
           }
           .frame(minWidth: rect.size.width)

       }
   }

    // MARK: - Y轴网格
    @ViewBuilder
    private func yAxisGrid() -> some View {
        let (maxValue, minValue, avgValue) = computerMaxMinAvgValue()
        VStack(spacing: 0) {
            ForEach(0..<style.yAxisSep, id: \.self) { i in
                HStack {
                    Text("\(getYValue(minValue: minValue, maxValue: maxValue, avgValue: avgValue, index: i))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                        .frame(alignment: .trailing)
                    if style.showYLines {
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .frame(height: 1)
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - X轴标签
    @ViewBuilder
    private func xAxisLabels() -> some View {
        HStack(spacing: 0) {
            ForEach(data.points) { point in
                Text(point.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .frame(minWidth: style.xAxisMinSpace)
            }
        }.frame(height: style.showXAxis ? style.xAxisHeight : 0).opacity(style.showXAxis ? 1 : 0)
    }
    // MARK: - 阴影区域
    @ViewBuilder
    private func gradientFill()  -> some View {
        ForEach(0..<data.lineStyle.count, id:\.self) { lineIndex in
            let lineStyle = data.lineStyle[lineIndex]
            let path = createSmoothPath(width:scollSize.width, height: scollSize.height, smoothness: style.smoothness, closed:true, lineIndex: lineIndex)
            path.fill(
                LinearGradient(
                    colors: lineStyle.gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            ).mask(
                Rectangle()
                    .frame(width: scollSize.width * animationProgress)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        }
    }
    // MARK: - 线条
    @ViewBuilder
    private func linePath() -> some View {
        ForEach(0..<data.lineStyle.count, id: \.self) { lineIndex in
            let path = createSmoothPath(width:scollSize.width, height:scollSize.height, smoothness: style.smoothness, closed:false, lineIndex: lineIndex)
            let lineStyle = data.lineStyle[lineIndex]
            path.trim(from: 0, to: animationProgress)
                .stroke(LinearGradient(colors: lineStyle.lineColor, startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: lineStyle.lineWidth, lineCap: .round, lineJoin: .round))
        }
    }

    // MARK: - 平均值横线
    @ViewBuilder
    private func averageLine() -> some View {
        ForEach(Array(0..<data.lineStyle.count), id: \.self) { lineIndex in
            let lineStyle = data.lineStyle[lineIndex]

            // 只在启用平均线时显示
            if lineStyle.showAverageLine {
                let (maxValue, minValue, _) = computerMaxMinAvgValue()

                // 收集当前线条的所有有效数值（忽略nil）
                let validValues = data.points.compactMap { $0.values.indices.contains(lineIndex) ? $0.values[lineIndex] : nil }

                // 只在有有效数值时显示平均线
                if !validValues.isEmpty {
                    // 计算平均值
                    let avgValue = validValues.reduce(0, +) / Double(validValues.count)

                    let range = maxValue - minValue
                    let normalized = range > 0 ? (CGFloat(avgValue) - minValue) / range : 0.5
                    let yPosition = scollSize.height - (normalized * scollSize.height)

                    ZStack(alignment: .topLeading) {
                        // 平均线数值标签
                        Text("\(String(format: "%.2f", avgValue))")
                            .offset(y: yPosition - 15)
                            .font(.system(size: 12))
                            .foregroundStyle(LinearGradient(colors: lineStyle.lineColor, startPoint: .leading, endPoint: .trailing))

                        // 平均线
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: lineStyle.averageLineWidth, dash: [5, 5]))
                            .foregroundStyle(LinearGradient(colors: lineStyle.lineColor, startPoint: .leading, endPoint: .trailing))
                            .frame(height: lineStyle.averageLineWidth)
                            .offset(y: yPosition)
                    }
                    .opacity(animationProgress)
                }
            }
        }
    }

    // MARK: - Line Shape
    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return path
        }
    }
    // MARK: - 交互点
    @ViewBuilder
    private func interactionPoint() -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(maxHeight: .infinity)
                .frame(width: 2)
                .offset(x: locations.first?.x ?? 0)

            // 为每条线显示交互点（安全遍历：直接取元素，索引越界时跳过）
            ForEach(Array(data.lineStyle.enumerated()), id: \.offset) { lineIndex, lineStyle in
                if locations.indices.contains(lineIndex) {
                    let pointLocation = locations[lineIndex]
                    let pointColor = lineStyle.lineColor.first ?? lineStyle.pointColor
                    Circle()
                        .fill(lineStyle.pointBackgroundColor)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .fill(pointColor)
                                .frame(width: 10, height: 10)
                        )
                        .position(pointLocation)
                        .shadow(color: pointColor.opacity(0.3), radius: 4)
                }
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder
    private func pointCircle() -> some View {
        ZStack(alignment: .topLeading) {
            let (maxValue, minValue, _) = computerMaxMinAvgValue()
            let range = maxValue - minValue

            ForEach(0..<data.lineStyle.count, id: \.self) { lineIndex in
                let lineStyle = data.lineStyle[lineIndex]
                // 只有当showPointCircle为true时才显示点
                if lineStyle.showPointCircle || data.points.count <= 1 {
                    let wSpace = max(scollSize.width / CGFloat(max(data.points.count, 1)), style.xAxisMinSpace)
                    let points = data.points.enumerated().map { index, item -> CGPoint in
                        let x = (CGFloat(index) * wSpace) + (wSpace / 2)
                        let value = item.values.indices.contains(lineIndex) ? (item.values[lineIndex] ?? 0) : 0
                        let normalized = range > 0 ? (value - minValue) / range : 0.5
                        let y = scollSize.height - (CGFloat(normalized) * scollSize.height)
                        return CGPoint(x: x, y: y)
                    }

                    ForEach(0..<points.count, id:\.self) { pointIndex in
                        Circle()
                            .fill(lineStyle.pointColor)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .fill(lineStyle.pointBackgroundColor)
                                    .frame(width: 10, height: 10)
                            )
                            .position(points[pointIndex])
                            .shadow(color: lineStyle.pointColor.opacity(0.3), radius: 4)
                    }
                }
            }
        }
    }

}
// MARK: - 辅助方法
private extension MultiScrollChartLine {
    // MARK: - 最大最小值计算
    private func computerMaxMinAvgValue() -> (CGFloat, CGFloat, CGFloat) {
        // 收集所有有效值
        var values:[Double] = []
        for i in 0..<data.points.count {
            let points = data.points[i]
            for j in 0..<points.values.count {
                if let pointValue = points.values[j] {
                    values.append(pointValue)
                }
            }
        }

        // 使用自定义范围（如果提供的话），否则计算数据范围
        var maxValue = CGFloat(values.max() ?? 100)
        var minValue = CGFloat(values.min() ?? 0)

        // 确保最大值和最小值不相等
        if maxValue == minValue {
            if maxValue > 0 {
                minValue = 0;
                maxValue = maxValue * 2.0
                if let styleMaxValue = style.maxValue {
                    maxValue = min(maxValue, styleMaxValue)
                }
            } else if maxValue <= 0 {
                minValue = maxValue * 2.0
                if let styleMinValue = style.minValue {
                    minValue = max(minValue, styleMinValue)
                }
                maxValue = 0;
            }
        }

        // 计算平均步长和调整后的范围
        let avgValue = abs((maxValue - minValue) / CGFloat(style.yAxisSep))
        let maxTemp = maxValue + avgValue / 2;
        let minTemp = minValue - avgValue / 2;
        let avgTemp = abs((maxTemp - minTemp) / CGFloat(style.yAxisSep))

        return (maxTemp, minTemp, avgTemp)
    }
    // MARK: - Y轴值显示
    private func getYValue(minValue: CGFloat, maxValue: CGFloat, avgValue: CGFloat, index: Int) -> String {
        let value = maxValue - avgValue * CGFloat(index)

        // 根据整个数据范围确定小数位数
        let decimalPlaces = getDecimalPlacesForRange(avgValue: avgValue)

        // 直接格式化，避免NumberFormatter问题
        if decimalPlaces == 0 {
            return "\(Int(value.rounded()))"
        } else {
            return String(format: "%.\(decimalPlaces)f", value)
        }
    }

    // 根据整个数据范围确定小数位数
    private func getDecimalPlacesForRange(avgValue: CGFloat) -> Int {
        if avgValue < 0.01 {
            return 3
        } else if avgValue < 0.1 {
            return 2
        } else if avgValue < 1 {
            return 1
        } else if avgValue < 10 {
            return 1
        } else {
            return 0
        }
    }
}


// MARK: - 核心算法部分
private extension MultiScrollChartLine {

    // MARK: 创建平滑路径（Catmull–Rom 样条曲线）
    func createSmoothPath(width: CGFloat, height: CGFloat, smoothness: CGFloat, closed: Bool, lineIndex:Int) -> Path {
        guard data.points.count > 1 else { return Path() }

        let (maxValue, minValue, _) = computerMaxMinAvgValue()
        let range = maxValue - minValue
        let wSpace = max(width / CGFloat(max(data.points.count, 1)), style.xAxisMinSpace)
        var startX = CGFloat(0.0);

        // 过滤出有效数据点（非nil值）
        let validPoints = data.points.enumerated()
            .compactMap { (index, item) -> (CGFloat, Double)? in
                if item.values.indices.contains(lineIndex), let value = item.values[lineIndex] {
                    return (CGFloat(index), value)
                }
                return nil
            }
            .map { (index, value) -> CGPoint in
                let x = (index * wSpace) + (wSpace / 2)
                let normalized = range > 0 ? (value - minValue) / range : 0.5
                let y = height - (CGFloat(normalized) * height)
                if index == 0 { startX = x }
                return CGPoint(x: x, y: y)
            }

        // 如果有效点不足，返回空路径
        guard validPoints.count > 1 else { return Path() }

        var path = Path()
        path.move(to: validPoints[0])

        for i in 0..<validPoints.count - 1 {
            let p0 = i > 0 ? validPoints[i - 1] : validPoints[i]
            let p1 = validPoints[i]
            let p2 = validPoints[i + 1]
            let p3 = i + 2 < validPoints.count ? validPoints[i + 2] : validPoints[i + 1]

            let t = smoothness.clamped(to: 0...1)

            var control1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6 * t,
                y: p1.y + (p2.y - p0.y) / 6 * t
            )
            var control2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6 * t,
                y: p2.y - (p3.y - p1.y) / 6 * t
            )
            // 防止过冲：控制点 y 夹在相邻数据点 y 之间，避免低于0/高于峰值的凹陷或凸起
            control1.y = control1.y.clamped(to: min(p0.y, p1.y, p2.y)...max(p0.y, p1.y, p2.y))
            control2.y = control2.y.clamped(to: min(p1.y, p2.y, p3.y)...max(p1.y, p2.y, p3.y))

            path.addCurve(to: p2, control1: control1, control2: control2)
        }

        if closed, let lastPoint = validPoints.last {
            path.addLine(to: CGPoint(x: lastPoint.x, y: height))
            path.addLine(to: CGPoint(x: startX, y: height))
            path.closeSubpath()
        }

        return path
    }

    // MARK: 根据 X 获取曲线对应 Y 值（精确对齐）
    func yValue(atX x: CGFloat, width: CGFloat, height: CGFloat, lineIndex: Int = 0) -> CGFloat {
        guard data.points.count > 1 else { return height / 2 }

        let (maxValue, minValue, _) = computerMaxMinAvgValue()
        let range = maxValue - minValue
        let wSpace = max(width / CGFloat(max(data.points.count, 1)), style.xAxisMinSpace)

        // 过滤出有效数据点（非nil值）
        let validPoints = data.points.enumerated()
            .compactMap { (index, item) -> (CGPoint)? in
                if item.values.indices.contains(lineIndex), let value = item.values[lineIndex] {
                    let xPos = (CGFloat(index) * wSpace) + (wSpace / 2)
                    let normalized = range > 0 ? (value - minValue) / range : 0.5
                    let yPos = height - (CGFloat(normalized) * height)
                    return CGPoint(x: xPos, y: yPos)
                }
                return nil
            }

        // 如果有效点不足，返回默认值
        guard validPoints.count > 1 else { return height / 2 }

        for i in 0..<validPoints.count - 1 {
            let p0 = i > 0 ? validPoints[i - 1] : validPoints[i]
            let p1 = validPoints[i]
            let p2 = validPoints[i + 1]
            let p3 = i + 2 < validPoints.count ? validPoints[i + 2] : validPoints[i + 1]

            if x >= p1.x && x <= p2.x {
                let t = style.smoothness.clamped(to: 0...1)

                var c1 = CGPoint(
                    x: p1.x + (p2.x - p0.x) / 6 * t,
                    y: p1.y + (p2.y - p0.y) / 6 * t
                )
                var c2 = CGPoint(
                    x: p2.x - (p3.x - p1.x) / 6 * t,
                    y: p2.y - (p3.y - p1.y) / 6 * t
                )
                // 与 createSmoothPath 保持一致的防过冲夹紧
                c1.y = c1.y.clamped(to: min(p0.y, p1.y, p2.y)...max(p0.y, p1.y, p2.y))
                c2.y = c2.y.clamped(to: min(p1.y, p2.y, p3.y)...max(p1.y, p2.y, p3.y))

                let tVal = findTForX(targetX: x, p0: p1, c1: c1, c2: c2, p3: p2)
                let y = cubicBezier(tVal, p1.y, c1.y, c2.y, p2.y)
                return y
            }
        }
        return height / 2
    }

    // MARK: 选中更新
    func updateSelection(at location: CGPoint, width: CGFloat, height: CGFloat) {
        // 确保locations数组大小与线条数量一致
        var updatedLocations = [CGPoint](repeating: .zero, count: data.lineStyle.count)

        // 计算每条线的Y值
        for lineIndex in 0..<data.lineStyle.count {
            let y = yValue(atX: location.x, width: width, height: height, lineIndex: lineIndex)
            updatedLocations[lineIndex] = CGPoint(x: location.x, y: y)
        }

        self.locations = updatedLocations

        withAnimation(.easeOut(duration: 0.1)) {
            selected = closestPoint(toX: location.x, width: width)
        }
    }

    // MARK: 计算最近点
    func closestPoint(toX x: CGFloat, width: CGFloat) -> MultiScrollChartDataPoint? {
        let wSpace = max(width / CGFloat(max(data.points.count, 1)), style.xAxisMinSpace)
        let index = Int(x / wSpace)
        guard data.points.indices.contains(index) else { return nil }
        return data.points[index]
    }

    // MARK: 计算提示框Y位置
    func calculateTooltipYPosition(rect: CGRect, y: CGFloat) -> CGFloat {
        // 动态计算提示框高度
        let lineHeight: CGFloat = 14 // 每条线的高度
        let labelHeight: CGFloat = 16 // 标签高度
        let spacing: CGFloat = 2 // 线条之间的间距
        let innerPadding: CGFloat = 6 // 提示框内部上下内边距

        // 计算实际高度：标签高度 + 线条高度总和 + 间距总和 + 上下内边距
        let totalLines = CGFloat(data.lineStyle.count)
        let tooltipHeight = labelHeight + (lineHeight * totalLines) + (spacing * (totalLines - 1)) + (innerPadding * 2)
        let outerPadding: CGFloat = 20 // 外部边距，避免紧贴边界

        // 计算图表区域的有效范围，使用xAxisHeight替代写死的40
        let chartTop = outerPadding
        let chartBottom = (style.showXAxis ? rect.height - style.xAxisHeight : rect.height) - outerPadding

        // 计算提示框的理想位置 - 始终显示在上方
        var idealY = y - tooltipHeight

        // 调整位置，确保提示框完全在图表区域内
        if idealY < chartTop {
            idealY = chartTop
        } else if idealY > chartBottom {
            idealY = chartBottom
        }

        return idealY
    }


    func findTForX(targetX: CGFloat, p0: CGPoint, c1: CGPoint, c2: CGPoint, p3: CGPoint) -> CGFloat {
        var tMin: CGFloat = 0
        var tMax: CGFloat = 1
        var t: CGFloat = 0.5
        for _ in 0..<20 {
            let x = cubicBezier(t, p0.x, c1.x, c2.x, p3.x)
            if abs(x - targetX) < 0.1 { break }
            if x < targetX { tMin = t } else { tMax = t }
            t = (tMin + tMax) / 2
        }
        return t
    }

    func cubicBezier(_ t: CGFloat, _ p0: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ p3: CGFloat) -> CGFloat {
        let oneMinusT = 1 - t
        return pow(oneMinusT, 3) * p0
        + 3 * pow(oneMinusT, 2) * t * c1
        + 3 * oneMinusT * pow(t, 2) * c2
        + pow(t, 3) * p3
    }

    func formatDoubleWithoutTrailingZeros(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2 // 金额最多精确到 2 位小数，避免 Double 浮点误差
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

// MARK: - Clamp Extension
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
