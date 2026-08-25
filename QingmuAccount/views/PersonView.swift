//
//  Setting.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

struct PersonView : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var globalModel:GlobalModel
    @State var showAlter:Bool = false
    @State var showAlterConfig:AlertComponentConfig = AlertComponentConfig(desc:"操作失败！")
    @State var showLoading:Bool = false
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    DefaultTopBarComponent {
                        presentationMode.wrappedValue.dismiss()
                    }
                    if nil != globalModel.accountBook {
                        AccountBookActiveCard(accountBook: globalModel.accountBook!)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 16)
                    }
                    VStack {
                        NavigationLink {
                            AccountBookSettingComponent().environmentObject(globalModel)
                        } label: {
                            PersonMenuItem(text: "账本", imageSystemName: "book", foregroundColor: Color("DefaultButtonBackgroud"))
                                .listRowSeparator(.hidden)
                        }.foregroundColor(.primary)

                        NavigationLink {
                            AssetAccountSettingView().environmentObject(globalModel)
                        } label: {
                            PersonMenuItem(text: "资产账户", imageSystemName: "creditcard", foregroundColor: Color("DefaultButtonBackgroud"))
                                .listRowSeparator(.hidden)
                        }.foregroundColor(.primary)

                        NavigationLink {
                            SeeComponent().environmentObject(globalModel)
                        } label: {
                            PersonMenuItem(text: "外观", imageSystemName: "gear", foregroundColor: Color("DefaultButtonBackgroud"))
                                .listRowSeparator(.hidden)
                        }.foregroundColor(.primary)
                       
                    }.padding(.horizontal,15)
                    Spacer()
                }
                .navigationBarHidden(true)
                .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
                .background(Color("ViewBackgroundColor"))
                .selfDragBack {
                    presentationMode.wrappedValue.dismiss()
                }
            }.navigationViewStyle(.stack)
            .listStyle(.plain)
            .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            
        }
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        .background(Color("ViewBackgroundColor"))
        .ignoresSafeArea()
        .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
        .selfAlter(showState: $showAlter, config: showAlterConfig)
        .selfLoading(showState: $showLoading)
    }
    
}

struct PersonMenuItem : View {
    @State var text:String
    @State var imageSystemName:String
    @State var foregroundColor:Color
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageSystemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(foregroundColor)
                .padding(10)
            Text(text)
                .font(.system(size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal,10)
        }.padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 50)
        .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 当前激活账本卡片
struct AccountBookActiveCard: View {
    let accountBook: AccountBookModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部彩色区域
            ZStack(alignment: .bottomLeading) {
                Color(hex: accountBook.bgColor.count > 0 ? accountBook.bgColor : ColorConfig.SOFT_COLORS[0])
                    .frame(height: 100)
                    .clipShape(RoundedCorner(radius: 14, corners: [.topLeft, .topRight]))
                
                Text(hexStr2Unicode(accountBook.iconStr))
                    .font(.custom("icomoon", size: 48))
                    .foregroundColor(.white)
                    .padding(16)
            }
            
            // 底部信息区域
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(accountBook.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("FontColor"))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color("DefaultButtonBackgroud"))
                        }
                        
                        if let description = accountBook.description, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(Color("MainBackgroundColor"))
            .clipShape(RoundedCorner(radius: 14, corners: [.bottomLeft, .bottomRight]))
        }
        .background(Color("MainBackgroundColor"))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("DefaultButtonBackgroud").opacity(0.2), lineWidth: 1)
        )
    }
}






// MARK: - 圆角扩展 (仅在此文件使用)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
