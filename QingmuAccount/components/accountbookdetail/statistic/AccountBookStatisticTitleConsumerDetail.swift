//
//  AccountBookStatisticTitleConsumerDetail.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2024/1/13.
//  单个类别的消费详情
//

import SwiftUI

struct AccountBookStatisticTitleConsumerDetail: View {
    @ObservedObject var showDetailData:ExpendIncomeDetailData
    @State private var itemList:[AccountBookData] = []
    @State private var totalValue:Decimal = 0
    var body: some View {
        VStack {
            HStack {
                Text("\"\(showDetailData.data!.title)\"收支详情").font(.system(size: 18,weight: .bold))
                    .foregroundColor(Color("FontColor"))
                
            }.padding(.bottom,10)
            HStack {
                Text("\(showDetailData.data!.count.description)笔")
                Spacer()
                Text("合计：\(DecimalUtils.trans2StringOfCurrency(totalValue))")
            }.font(.system(size: 16, weight: .bold))
            ScrollView(showsIndicators: false) {
                ForEach(itemList, id:\.self) { item in
                    listItemView(
                        iconStr: item.iconStr,
                        dateStr: item.dateStr,
                        percent:Decimal(Double(item.type == 0 ? ("-"+item.money) : item.money) ?? 0) / totalValue ,
                        desc: item.desc,
                        payType:item.type,
                        money: item.money)
                }
            }
        }.padding(.top, 20)
            .padding(.horizontal,20)
            .background(Color("ViewBackgroundColor"))
            .onAppear(){
                initList()
            }
            
    }
    
    
    func listItemView(iconStr:String, dateStr:String,percent:Decimal, desc:String,payType:Int,money:String) -> some View {
        VStack {
            HStack {
                Text(hexStr2Unicode(iconStr))
                    .font(.custom("icomoon", size: 25))
                    .foregroundColor( Color("DefaultButtonBackgroud"))
                    .padding(10)
                    .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading) {
                    HStack{
                        Text("\(StringUtils.subString(dateStr, start: 0, end: 4))-\(StringUtils.subString(dateStr, start: 4, end: 6))-\(StringUtils.subString(dateStr, start: 6, end: 8))")
                            .font(.system(size: 14,weight: .bold))
                        Text("\(DecimalUtils.trans2StringOfCurrency(percent * Decimal(100)))%").font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                   
                    Text(desc).font(.system(size: 12))
                }
                Spacer()
                Text("\(payType == 0 ? "-" : "")\(money)").font(.system(size: 14,weight: .bold))
            }
        }.frame(minWidth: 0,maxWidth: .infinity)
            .frame(height: 60)
            .padding(.horizontal,10)
            .background(Color("MainBackgroundColor"),in:RoundedRectangle(cornerRadius: 10))
    }
    
    
    func initList() {
        if showDetailData.data!.list.count <= 0 {
            return;
        }
        itemList = showDetailData.data!.list.sorted(by: { item1, item2 in
            item1.dateStr > item2.dateStr
        })
        var totalValueTemp = Decimal(0.0);
        for item in itemList {
            if item.type == 0 {
                totalValueTemp -= Decimal(Double(item.money) ?? 0)
            } else {
                totalValueTemp += Decimal(Double(item.money) ?? 0)
            }
        }
        self.totalValue = totalValueTemp
    }
}

struct AccountBookStatisticTitleConsumerDetail_Previews: PreviewProvider {
    
    static var previews: some View {
        var showDetailData:ExpendIncomeDetailData = ExpendIncomeDetailData(data: ExpendIncomeTitleData(title: "早餐", iconStr: "ed4b", value: 200.0, count: 1, list: [AccountBookData(version: "1.0", dateStr: "20230112", type: 0, money: "52", iconStr: "ed4b", title: "早餐", desc: "备注信息"),AccountBookData(version: "1.0", dateStr: "20230111", type: 0, money: "52", iconStr: "ed4b", title: "早餐", desc: "备注信息")]))
        
        AccountBookStatisticTitleConsumerDetail(showDetailData: showDetailData)
    }
}
