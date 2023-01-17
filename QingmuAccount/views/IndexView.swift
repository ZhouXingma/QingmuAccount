//
//  IndexMainView.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/30.
//

import SwiftUI

struct IndexView : View {
    @EnvironmentObject var globalModel:GlobalModel
    @AppStorage("selectAccountBook") private var selectAccountBook = AccountBookHandleService.DEFAULT_NAME
    // 系统当前颜色模式
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var initAccountBookResult:Bool = false
    @State private var initAccountBookConfig = AlertComponentConfig(desc: "初始化账本失败",
                            showCancelButton: false,
                            sureButtonName: "我知道了")
    // 选择的tabView的tag
    @State private var selection:Int = 0
    // 滑动变动参数，用于计算菜单文字大小和颜色动态变化，以及菜单下的滚动条位置
    @State private var x:Double = 0
    // 菜单下面的滚动条偏移量
    @State private var offsetX:Double = 0
    // 是否显示加载
    @State private var showLoding = false
    // 显示提醒
    @State private var showAlter = false
    // 提醒的配置信息
    @State private var alterConfig = AlertComponentConfig(showCancelButton: false, sureButtonName: "我知道了")
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    TopMenu
                    ContentTabView
                }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
                    .ignoresSafeArea(.all,edges: .bottom)
                    .background(Color("ViewBackgroundColor"))
                    .navigationBarBackButtonHidden()
                    .navigationBarHidden(true)
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .selfLoading(showState: $showLoding)
        .selfAlter(showState: $showAlter, config: alterConfig)
        .onAppear() {
            initData()
        }
    }
    
    /**
     菜单下面的横杠偏移量
     */
    func computerTopEnumSubBarOffx(_ value:[Int:Double]) {
        x = value[selection] ?? 0
        var tempSelection = selection
        if (x < 0 && -x > 0.5) {
            tempSelection = tempSelection - 1
        }
        if (x > 0 &&  x >= 0.5) {
            tempSelection = tempSelection + 1
        }
        offsetX = (Double(tempSelection)-x) * 56
    }

    /**
     初始化默认账本
     */
    func initData() {
        showLoding = true
        
        do {
            try AccountBookHandleOfCacheService.initAcountBook(selectAccountBookName:selectAccountBook, cache: globalModel)
        } catch AccountBookHandleError.ISEXIT {
            
        } catch {
            alterConfig.desc = "初始化账本失败"
            showAlter = true
        }
        
        do {
            // 初始化账本设置
            if nil != globalModel.accountBook {
                try AccountBookSetingOfCacheService.initSeting(globalModel.accountBook!.id.description, cache: globalModel)
            }
        } catch AccountBookSetingError.ISEXIT {
           
        } catch {
            alterConfig.desc = "初始化账本设置失败"
            showAlter = true
        }
        showLoding = false
    }
    /**
     顶部菜单
     */
    var TopMenu : some View {
        VStack {
            HStack {
                HStack(alignment: .bottom) {
                    TopMenuItem(name: "账本", menuSelection: 0, currentSelection: $selection, changeValue: $x)
                    TopMenuItem(name: "资产", menuSelection: 1, currentSelection: $selection, changeValue: $x)
                }
                Spacer()
                NavigationLink {
                    AccountBookSelectComponent().environmentObject(globalModel)
                } label: {
                    Image(systemName: "list.bullet.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                }
                NavigationLink {
                    PersonView().environmentObject(globalModel)
                } label: {
                    Image(systemName: "person.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                }
            }
            HStack{
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 30,height: 5)
                        .offset(x: offsetX)
                    Spacer()
                }.padding(.horizontal,10)
                Spacer()
            }.offset(y:-5)
        }.padding(.horizontal,10)
    }
    /**
       内容
     */
    var ContentTabView : some View {
        TabView(selection: $selection) {
            VStack {
                MainTabViewScrollPrefreceViewSetter(tag: 0)
                AccountBookDetailView().environmentObject(globalModel)
            }.tag(0)
            VStack {
                MainTabViewScrollPrefreceViewSetter(tag: 1)
                AssetsView().environmentObject(globalModel)
            }.tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onPreferenceChange(MainTabViewScrollPreferenceKey.self,perform: { value in
           computerTopEnumSubBarOffx(value)
        })
        
    }
    
}

struct MainTabViewScrollPrefreceViewSetter : View {
    let tag:Int
    var body: some View {
        GeometryReader { proxy in
            let value = proxy.frame(in:.global).minX/proxy.frame(in: .global).width
            Color.clear.preference(
                key: MainTabViewScrollPreferenceKey.self,
                value: [tag:value]
            ).frame(height: 0)
        }.frame(height: 0)
    }
}




struct TopMenuItem : View {
    @State var name : String
    @State var menuSelection: Int
    @Binding var currentSelection : Int
    @Binding var changeValue:Double
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("FontColor").opacity(computerFontColorOpacity()))
                .scaleEffect(computerFontColorOpacity())
        }.frame(height: 40)
            .onTapGesture {
                currentSelection = menuSelection
            }
        
    }
    /**
     计算文字的颜色
     */
    func computerFontColorOpacity() -> Double {
        if (computerOutSelection() == menuSelection) {
            return 1 - 0.3 * abs(changeValue)
        } else if (computerInSelection() == menuSelection) {
            return 0.7 + 0.3 * abs(changeValue)
        }
        return 0.7
    }
    
    /**
     计算要选中的菜单编号
     */
    func computerInSelection() -> Int{
        var inSelectionTemp = currentSelection
        if (changeValue < 0 && -changeValue < 0.5) {
            inSelectionTemp = currentSelection + 1
        }
        if (changeValue > 0 && changeValue <= 0.5) {
            inSelectionTemp = currentSelection - 1
        }
        return inSelectionTemp
    }
    /**
     计算要消失的菜单编号
     */
    func computerOutSelection() -> Int {
        var outSelectionTemp = currentSelection
        if (changeValue < 0 && -changeValue > 0.5) {
            outSelectionTemp = currentSelection - 1
        }
        if (changeValue > 0 && changeValue >= 0.5) {
            outSelectionTemp = currentSelection + 1
        }
        return outSelectionTemp
    }
}
