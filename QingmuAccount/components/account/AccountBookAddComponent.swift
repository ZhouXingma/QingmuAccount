//
//  AccountBookAddComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
struct AccountBookAddComponent : View {
    // 全局环境
    @EnvironmentObject var globalModel:GlobalModel
    // 图标的显示样式
    private let iConGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 45), count: 3)
    // 颜色的显示样式
    private let colorGridItems: [GridItem] = Array(repeating: GridItem(.flexible(),spacing: 40), count: 4)
    // 账本名称
    @State private var accountBookName:String = ""
    // 选择的图标
    @State private var selectIcon:IconFontEnum = .icon1
    // 选择的颜色
    @State private var selectColor:String = ""
    
    // 是否显示提醒
    @State private var showSelfAlter = false
    // 是否显示添加结果
    @State private var showNormalAlter = false
    // 失败信息提醒配置
    @State private var alterConfig = AlertComponentConfig()
    // 普通信息提醒配置
    @State private var normalAlterConfig = AlertComponentConfig()
    // 是否显示等待
    @State private var isCreatingWait = false;
    // 添加成功后/更新成功后的执行对象
    var handleAccountBookSuccessFun: ([String:AccountBookModel]?) -> Void
    // 更新账本名字
    @Binding var updateAccountBook: AccountBookModel?

    
    var body: some View {
        VStack {
            AccountBookAddForm_PreView
            ScrollView(showsIndicators: false) {
                AccountBookAddForm_AccountBookIcon
                AccountBookAddForm_AccountBookColor
            }
            Spacer()
            
            VStack {
                Button {
                    toHideKeyboard()
                    handleAccountBook()
                } label: {
                    HStack {
                        Text("确认")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                            .padding(.vertical, 15)
                    }.frame(width: 250, height: 50, alignment: .center)
                        .background(Color("DefaultButtonBackgroud").opacity(validForm() ? 1: ColorConfig.UNABLE_COLOR_OPCITY), in: RoundedRectangle(cornerRadius: 10))
                }.disabled(!validForm() || isCreatingWait)
            }.padding(.bottom,30)
            
        }.ignoresSafeArea()
            .padding(.horizontal,15)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 0, maxHeight: .infinity)
            .background(Color("ViewBackgroundColor"))
            .selfAlter(showState: $showSelfAlter, config: alterConfig)
            .selfAlter(showState: $showNormalAlter, config: normalAlterConfig)
            .selfLoading(showState: $isCreatingWait)
            .onAppear() {
                self.accountBookName = updateAccountBook?.name ?? ""
                let tempIcon:IconFontEnum = IconFontEnum.findByValue(updateAccountBook?.iconStr ?? "") ?? .icon1
                self.selectIcon = tempIcon
                self.selectColor = updateAccountBook?.bgColor ?? ""
            }
    }
    /**
     处理账本的操作
     */
    func handleAccountBook () {
        if nil != updateAccountBook {
            updateAccountBookSure()
        } else {
            addAccountBook()
        }
    }
    
    /**
     添加账本
     */
    func addAccountBook() {
        alterConfig.showCancelButton = true
        alterConfig.cancalButtonName = "取消"
        alterConfig.showSureButton = true
        alterConfig.sureButtonName = "确定"
        alterConfig.desc="确定添加该账本吗？"
        alterConfig.cancelFun = {}
        alterConfig.sureFun = addAccountBookSure
        withAnimation(.easeOut) {
            showSelfAlter = true
        }
    }
    /**
     确认添加账本操作
     */
    func addAccountBookSure() {
        isCreatingWait = true
        do {
            let data = try AccountBookHandleOfCacheService.addAccountBook(name: StringUtils.trim(accountBookName),icon:selectIcon.rawValue,bgColor:selectColor, cache: globalModel)
            openNormalAlter("添加账本成功！")
            accountBookName=""
            handleAccountBookSuccessFun(data)
        } catch AccountBookHandleError.ISEXIT {
            openNormalAlter("添加账本失败！该账本已经存在",.RED)
        } catch {
            openNormalAlter("添加账本失败！",.RED)
        }
        isCreatingWait = false
    }
    
    func updateAccountBookSure() {
        isCreatingWait = true
        do {
            let data = try AccountBookHandleOfCacheService.updateAccountBook(id:updateAccountBook!.id, name: StringUtils.trim(accountBookName),icon:selectIcon.rawValue,bgColor:selectColor,cache: globalModel)
            openNormalAlter("更新账本成功！")
            handleAccountBookSuccessFun(data)
        } catch AccountBookHandleError.ISNOTEXIT {
            openNormalAlter("更新账本失败！该账本不存在",.RED)
        } catch {
            openNormalAlter("更新账本失败！",.RED)
        }
        isCreatingWait = false
    }
    
    var AccountBookAddForm_AccountBookIcon: some View {
        VStack {
            AccountBookAddFormTitleView(title:"选择图标")
            ScrollView(.horizontal,showsIndicators: false) {
                LazyHGrid(rows: iConGridItems) {
                    ForEach(accountBookIconArray,id:\.self) { item in
                        VStack {
                            Text(item.rawValue)
                                .font(.custom("icomoon", size: 26))
                                .foregroundColor(selectIcon == item ? .white : Color("DefaultButtonBackgroud"))
                                .padding(10)
                        }.background(selectIcon == item ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"),in: RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                 selectIcon = item
                                toHideKeyboard()
                            }
                    }
                   
                }.padding(.vertical,30)
            }
        }
    }
    
    var AccountBookAddForm_AccountBookColor: some View {
        VStack {
            AccountBookAddFormTitleView(title:"选择颜色")
            ScrollView(.horizontal,showsIndicators: false) {
                LazyHGrid(rows: colorGridItems) {
                    ForEach(ColorConfig.SOFT_COLORS,id:\.self) { item in
                        ZStack {
                            Color(hex:item)
                                .frame(width: 60, height: 40, alignment: .center)
                            Image(systemName: "checkmark.circle").foregroundColor(Color("DefaultButtonBackgroud")).opacity(selectColor == item ? 1 : 0)
                        }.onTapGesture {
                            if (selectColor == item) {
                                selectColor = ""
                            } else {
                                selectColor = item
                            }
                        }
                    }
                }.padding(.vertical,20)
            }
        }
    }
    
    var AccountBookAddForm_PreView : some View {
        HStack {
            Text(selectIcon.rawValue).font(.custom("icomoon", size: 25))
                .foregroundColor(.white)
                .padding(10)
                .background(selectColor.count<=0 ? Color("DefaultButtonBackgroud") : Color(hex: selectColor), in: RoundedRectangle(cornerRadius: 10))
            //Text(StringUtils.trim(accountBookName)).font(.system(size: 16, weight: .bold))
            TextField("账本名字,6个字内", text: $accountBookName)
                .multilineTextAlignment(.leading)
                .font(.system(size: 14, weight: .bold))
                .frame(height: 40)
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(minWidth: 0,maxWidth: .infinity,alignment: .center)
        .frame(height: 60)
        .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 10)
        
          
    }
    
    /**
    开启普通提示
     */
    func openNormalAlter(_ desc:String, _ style:AlertComponentTopBarColorStyle = .DEFAULT) {
        normalAlterConfig.showCancelButton = false
        normalAlterConfig.showSureButton = true
        normalAlterConfig.sureButtonName = "我知道啦！"
        normalAlterConfig.desc = desc
        normalAlterConfig.topBarColorStyle = style
        withAnimation {
            showNormalAlter = true
        }
    }
    /**
     表单是否已经填写完整
     */
    func validForm() -> Bool {
        if(StringUtils.trimCount(accountBookName) <= 0 || StringUtils.trimCount(accountBookName) > 6) {
            return false
        }
        return true
    }
}

struct AccountBookAddFormTitleView : View {
    @State var title:String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14,weight: .bold))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
