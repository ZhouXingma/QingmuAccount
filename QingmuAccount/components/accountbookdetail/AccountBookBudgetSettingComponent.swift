//
//  AccountBookBudgetSettingComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2024/1/16.
//

import SwiftUI
import Combine

struct AccountBookBudgetSettingComponent: View {
    var thisMothBugget = ""
    var saveBudgetSeting : (String) -> Void = {a in }
    // 本月
    @State var thisMonth:Int = DateUtils.findComponentsOfDate([.month], date: Date()).month!
    // 设置预算的参数-预算金额
    @State private var setingBugget = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("设置预算").font(.system(size: 18, weight: .bold))
            }.padding(.bottom,10)
            VStack {
                HStack {
                    Text("\(thisMonth)月预算").font(.system(size: 16,weight: .bold))
                    Spacer()
                }.frame(height: 20)
                HStack {
                    TextField("输入预算金额",text: $setingBugget)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 26,weight: .bold))
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .keyboardType(.decimalPad)
                        .onReceive(Just(setingBugget)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            let pointIndex = inclusePointIndex(filtered)
                            let lastPointIndex = lastPointIndex(filtered)
                            if (pointIndex == 0) {
                                self.setingBugget = "0."
                                return
                            }
                            if (pointIndex != lastPointIndex ) {
                                self.setingBugget = String(filtered[filtered.startIndex...filtered.index(filtered.startIndex, offsetBy: (lastPointIndex-1))])
                            } else if (pointIndex > -1 && filtered.count - pointIndex > 2) {
                                self.setingBugget = String(filtered[filtered.startIndex...filtered.index(filtered.startIndex, offsetBy: (pointIndex + 2))])
                            } else {
                                self.setingBugget = filtered
                            }
                           
                        }
                }
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 80)
                .padding(10)
                .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            VStack {
                Button{
                    saveBudgetSeting(setingBugget)
                } label: {
                    Text("保存").tint(.white)
                        .frame(width: 250, height: 50, alignment: .center)
                        .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
                }.padding(.vertical,20)
            }.padding(.bottom, 20)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea()
            .padding(.top, 20)
            .padding(.horizontal,20)
            .background(Color("ViewBackgroundColor"))
            .onAppear() {
                loadData()
            }
            .onTapGesture {
                toHideKeyboard()
            }
    }
    
    func loadData() {
        setingBugget = thisMothBugget
    }
    /**
     计算小数点位置
     */
    func inclusePointIndex(_ value:String) -> Int {
        let p = value.firstIndex(of: ".")
        if let a = p {
            return a.utf16Offset(in: value)
        }
        return -1
    }
    
    func lastPointIndex(_ value:String) -> Int {
        let p = value.lastIndex(of: ".")
        if let a = p {
            return a.utf16Offset(in: value)
        }
        return -1
    }
}

struct AccountBookBudgetSettingComponent_Previews: PreviewProvider {
    static var previews: some View {
        AccountBookBudgetSettingComponent()
    }
}
