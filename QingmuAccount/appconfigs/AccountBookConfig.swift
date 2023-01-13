//
//  AccountBookConfig.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation


var AccountBookBudgetType:[Int:String] = [0:"日",1:"周",2:"月",3:"年"]

/**
 收入
 */
var defaultAccountBookInRecordIcon:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(id:"1",iconStr: IconFontEnum.icon35.rawValue, name: "工资", sort: 0),
    AccountBookSetingOfIconModel(id:"2",iconStr: IconFontEnum.icon163.rawValue, name: "理财", sort: 0),
    AccountBookSetingOfIconModel(id:"3",iconStr: IconFontEnum.icon166.rawValue, name: "兼职", sort: 0),
]

/**
 收入
 */
var defaultAccountBookOutRecordIcon:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(id:"1",iconStr: IconFontEnum.icon105.rawValue, name: "早餐", sort: 0),
    AccountBookSetingOfIconModel(id:"2",iconStr: IconFontEnum.icon161.rawValue, name: "午餐", sort: 0),
    AccountBookSetingOfIconModel(id:"3",iconStr: IconFontEnum.icon160.rawValue, name: "晚餐", sort: 0),
    AccountBookSetingOfIconModel(id:"4",iconStr: IconFontEnum.icon54.rawValue, name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(id:"5",iconStr: IconFontEnum.icon29.rawValue, name: "公交", sort: 0),
    AccountBookSetingOfIconModel(id:"6",iconStr: IconFontEnum.icon118.rawValue, name: "地铁", sort: 0),
    AccountBookSetingOfIconModel(id:"6",iconStr: IconFontEnum.icon157.rawValue, name: "高铁", sort: 0),
    AccountBookSetingOfIconModel(id:"7",iconStr: IconFontEnum.icon48.rawValue, name: "话费", sort: 0),
    AccountBookSetingOfIconModel(id:"8",iconStr: IconFontEnum.icon113.rawValue, name: "电费", sort: 0),
    AccountBookSetingOfIconModel(id:"9",iconStr: IconFontEnum.icon112.rawValue, name: "水费", sort: 0),
    AccountBookSetingOfIconModel(id:"10",iconStr: IconFontEnum.icon52.rawValue, name: "购物", sort: 0),
    AccountBookSetingOfIconModel(id:"11",iconStr: IconFontEnum.icon51.rawValue, name: "水果", sort: 0),
    AccountBookSetingOfIconModel(id:"12",iconStr: IconFontEnum.icon64.rawValue, name: "饮料", sort: 0),
    AccountBookSetingOfIconModel(id:"13",iconStr: IconFontEnum.icon66.rawValue, name: "买菜", sort: 0),
]


var iconTypeMap:[String:[AccountBookSetingOfIconModel]] = [
    "衣":yi,
    "食":shi,
    "住":zhu,
    "行":xing,
    "购":gou,
    "乐":yue,
    "医":yiliao,
    "育":yu,
    "情":qing,
    "公":gong,
    "投":tou,
    "其":qita
]




// 衣
var yi:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon25.rawValue, name: "裙子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon67.rawValue, name: "袜子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon87.rawValue, name: "鞋子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon121.rawValue, name: "服装", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon128.rawValue, name: "裤子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon164.rawValue, name: "内衣", sort: 0),
]

// 食
var shi:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon51.rawValue, name: "水果", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon54.rawValue, name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon57.rawValue, name: "零食", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon64.rawValue, name: "饮料", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon65.rawValue, name: "肉类", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon66.rawValue, name: "蔬菜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon69.rawValue, name: "烧烤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon11.rawValue, name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon105.rawValue, name: "早餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon161.rawValue, name: "午餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon160.rawValue, name: "晚餐", sort: 0),
]

// 住
var zhu:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon42.rawValue, name: "酒店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon149.rawValue, name: "酒店1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon9.rawValue, name: "酒店2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon50.rawValue, name: "房租", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon74.rawValue, name: "家具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon86.rawValue, name: "家电", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon109.rawValue, name: "装修", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon117.rawValue, name: "装修1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon8.rawValue, name: "装修2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon12.rawValue, name: "装修3", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon112.rawValue, name: "水费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon113.rawValue, name: "电费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon76.rawValue, name: "宽带", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon127.rawValue, name: "住房贷款", sort: 0),
    
]
// 行
var xing:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon29.rawValue, name: "公交", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon97.rawValue, name: "公交1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon53.rawValue, name: "租车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon60.rawValue, name: "打车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon75.rawValue, name: "自行车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon119.rawValue, name: "电瓶车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon81.rawValue, name: "汽车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon85.rawValue, name: "加油", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon106.rawValue, name: "停车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon118.rawValue, name: "轻轨", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon142.rawValue, name: "铁路", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon151.rawValue, name: "汽车保养", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon156.rawValue, name: "飞机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon157.rawValue, name: "火车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon159.rawValue, name: "轮船", sort: 0),
    
]
// 购
var gou:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon26.rawValue, name: "洗护", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon111.rawValue, name: "洗护1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon116.rawValue, name: "洗护2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon31.rawValue, name: "超市", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon49.rawValue, name: "淘宝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon52.rawValue, name: "购物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon62.rawValue, name: "纸巾", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon63.rawValue, name: "牙膏牙刷", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon82.rawValue, name: "快递", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon98.rawValue, name: "快递1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon93.rawValue, name: "电商", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon122.rawValue, name: "拼多多", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon150.rawValue, name: "京东", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon153.rawValue, name: "天猫", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon143.rawValue, name: "数码产品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon165.rawValue, name: "数码相机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon152.rawValue, name: "化妆品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon155.rawValue, name: "购物车", sort: 0),
    
]
// 乐
var yue:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon37.rawValue, name: "娱乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon55.rawValue, name: "门票", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon80.rawValue, name: "KTV", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon90.rawValue, name: "叶子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon101.rawValue, name: "电影", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon144.rawValue, name: "游戏", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon146.rawValue, name: "音乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon148.rawValue, name: "文化娱乐", sort: 0),
   
    
]
// 医
var yiliao:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon59.rawValue, name: "药品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon123.rawValue, name: "药品1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon132.rawValue, name: "药品2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon83.rawValue, name: "救护车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon84.rawValue, name: "医生", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon88.rawValue, name: "注射", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon131.rawValue, name: "药店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon16.rawValue, name: "医疗", sort: 0),
]
// 育
var yu:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon43.rawValue, name: "书本", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon61.rawValue, name: "教育", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon158.rawValue, name: "健身", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon7.rawValue, name: "教育1", sort: 0),
]
// 情
var qing:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon34.rawValue, name: "请客", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon58.rawValue, name: "生日", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon68.rawValue, name: "旅行", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon3.rawValue, name: "旅行1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon89.rawValue, name: "赠品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon96.rawValue, name: "盆栽", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon100.rawValue, name: "爱情", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon154.rawValue, name: "爱情1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon13.rawValue, name: "婚礼", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon14.rawValue, name: "婚礼1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon102.rawValue, name: "红包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon147.rawValue, name: "红包1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon103.rawValue, name: "会员", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon145.rawValue, name: "礼物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon5.rawValue, name: "宠物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon23.rawValue, name: "宠物1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon6.rawValue, name: "招待", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon17.rawValue, name: "宝宝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon19.rawValue, name: "宝宝1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon24.rawValue, name: "丧", sort: 0),
   
]
// 公
var gong:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon38.rawValue, name: "赔付", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon45.rawValue, name: "赔偿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon79.rawValue, name: "理赔", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon40.rawValue, name: "钱包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon41.rawValue, name: "捐赠", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon124.rawValue, name: "公益", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon126.rawValue, name: "救助", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon47.rawValue, name: "办公", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon48.rawValue, name: "话费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon56.rawValue, name: "文具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon78.rawValue, name: "文具1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon107.rawValue, name: "文具2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon71.rawValue, name: "维修", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon104.rawValue, name: "处罚", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon108.rawValue, name: "办证", sort: 0),
    
    
]
// 投
var tou:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon30.rawValue, name: "储蓄", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon32.rawValue, name: "经营", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon10.rawValue, name: "金钱", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon33.rawValue, name: "买车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon36.rawValue, name: "理财", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon21.rawValue, name: "理财1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon15.rawValue, name: "理财2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon22.rawValue, name: "理财3", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon35.rawValue, name: "工资", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon46.rawValue, name: "保险", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon125.rawValue, name: "保险1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon73.rawValue, name: "五险一金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon114.rawValue, name: "意外险", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon115.rawValue, name: "车险", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon133.rawValue, name: "投资", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon134.rawValue, name: "基金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon135.rawValue, name: "股票", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon136.rawValue, name: "押金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon137.rawValue, name: "黄金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon138.rawValue, name: "储蓄罐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon20.rawValue, name: "金钱", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon140.rawValue, name: "比特币", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon141.rawValue, name: "银行", sort: 0),
]
// 其
var qita:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon166.rawValue, name: "兼职", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon27.rawValue, name: "信用卡", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon28.rawValue, name: "活动", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon72.rawValue, name: "服务", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon162.rawValue, name: "服务1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon163.rawValue, name: "服务2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon2.rawValue, name: "人脉", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon4.rawValue, name: "聚会", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon91.rawValue, name: "服务中心", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon92.rawValue, name: "服务费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon39.rawValue, name: "充电", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon44.rawValue, name: "扇子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon70.rawValue, name: "玩具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon77.rawValue, name: "损坏", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon94.rawValue, name: "收入", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon95.rawValue, name: "补贴", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon99.rawValue, name: "其它收入", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon110.rawValue, name: "其它", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon120.rawValue, name: "其它1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon130.rawValue, name: "其它2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon129.rawValue, name: "篮子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon1.rawValue, name: "阳光", sort: 0),
]
