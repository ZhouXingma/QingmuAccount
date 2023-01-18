//
//  YmDatePickerComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/5.
//

import SwiftUI

struct YmDatePickerComponent : View {
    @Binding var showState:Bool
    @Binding var param:DatePickerValue
    @State var pickerSure:(DatePickerValue)->Void
    @State var year:Int = 2022
    @State var month:Int = 1
    @State private var offsetY:Double = 0

    var body: some View {
        VStack {
            Spacer()
            VStack {
                HStack {
                    Button {
                        closeShow()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("DefaultButtonBackgroud"))
                    }
                    Spacer()
                    Button {
                        let value:DatePickerValue = DatePickerValue(year: year, month: month)
                        pickerSure(value)
                        closeShow()
                    } label: {
                        Text("确认")
                            .foregroundColor(.white)
                            .padding(.horizontal,20).padding(.vertical,5).background(Color("DefaultButtonBackgroud"),in: RoundedRectangle(cornerRadius: 5))
                    }
                }.frame(height: 30)
                    .padding(.horizontal,20)
                    .padding(.vertical,10)
                   
                YmDatePickerRepresentable(year: $year, month: $month)
            }.background(Color("MainBackgroundColor"))
            .shadow(color: Color("MainShadowColor").opacity(0.3), radius:20,x: 1,y:-10)
            .frame(height: 300)
            .offset(y: computerOffSetY())
            .animation(.easeInOut,value: computerOffSetY())
            
        }
        .onAppear() {
            resetYmd()
        }
        .onChange(of: showState) { newValue in
            resetYmd()
        }
    }
    
    func closeShow() {
        showState = false
    }
    
    func resetYmd() {
        let components = DateUtils.findComponentsOfDate([.year,.month], date: Date())
        self.year = param.year ?? components.year!
        self.month = param.month ?? components.month!
    }
    
    func computerOffSetY () -> Double {
        if (!showState) {
            return 350.0
        }
        return offsetY > 0 ? offsetY : 0
    }
}

struct YmDatePickerRepresentable : UIViewRepresentable {
    // 年
    @Binding var year:Int
    // 月
    @Binding var month:Int
    
    typealias UIViewType = UIPickerView
    
    func makeUIView(context: Context) -> UIPickerView {
        let uiPickerView = UIPickerView()
        uiPickerView.dataSource = context.coordinator
        uiPickerView.delegate = context.coordinator
        return uiPickerView
    }
    
    func updateUIView(_ uiPickerView: UIPickerView, context: Context) {
        context.coordinator.refreshDefaultPicker(uiPickerView,component: 0,value: year)
        context.coordinator.refreshMothArray(year: year)
        context.coordinator.refreshDefaultPicker(uiPickerView,component: 1,value: month)
        uiPickerView.reloadAllComponents()
    }
    
    func makeCoordinator() -> YmDatePickerDataSourceAndDelegate {
        YmDatePickerDataSourceAndDelegate(self)
    }
    
    class YmDatePickerDataSourceAndDelegate : NSObject,UIPickerViewDataSource, UIPickerViewDelegate {
        // 年月日选择-年
        var yearArray:[Int] = Array(1970...DateUtils.findComponentsOfDate([.year], date: Date()).year!)
        // 年月日选择-月
        var monthArray:[Int] = Array(1...12)
        
        private var parent:YmDatePickerRepresentable
        
        init(_ ymDatePickerRepresentable : YmDatePickerRepresentable) {
            self.parent = ymDatePickerRepresentable
            monthArray = YmDatePickerDataSourceAndDelegate.computerMonthArray(year: ymDatePickerRepresentable.year)
        }
        // 多少列
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            2
        }
        // 每列多少行
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if (component == 0) {
                return yearArray.count
            } else if (component == 1) {
                return monthArray.count
            }
            return 0
        }
        // 宽度
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            let w = pickerView.frame.width
            return (1/3) * w
        }
        // 选择行的高度
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 50.0
        }
        // 自定义试图
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing : UIView?) -> UIView {
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
                       
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            
            if (component == 0) {
                let year = yearArray.count-1 < row ? yearArray[yearArray.count-1] : yearArray[row]
                label.text = String("\(year)年")
            } else if (component == 1) {
                let month = monthArray.count-1 < row ? 1 : monthArray[row]
                label.text = String("\(month)月")
            }
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20, weight: .black)
            // 设置选中的颜色，需要配合 pickerView.reloadAllComponents()
            label.textColor = pickerView.selectedRow(inComponent: component) == row ? UIColor(Color("DefaultButtonBackgroud")): UIColor(Color.primary)
            view.addSubview(label)
            // 背景颜色
            pickerView.subviews[1].alpha = 0
            return view
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if (component == 0) {
                // 年
                self.parent.year = yearArray[row]
                refreshDefaultPicker(pickerView, component: 0, value: self.parent.year)
                refreshMothArray(year: self.parent.year)
            } else if (component == 1) {
                // 月
                self.parent.month = monthArray[row]
                refreshDefaultPicker(pickerView, component: 1, value: self.parent.month)
            }
            pickerView.reloadAllComponents()
        }
        func refreshMothArray(year:Int) {
            self.monthArray = YmDatePickerDataSourceAndDelegate.computerMonthArray(year: year)
           
        }
        /**
         更新月和日
         */
        func refreshDefaultPicker(_ pickerView: UIPickerView) {
            refreshDefaultPicker(pickerView, component: 0, value: self.parent.year)
            refreshDefaultPicker(pickerView, component: 1, value: self.parent.month)
        }
        /**
        更新默认的选择项
         */
        func refreshDefaultPicker(_ pickerView: UIPickerView, component: Int, value:Int) {
            var row = 0
            if (component == 0) {
                row = yearArray.firstIndex(of: value) ?? 0
            } else if (component == 1) {
                row = monthArray.firstIndex(of: value) ?? 0
            }
            pickerView.selectRow(row, inComponent: component, animated: true)
        }
        /**
        计算月数组
         */
        static func computerMonthArray(year:Int) -> [Int] {
            let component = DateUtils.findComponentsOfDate([.year,.month], date: Date())
            // 当前的年月日
            let yearNow = component.year!
            let monthNow = component.month!
            var monthLength = monthNow
            if (year < yearNow) {
                monthLength = 12
            }
            return Array(1...monthLength)
        }
        /**
         计算日数组
         */
        static func computerDayArray(year:Int,month:Int) -> [Int] {
            let component = DateUtils.findComponentsOfDate([.year,.month,.day], date: Date())
            // 当前的年月日
            let yearNow = component.year!
            let monthNow = component.month!
            let dayDaw = component.day!
            // 日数组最后一天
            var dayLength = dayDaw
            if (year < yearNow || month < monthNow ) {
                dayLength = DateUtils.monthOfDayLength(year:year, month: month)
            }
            return Array(1...dayLength)
        }
    }
}
