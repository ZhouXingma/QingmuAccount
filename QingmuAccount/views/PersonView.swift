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
    @State var showAlterConfig:AlertComponentConfig = AlertComponentConfig()
    @State var showLoading:Bool = false
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    DefaultTopBarComponent {
                        presentationMode.wrappedValue.dismiss()
                    }
                    if nil != globalModel.accountBook {
                        VStack(alignment: .center, spacing: 8.0) {
                            VStack {
                                Text(globalModel.accountBook!.iconStr).font(.custom("icomoon", size: 30))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(globalModel.accountBook!.bgColor.count<=0 ? Color("DefaultButtonBackgroud") : Color(hex: globalModel.accountBook!.bgColor), in: RoundedRectangle(cornerRadius: 10))
                                Text(globalModel.accountBook!.name).font(.system(size: 14,weight: .bold))
                            }.frame(minWidth: 0,maxWidth: .infinity)
                                .frame(height: 80)
                                .padding(.vertical,20)
                                .background(Color("MainBackgroundColor"), in:RoundedRectangle(cornerRadius: 10))
                        }.padding(.horizontal,15)
                            .padding(.vertical,10)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                    VStack {
                        NavigationLink {
                            AccountBookSettingComponent().environmentObject(globalModel)
                        } label: {
                            PersonMenuItem(text: "账本", imageSystemName: "book", foregroundColor: Color("DefaultButtonBackgroud"))
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





