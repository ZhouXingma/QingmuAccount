//
//  AcouuntKeyBoard.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/5.
//

import SwiftUI
import AVFoundation
struct AcountKeyBoard : View {
    @State var date:String = "今天"
    @State var nowDate = DateUtils.transDate2String(Date(), format: "yyyy-MM-dd")
    @State var desc:String = ""
    @State var descChangeFun:(String) -> Void
    @State var dateChangeFun:(String) -> Void
    @State var keyTabFun:(Int) -> Void
    @State private var showDatePicker:Bool = false
    @State private var datePickerType:DatePickerType = .YMD
    @State private var datePickerParam:DatePickerValue = DatePickerValue()
    @StateObject var acountKeyBoardNotifaction = AcountKeyBoardNotifaction()
    
    var body: some View {
        VStack(spacing:5) {
            HStack(alignment: .center) {
                HStack {
                    HStack {
                      Image(systemName: "list.dash.header.rectangle")
                            .foregroundColor(.secondary)
                      TextField("输入备注", text: $desc).frame(minWidth: 0,maxWidth: .infinity)
                            .foregroundColor(.secondary)
                            .onChange(of: desc) { newValue in
                                descChangeFun(newValue)
                            }
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    Button {
                        toHideKeyboard()
                        showDatePicker = true
                    } label: {
                        Text(date)
                        .frame(width: 100,height: 30)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .background(Color("SecendButtonBackgroud").opacity(0.2),in:RoundedRectangle(cornerRadius: 30))
                    }
                }.padding(.horizontal,10)
                    .padding(.vertical,3)
            }.frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 40)
            .background(Color("MainBackgroundColor"))
            
            HStack(spacing: 8) {
                VStack(spacing: 5) {
                    HStack {
                        ForEach(0...2, id:\.self) { i in
                            AcountKeyBoardButton(c:acountKeyBoardKeysArray[i],keyTabFun:keyTabFun)
                        }
                    }
                    HStack {
                        ForEach(3...5, id:\.self) { i in
                            AcountKeyBoardButton(c:acountKeyBoardKeysArray[i],keyTabFun:keyTabFun)
                        }
                    }
                    HStack {
                        ForEach(6...8, id:\.self) { i in
                            AcountKeyBoardButton(c:acountKeyBoardKeysArray[i],keyTabFun:keyTabFun)
                        }
                    }
                    HStack {
                        ForEach(9...11, id:\.self) { i in
                            AcountKeyBoardButton(c:acountKeyBoardKeysArray[i],keyTabFun:keyTabFun)
                        }
                    }
                }.frame(minWidth: 0,maxWidth: .infinity)
                VStack(spacing: 5) {
                    AcountKeyBoardButton(c:acountKeyBoardKeysArray[12],keyTabFun:keyTabFun)
                    AcountKeyBoardButton(c:acountKeyBoardKeysArray[13],keyTabFun:keyTabFun)
                    AcountKeyBoardButton(c:acountKeyBoardKeysArray[14],keyTabFun:keyTabFun)
                }.frame(width: 80)
            }.frame(minWidth: 0,maxWidth: .infinity)
                .padding(.horizontal,8)
        }.frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 260)
            .background(Color("ViewBackgroundColor"))
            .offset(y: acountKeyBoardNotifaction.offY)
            .selfDatePicker(showState: $showDatePicker, type: $datePickerType, param: $datePickerParam) { value in
                if (nil != value.year && nil != value.month && nil != value.day) {
                    self.datePickerParam.year = value.year
                    self.datePickerParam.month = value.month
                    self.datePickerParam.day = value.day
                    
                    let monthStr:String = value.month! < 10 ? "0\(value.month!)" : "\(value.month!)"
                    let dayStr:String = value.day! < 10 ? "0\(value.day!)" : "\(value.day!)"
                    var dateTemp = "\(value.year!)-\(monthStr)-\(dayStr)"
                    if (dateTemp == self.nowDate) {
                        dateTemp = "今天"
                    }
                    self.date = dateTemp
                    dateChangeFun(dateTemp)
                }
               
            }
            .animation(.easeInOut(duration: 0.1), value: acountKeyBoardNotifaction.offY)
    }
   
}

struct AcountKeyBoardButton : View {
    let c:AcountKeyBoardButtonConfig
    var keyTabFun:(Int) -> Void
    let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)

    var body: some View {
        HStack {
            Button {
                
                toHideKeyboard()
                // 如果背景在播放音乐，会产生影响
                //playKeySound()
                keyFeedback()
                keyTabFun(c.id)
            } label: {
                if (!c.isImage) {
                    Text(c.showKeyStr)
                        .frame(minWidth: 0,maxWidth: .infinity)
                        .frame(height: c.height)
                        .font(.system(size: 16,weight: .bold))
                        .foregroundColor(c.fontColor)
                        .background(c.bgColor,in:RoundedRectangle(cornerRadius: 5))
                } else {
                    Image(systemName: c.showKeyStr)
                        .frame(minWidth: 0,maxWidth: .infinity)
                        .frame(height: c.height)
                        .foregroundColor(c.fontColor)
                        .background(c.bgColor,in:RoundedRectangle(cornerRadius: 5))
                }
                
            }.padding(0)
        }.padding(0)
    }
    
    func playKeySound() {
        if (c.id == 12) {
            AudioServicesPlaySystemSound(1105)
        } else {
            AudioServicesPlaySystemSound(1306)
        }
    }
}


class AcountKeyBoardButtonConfig:Identifiable {
    var id: Int
    var showKeyStr: String
    var isImage: Bool = false
    var height: Double = 50.0
    var bgColor: Color = Color("MainBackgroundColor")
    var fontColor: Color = Color("FontColor")
    init(id: Int, showKeyStr: String, isImage: Bool = false, height: Double = 50, bgColor:Color = Color("MainBackgroundColor"),fontColor:Color = Color("FontColor")) {
        self.id = id
        self.showKeyStr = showKeyStr
        self.isImage = isImage
        self.height = height
        self.bgColor = bgColor
        self.fontColor = fontColor
    }
}


var acountKeyBoardKeysArray = [
    AcountKeyBoardButtonConfig(id:1,showKeyStr:"1"),
    AcountKeyBoardButtonConfig(id:2,showKeyStr:"2"),
    AcountKeyBoardButtonConfig(id:3,showKeyStr:"3"),
    AcountKeyBoardButtonConfig(id:4,showKeyStr:"4"),
    AcountKeyBoardButtonConfig(id:5,showKeyStr:"5"),
    AcountKeyBoardButtonConfig(id:6,showKeyStr:"6"),
    AcountKeyBoardButtonConfig(id:7,showKeyStr:"7"),
    AcountKeyBoardButtonConfig(id:8,showKeyStr:"8"),
    AcountKeyBoardButtonConfig(id:9,showKeyStr:"9"),
    AcountKeyBoardButtonConfig(id:10,showKeyStr:"."),
    AcountKeyBoardButtonConfig(id:11,showKeyStr:"0"),
    AcountKeyBoardButtonConfig(id:12,showKeyStr:"delete.backward.fill",isImage:true),
    AcountKeyBoardButtonConfig(id:13,showKeyStr:"+"),
    AcountKeyBoardButtonConfig(id:14,showKeyStr:"-"),
    AcountKeyBoardButtonConfig(id:15,showKeyStr:"完成",height: 105, bgColor: Color("DefaultButtonBackgroud"),fontColor:.white),
]
