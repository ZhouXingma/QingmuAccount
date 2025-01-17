//
//  YmDatePickerComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/5.
//

import SwiftUI

struct DataPickerComponent : View {
    @Binding var showState:Bool
    @Binding var param:DataPickerValue
    @Binding var datas:[DataPickerValue]
    @State var pickerSure:(DataPickerValue)->Void
    @State var pickerValue:DataPickerValue = DataPickerValue()
    @State private var offsetY:Double = 0

    var body: some View {
        VStack {
            Spacer()
            VStack {
                HStack {
                    VStack {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("DefaultButtonBackgroud"))
                    }.onTapGesture {
                        closeShow()
                    }
                  
                    Spacer()
                    VStack {
                        Text("确认")
                            .foregroundColor(.white)
                            .padding(.horizontal,20).padding(.vertical,5).background(Color("DefaultButtonBackgroud"),in: RoundedRectangle(cornerRadius: 5))
                    }.onTapGesture {
                        pickerSure(pickerValue)
                        closeShow()
                    }
            
                }.frame(height: 30)
                    .padding(.horizontal,20)
                    .padding(.vertical,10)
                   
                DataPickerRepresentable(pickerValues: $datas,pickerValue: $pickerValue)
                
            }.background(Color("MainBackgroundColor"))
            .shadow(color: Color("MainShadowColor").opacity(0.3), radius:20,x: 1,y:-10)
            .frame(height: 300)
            .offset(y: computerOffSetY())
            .animation(.easeInOut,value: computerOffSetY())
            .onAppear() {
                if self.datas.count > 0 {
                    self.pickerValue = self.datas[self.datas.count - 1]
                }
               
            }
        }
    }
    
    func closeShow() {
        showState = false
    }
    
    func computerOffSetY () -> Double {
        if (!showState) {
            return 350.0
        }
        return offsetY > 0 ? offsetY : 0
    }
}

struct DataPickerRepresentable : UIViewRepresentable {
    @Binding var pickerValues:[DataPickerValue]
    // 选择的数据
    @Binding var pickerValue:DataPickerValue
    
    typealias UIViewType = UIPickerView
    
    func makeUIView(context: Context) -> UIPickerView {
        let uiPickerView = UIPickerView()
        uiPickerView.dataSource = context.coordinator
        uiPickerView.delegate = context.coordinator
        return uiPickerView
    }
    
    func updateUIView(_ uiPickerView: UIPickerView, context: Context) {
        context.coordinator.refreshDefaultPicker(uiPickerView, component: 0,value: pickerValue)
        uiPickerView.reloadAllComponents()
    }
    
    func makeCoordinator() -> DataPickerDataSourceAndDelegate {
        DataPickerDataSourceAndDelegate(self)
    }
    
    class DataPickerDataSourceAndDelegate : NSObject,UIPickerViewDataSource, UIPickerViewDelegate {
        
        private var parent:DataPickerRepresentable
        
        init(_ dataPickerRepresentable : DataPickerRepresentable) {
            self.parent = dataPickerRepresentable
        }
        // 多少列
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }
        // 每列多少行
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if (component == 0) {
                return parent.pickerValues.count
            }
            return 0
        }
        // 宽度
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            let w = pickerView.frame.width
            return w
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
                let value = parent.pickerValues.count-1 < row ? parent.pickerValues[parent.pickerValues.count-1] : parent.pickerValues[row]
                label.text = String("\(value.data ?? "")")
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
                self.parent.pickerValue = self.parent.pickerValues[row]
                refreshDefaultPicker(pickerView, component: 0, value: self.parent.pickerValue)
            }
            pickerView.reloadAllComponents()
        }
        /**
        更新默认的选择项
         */
        func refreshDefaultPicker(_ pickerView: UIPickerView, component: Int, value:DataPickerValue) {
            if nil == value.data || nil == value.key {
                return
            }
            var row = 0
            if (component == 0) {
                for (index,item) in parent.pickerValues.enumerated() {
                    if item.key == value.key && item.data == value.data {
                        row = index
                        break
                    }
                }
            }
            pickerView.selectRow(row, inComponent: component, animated: true)
        }
    }
}
