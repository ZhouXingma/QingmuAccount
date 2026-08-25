//
//  Calendar.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/24.
//

import SwiftUI

struct CalendarComponent : View {

    private let caldendarWeekTitle = ["日","一","二","三","四","五","六"]
    private let caldendarWeekTitle_En_Simple = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 0), count: 7)
    
    var monthDataHandle:(CalendarShowData)->Void = {_ in }
    var selectDateChange:(Date)->Void = {_ in }
    @AppStorage("calendarType") private var calendarType:Int = 1
    @Binding var year:Int
    @Binding var month:Int
    @Binding var selectDate:Date
    // 最后加载时间
    @Binding var latestLoadTime:Date
    @State private var calendarShowData:CalendarShowData = CalendarShowData()
    @State private var dragIng:Bool = false
    @State private var totalHeight:CGFloat = 260
    
    /// 拖拽的偏移量
    @State var dragOffset: CGFloat = .zero
    /// 当前显示的位置索引,
    /// 这是实际数据中的1就是数据没有被处理之前的0位置的图片
    /// 所以这里默认从1开始
    @State var currentIndex: Int = 1
    /// 是否需要动画
    @State var isAnimation: Bool = true
    
    
    var body: some View {
        VStack {
            HStack {
                Text("\(String(year))年\(month)月").font(.system(size: 15,weight: .bold))
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            calendarType = calendarType == 0 ? 1 : 0
                        }
                    }
            }.padding(10)
            HStack() {
                LazyVGrid(columns: columns) {
                    ForEach(caldendarWeekTitle, id:\.self) { weekTitle in
                        createCalendarWeekTitleItem(week: weekTitle)
                    }
                }
            }
            GeometryReader { geometry in
                let width = geometry.frame(in: .local).width
                let currentOffset = CGFloat(currentIndex) * width
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        if (dragIng) {
                            CalendarBody(calendarShowDateItems: $calendarShowData.pre, selectDate: $selectDate, calendarType: $calendarType)
                        }
                    }.frame(width: width)
                        .opacity(dragIng ? 1 : 0)
                    VStack(spacing: 0) {
                        CalendarBody(calendarShowDateItems: $calendarShowData.show, selectDate: $selectDate, calendarType: $calendarType)
                    }.frame(width: width)
                        .background(GeometryReader {gp -> Color in
                               DispatchQueue.main.async {
                                   // update on next cycle with calculated height of ZStack !!!
                                   self.totalHeight = gp.size.height
                               }
                               return Color.clear
                        })
                    VStack(spacing: 0) {
                        if (dragIng) {
                            CalendarBody(calendarShowDateItems: $calendarShowData.next, selectDate: $selectDate, calendarType: $calendarType)
                        }
                    }.frame(width: width)
                        .opacity(dragIng ? 1 : 0)
                }.frame(width: 3 * width).offset(x: -currentOffset)
                    .offset(x:self.dragOffset)
                    .animation(isAnimation ? .spring():.none)
                    .background(.white.opacity(0.01))
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged({ dragValue in
                                self.isAnimation = true
                                self.dragIng = true
                                self.dragOffset = dragValue.translation.width
                            })
                            .onEnded({ dragValue in
                                // 速率
                                let velocity = CGSize(
                                        width:  dragValue.predictedEndLocation.x - dragValue.location.x,
                                        height: dragValue.predictedEndLocation.y - dragValue.location.y
                                )
                                // 阀值
                                let threshold = width * 0.2
                                // 是否超过阀值
                                let newIndex = Int(-dragValue.translation.width / threshold)
                                // 0 当前也，-1 前一页， 1 下一页
                                var handlePage = 0
                                if (newIndex > 1) {
                                    handlePage = 1
                                } else if(newIndex < -1) {
                                    handlePage = -1
                                } else if (velocity.width > 200) {
                                    handlePage = -1
                                } else if (velocity.width < -200) {
                                    handlePage = 1
                                }
                                // 处理页码
                                if (handlePage == 1) {
                                    currentIndex += 1
                                    
                                } else if (handlePage == -1) {
                                    currentIndex -= 1
                                   
                                }
                                self.dragOffset = 0
                                self.dragIng = false
                            })
                    ).onChange(of: currentIndex) { value in
                        isAnimation = true
                        /// 第一张的时候
                        if value == 0 {
                            isAnimation.toggle()
                            pre()
                            currentIndex = 1
                        /// 最后一张的时候currentIndex设置为1关闭动画
                        }else if value == 2 {
                            isAnimation.toggle()
                            next()
                            currentIndex = 1
                        }
                    }
            }.frame(minWidth: 0,maxWidth: .infinity, alignment: .leading)
                .frame(height: totalHeight)
                
        }
        .onChange(of: latestLoadTime, perform: { newValue in
            self.calendarShowData = createCalendarShowData(year: year, month: month)
            monthDataHandle(self.calendarShowData)
        })
        .onAppear() {
            self.calendarShowData = createCalendarShowData(year: year, month: month)
            monthDataHandle(self.calendarShowData)
        }
       
    }
    
    func pre() {
        calendarShowData.next = calendarShowData.show
        calendarShowData.show = calendarShowData.pre
        var year = calendarShowData.show.year
        var month = calendarShowData.show.month-1
        if (month < 1) {
            month = 12
            year = year - 1
        }
        calendarShowData.pre = CalendarShowDateItems(
            year: year,
            month: month,
            datas: createCalendarDateModelsaOfMonth (
                year: year,
                month: month
            )
        )
        self.year = calendarShowData.show.year
        self.month = calendarShowData.show.month
        monthDataHandle(self.calendarShowData)
    }
    
    func next() {
        calendarShowData.pre = calendarShowData.show
        calendarShowData.show = calendarShowData.next
        var year = calendarShowData.show.year
        var month = calendarShowData.show.month+1
        if (month > 12) {
            month = 1
            year = year + 1
        }
        calendarShowData.next = CalendarShowDateItems(
            year: year,
            month: month,
            datas: createCalendarDateModelsaOfMonth (
                year: year,
                month: month
            )
        )
        self.year = calendarShowData.show.year
        self.month = calendarShowData.show.month
        monthDataHandle(self.calendarShowData)
    }
    
    /**
     头部的星期
     */
    func createCalendarWeekTitleItem(week: String) -> some View {
        VStack(alignment: .center) {
            Text(week)
                .foregroundColor(.secondary)
                .font(.system(size: 16,weight: .bold))
                
        }.frame(minWidth: 0, maxWidth: .infinity)
    }
    
}

struct CalendarBody : View  {
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 0), count: 7)
    @Binding var calendarShowDateItems:CalendarShowDateItems
    @Binding var selectDate:Date
    @Binding var calendarType:Int
    var body: some View {
        LazyVGrid(columns: columns,spacing: 0) {
            ForEach(calendarShowDateItems.datas.indices, id:\.self) { itemIndex in
                createCalendarDayItem(
                   year: calendarShowDateItems.year,
                   month: calendarShowDateItems.month,
                   calendarDateModel: calendarShowDateItems.datas[itemIndex])
                
            }
        }
    }
    
    /**
     日历日期
     */
    func createCalendarDayItem(year:Int, month:Int, calendarDateModel:CalendarDateModel) -> some View {
        VStack {
            Text("\(calendarDateModel.dayValue)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(calendarDateModel.isToday ? .white : Color("FontColor").opacity(1))
            Text(calendarDateModel.desc)
                .font(.system(size: calendarType == 0 ? 0.01 : 10))
                .foregroundColor(calendarDateModel.isToday ? .white : Color("FontColor").opacity(0.5))
        }.frame(
            width: calendarType == 0 ? 40.0 : 50.0,
            height: calendarType == 0 ? 40.0 : 50.0
        ).background(
            Color("DefaultButtonBackgroud").opacity(calendarDateModel.isToday ? 1 : 0),
            in:RoundedRectangle(cornerRadius: calendarType == 0 ? 40 : 5)
        )
        .padding(1)
        .onTapGesture {
            if (selectDate == calendarDateModel.day) {
                self.selectDate = Date()
            } else {
                self.selectDate = calendarDateModel.day
            }
        }
        .overlay {
            Circle().fill(Color("RedColor")).frame(width: 4,height: 4)
                .offset(y: 12)
                .opacity(calendarType == 0 && calendarDateModel.mark ? 1 : 0)
        }.overlay {
            RoundedRectangle(cornerRadius: calendarType == 0 ? 40 : 5)
                .stroke(style: .init(lineWidth: 2))
                .frame(
                    width: calendarType == 0 ? 38 : 48,
                    height: calendarType == 0 ? 38 : 48
                )
                .foregroundColor(Color("DefaultButtonBackgroud"))
                .opacity(calendarDateModel.isSelectedDay(selectDate) ? 1 : 0)
            
        }.opacity(calendarDateModel.isCurrentMonth ? 1 : 0)
    }
}



struct CalendarComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        CalendarComponent(year: .constant(2022), month: .constant(12), selectDate: .constant(Date()),latestLoadTime: .constant(Date())).previewDevice("iPhone 12 mini").preferredColorScheme(.light)
    }
}


