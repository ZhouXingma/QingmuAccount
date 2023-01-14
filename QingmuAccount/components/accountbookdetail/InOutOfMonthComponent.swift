//
//  InOutOfMonthComponent.swift
//  QingmuAccount - 每月收支情况
//
//  Created by 周荥马 on 2022/12/1.
//

import SwiftUI
struct InOutOfMonthComponent : View {
    /**
    月份
     */
    @Binding var year:Int
    /**
    月份
     */
    @Binding var month:Int
    /**
     支出
     */
    @Binding var outTotal:Decimal
    /**
     收入
     */
    @Binding var inTotal:Decimal
    /**
     重新选择时间
     */
    @State var changeTime: ()-> Void = {}
    /**
     显示统计
     */
    @Binding var showStatistics:Bool
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    VStack {
                        HStack {
                            Text("\(month)月收支：").font(.system(size: 14,weight: .bold))
                            Spacer()
                        }
                        HStack {
                            Text("\(String(year))").font(.system(size: 12,weight: .bold))
                            Spacer()
                        }
                    }.frame(width: 100,height: 30)
                        .onTapGesture {
                            changeTime()
                        }
                    Spacer()
                    VStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 16))
                            .onTapGesture {
                                showStatistics = true
                            }
                        Spacer()
                    }.frame(height: 30)
                }.frame(height: 30)
                Spacer()
                HStack {
                    Text("\(computerBalance())").font(.system(size: 30,weight: .bold))
                }
                Spacer()
                HStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("支出").font(.system(size: 13))
                            Text("\(DecimalUtils.trans2StringOfCurrency(outTotal))").font(.system(size: 16,weight: .bold))
                        }
                        Spacer()
                    }
                    Spacer()
                    Text("|").font(.system(size: 20))
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("收入")
                                .font(.system(size: 13))
                            Text("\(DecimalUtils.trans2StringOfCurrency(inTotal))").font(.system(size: 16,weight: .bold))
                            
                        }
                    }
                    
                }
               
            }
        }.padding(10)
        .foregroundColor(.white)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 180)
        .background(Color("DefaultButtonBackgroud"), in: RoundedRectangle(cornerRadius: 10))
        
        
    }
    
    /**
     计算总预算
     */
    func computerBalance() -> String {
        return DecimalUtils.trans2StringOfCurrency(inTotal - outTotal)
    }
}
