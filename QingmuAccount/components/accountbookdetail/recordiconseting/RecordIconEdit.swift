//
//  RecordIconEdit.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/15.
//

import SwiftUI
import Combine
struct RecordIconEdit:View {
    // 用于关闭当前窗口
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var surplus:Int = 4
    @State var iconTypeList:[String] = ["衣","食","住","行","购","乐","医","育","情","公","投","其"]
    @State var selectIconType:String = "衣"
    @ObservedObject var selectIconConfig:SelectIconConfig = SelectIconConfig()
    // 因为图标类型按钮改变
    @State var changeByIconTypeButton:Bool = false
    // 添加修改图标
    @State var addOrUpdateIconFunc:(_ iconStr:String, _ name:String, _ id:String) -> Bool = {_,_,_ in  return true }
    // 删除图标
    @State var removeIconFunc:(_ id:String) -> Bool = {_ in  return true }
    // 提醒
    @State var showAlter = false
    @State var alterConfig = AlertComponentConfig()
    // 编辑图标
    @Binding var editAccountBookIcon:AccountBookSetingOfIconModel?
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if (StringUtils.trimCount(selectIconConfig.iconStr) > 0) {
                        Text(hexStr2Unicode(selectIconConfig.iconStr))
                            .font(.custom("icomoon", size: 30))
                            .foregroundColor(Color("FontColorSecend"))
                    }
                }.frame(width: 55, height: 55)
                    .background(.ultraThinMaterial, in:RoundedRectangle(cornerRadius: 10))
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            Text("最长4个字").font(.system(size: 10)).foregroundColor(.secondary.opacity(0.4))
                            Spacer()
                        }
                       
                    }.frame(height: 55)
                    TextField("图标名称", text: $selectIconConfig.name)
                }.frame(height: 55)
            }.padding(20)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 80)
                .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal,20)
                .padding(.top,20)
            
            HStack{
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(iconTypeList,id:\.self) {key in
                                LeftMenu(name: key, selectIconType: $selectIconType,changeByIconTypeButton: $changeByIconTypeButton)
                            }
                        }
                    }
                }.frame(width: 50)
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            ForEach(iconTypeList,id:\.self) {key in
                                TypeGrid(name: key, iconList: iconTypeMap[key]!, selectIconConfig: selectIconConfig)
                            }
                        }.coordinateSpace(name: "iconListScrollView")
                        .onChange(of: selectIconType) { newValue in
                            if changeByIconTypeButton {
                                proxy.scrollTo(newValue,anchor: UnitPoint(x: 0, y: 0))
                            }
                        }
                    }.onPreferenceChange(IconTypeScrollPreferenceKey.self) { newValue in
                        if StringUtils.trimCount(newValue) > 0 {
                            changeByIconTypeButton = false
                            selectIconType = newValue
                        }
                    }
                }.frame(minWidth: 0,maxWidth: .infinity)
            }.padding(.vertical,5)
            
            
            HStack {
                let isFull = StringUtils.trimCount(selectIconConfig.name)>0 && StringUtils.trimCount(selectIconConfig.iconStr)>0
                && StringUtils.trimCount(selectIconConfig.name) <= 4
                if (nil != editAccountBookIcon) {
                    Button {
                        var _ = removeIconFunc(editAccountBookIcon!.id)
                    } label: {
                        HStack {
                            Text("删除")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 15)
                        }.frame(maxWidth: 200)
                            .background(Color("RedColor").opacity(isFull ? 1 : 0.5), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.top,5)
                    }
                }
                
                Button {
                    if nil != editAccountBookIcon {
                        let isSuccess = addOrUpdateIconFunc(selectIconConfig.iconStr, selectIconConfig.name, editAccountBookIcon!.id)
                        if isSuccess {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showAlter = true
                            alterConfig.desc = "修改失败，名称已存在"
                        }
                    } else {
                        let isSuccess = addOrUpdateIconFunc(selectIconConfig.iconStr, selectIconConfig.name, "")
                        if isSuccess {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showAlter = true
                            alterConfig.desc = "添加失败，名称已存在"
                        }
                    }
                   
                } label: {
                    HStack {
                        Text(nil != editAccountBookIcon ? "修改" : "添加")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                            .padding(.vertical, 15)
                    }.frame(maxWidth: 200)
                        .background(Color("DefaultButtonBackgroud").opacity(isFull ? 1 : 0.5), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.top,5)
                }.disabled(!isFull)
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(.vertical,5)
                .padding(.horizontal,20)
                .padding(.bottom, 25)
                .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
                
        }.ignoresSafeArea().frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color("ViewBackgroundColor"))
            .onTapGesture {
                toHideKeyboard()
            }.selfAlter(showState: $showAlter, config: alterConfig)
            .onAppear() {
                selectIconConfig.iconStr = editAccountBookIcon?.iconStr ?? ""
                selectIconConfig.name = editAccountBookIcon?.name ?? ""
            }
    }
}

struct LeftMenu:View {
    @State var name:String
    @Binding var selectIconType:String
    @Binding var changeByIconTypeButton:Bool
    var body: some View {
        Button {
            changeByIconTypeButton = true
            selectIconType = name
        } label: {
            Text(name)
                .font(.system(size: 13))
                .frame(width: 50,height: 40)
                .foregroundColor(selectIconType == name ? .white : .secondary)
                .background(selectIconType == name ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"))
        }
    }
}


struct TypeGrid:View {
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 5), count: 5)
    @State var name:String
    @State var iconList:[AccountBookSetingOfIconModel]
    @State var selectIconConfig:SelectIconConfig
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let minY = proxy.frame(in: .named("iconListScrollView")).minY
                let value = minY >= -50 && minY <= 0 ? name : ""
                Color.clear.preference(
                    key: IconTypeScrollPreferenceKey.self,
                    value:value
                ).frame(height: 0)
                HStack {
                    Text(name)
                        .foregroundColor(.secondary.opacity(0.4))
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                }
            }.padding(.vertical,5)
            
            VStack {
                LazyVGrid(columns: iConGridItems) {
                    ForEach(iconList,id:\.self.id) { item in
                        RecordItemIconButton(iconStr: item.iconStr, name: item.name, selectIconStr: $selectIconConfig.iconStr)
                            .onTapGesture {
                                selectIconConfig.iconStr = item.iconStr
                                selectIconConfig.name = item.name
                            }
                    }
                }.padding(.trailing,10)
            }
        }.id(name)
    }
}

class SelectIconConfig :ObservableObject {
    @Published var iconStr:String = ""
    @Published var name:String = ""
}
