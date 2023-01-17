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
    AccountBookSetingOfIconModel(id:"1",iconStr: IconFontEnum.icon159.getUnicodeValue(), name: "工资", sort: 0),
    AccountBookSetingOfIconModel(id:"2",iconStr: IconFontEnum.icon156.getUnicodeValue(), name: "理财", sort: 0),
    AccountBookSetingOfIconModel(id:"3",iconStr: IconFontEnum.icon167.getUnicodeValue(), name: "兼职", sort: 0),
]

/**
 收入
 */
var defaultAccountBookOutRecordIcon:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(id:"1",iconStr: IconFontEnum.icon56.getUnicodeValue(), name: "早餐", sort: 0),
    AccountBookSetingOfIconModel(id:"2",iconStr: IconFontEnum.icon57.getUnicodeValue(), name: "午餐", sort: 0),
    AccountBookSetingOfIconModel(id:"3",iconStr: IconFontEnum.icon58.getUnicodeValue(), name: "晚餐", sort: 0),
    AccountBookSetingOfIconModel(id:"4",iconStr: IconFontEnum.icon45.getUnicodeValue(), name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(id:"5",iconStr: IconFontEnum.icon70.getUnicodeValue(), name: "公交", sort: 0),
    AccountBookSetingOfIconModel(id:"6",iconStr: IconFontEnum.icon77.getUnicodeValue(), name: "地铁", sort: 0),
    AccountBookSetingOfIconModel(id:"6",iconStr: IconFontEnum.icon84.getUnicodeValue(), name: "高铁", sort: 0),
    AccountBookSetingOfIconModel(id:"7",iconStr: IconFontEnum.icon126.getUnicodeValue(), name: "话费", sort: 0),
    AccountBookSetingOfIconModel(id:"8",iconStr: IconFontEnum.icon66.getUnicodeValue(), name: "电费", sort: 0),
    AccountBookSetingOfIconModel(id:"9",iconStr: IconFontEnum.icon65.getUnicodeValue(), name: "水费", sort: 0),
    AccountBookSetingOfIconModel(id:"10",iconStr: IconFontEnum.icon89.getUnicodeValue(), name: "购物", sort: 0),
    AccountBookSetingOfIconModel(id:"11",iconStr: IconFontEnum.icon41.getUnicodeValue(), name: "水果", sort: 0),
    AccountBookSetingOfIconModel(id:"12",iconStr: IconFontEnum.icon43.getUnicodeValue(), name: "饮料", sort: 0),
    AccountBookSetingOfIconModel(id:"13",iconStr: IconFontEnum.icon209.getUnicodeValue(), name: "买菜", sort: 0),
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
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon25.getUnicodeValue(), name: "衣服", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon26.getUnicodeValue(), name: "圆领衫", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon27.getUnicodeValue(), name: "内裤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon28.getUnicodeValue(), name: "短裤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon29.getUnicodeValue(), name: "长裤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon30.getUnicodeValue(), name: "裙子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon31.getUnicodeValue(), name: "眼镜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon32.getUnicodeValue(), name: "帽子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon33.getUnicodeValue(), name: "领带", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon34.getUnicodeValue(), name: "短裙", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon35.getUnicodeValue(), name: "背包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon36.getUnicodeValue(), name: "袜子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon37.getUnicodeValue(), name: "内衣", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon38.getUnicodeValue(), name: "鞋子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon39.getUnicodeValue(), name: "高跟鞋", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon40.getUnicodeValue(), name: "拖鞋", sort: 0),
]

// 食
var shi:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon41.getUnicodeValue(), name: "水果", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon42.getUnicodeValue(), name: "饮料2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon43.getUnicodeValue(), name: "饮料", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon44.getUnicodeValue(), name: "零食", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon45.getUnicodeValue(), name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon46.getUnicodeValue(), name: "肉类", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon47.getUnicodeValue(), name: "海鲜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon48.getUnicodeValue(), name: "蔬菜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon49.getUnicodeValue(), name: "烧烤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon50.getUnicodeValue(), name: "蛋糕", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon51.getUnicodeValue(), name: "蛋制品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon52.getUnicodeValue(), name: "配料", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon53.getUnicodeValue(), name: "酒水", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon54.getUnicodeValue(), name: "牛奶", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon55.getUnicodeValue(), name: "茶", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon56.getUnicodeValue(), name: "早餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon57.getUnicodeValue(), name: "午餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon58.getUnicodeValue(), name: "晚餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon59.getUnicodeValue(), name: "小吃", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon60.getUnicodeValue(), name: "冰棍", sort: 0),
]

// 住
var zhu:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon61.getUnicodeValue(), name: "酒店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon62.getUnicodeValue(), name: "房租", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon63.getUnicodeValue(), name: "家具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon64.getUnicodeValue(), name: "家电", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon11.getUnicodeValue(), name: "装修", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon65.getUnicodeValue(), name: "水费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon66.getUnicodeValue(), name: "电费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon67.getUnicodeValue(), name: "网络", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon68.getUnicodeValue(), name: "房贷", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon69.getUnicodeValue(), name: "房租", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon126.getUnicodeValue(), name: "话费", sort: 0),
    
]
// 行
var xing:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon70.getUnicodeValue(), name: "公交", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon18.getUnicodeValue(), name: "汽车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon71.getUnicodeValue(), name: "飞机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon72.getUnicodeValue(), name: "轻轨", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon73.getUnicodeValue(), name: "轮船", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon74.getUnicodeValue(), name: "大巴车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon75.getUnicodeValue(), name: "托运", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon76.getUnicodeValue(), name: "出租车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon77.getUnicodeValue(), name: "地铁", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon78.getUnicodeValue(), name: "洗车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon79.getUnicodeValue(), name: "维修保养", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon80.getUnicodeValue(), name: "停车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon81.getUnicodeValue(), name: "油费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon82.getUnicodeValue(), name: "自行车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon83.getUnicodeValue(), name: "电瓶车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon84.getUnicodeValue(), name: "高铁", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon85.getUnicodeValue(), name: "过路费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon86.getUnicodeValue(), name: "充电费", sort: 0),
    
]
// 购
var gou:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon87.getUnicodeValue(), name: "超市", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon88.getUnicodeValue(), name: "摊位", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon89.getUnicodeValue(), name: "购物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon90.getUnicodeValue(), name: "拼多多", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon91.getUnicodeValue(), name: "淘宝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon92.getUnicodeValue(), name: "京东", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon93.getUnicodeValue(), name: "天猫", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon94.getUnicodeValue(), name: "美团", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon95.getUnicodeValue(), name: "饿了么", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon96.getUnicodeValue(), name: "抖音", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon97.getUnicodeValue(), name: "快手", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon98.getUnicodeValue(), name: "每日优鲜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon99.getUnicodeValue(), name: "生活用品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon100.getUnicodeValue(), name: "快递", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon101.getUnicodeValue(), name: "电子设备", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon102.getUnicodeValue(), name: "化妆品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon103.getUnicodeValue(), name: "洗护用品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon209.getUnicodeValue(), name: "买菜", sort: 0),
]
// 乐
var yue:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon104.getUnicodeValue(), name: "音乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon105.getUnicodeValue(), name: "文化娱乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon106.getUnicodeValue(), name: "电影", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon107.getUnicodeValue(), name: "游戏", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon108.getUnicodeValue(), name: "KTV", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon109.getUnicodeValue(), name: "票券", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon110.getUnicodeValue(), name: "旅行", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon111.getUnicodeValue(), name: "娱乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon112.getUnicodeValue(), name: "摄影", sort: 0),
]
// 医
var yiliao:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon113.getUnicodeValue(), name: "医疗", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon114.getUnicodeValue(), name: "药品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon115.getUnicodeValue(), name: "注射", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon116.getUnicodeValue(), name: "药丸", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon117.getUnicodeValue(), name: "医生", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon6.getUnicodeValue(), name: "医院", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon118.getUnicodeValue(), name: "药店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon119.getUnicodeValue(), name: "治疗", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon120.getUnicodeValue(), name: "死亡", sort: 0),
]
// 育
var yu:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon121.getUnicodeValue(), name: "学前教育", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon122.getUnicodeValue(), name: "书籍", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon123.getUnicodeValue(), name: "学校", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon3.getUnicodeValue(), name: "教育", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon124.getUnicodeValue(), name: "健身", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon125.getUnicodeValue(), name: "自我提升", sort: 0),
]
// 情
var qing:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon127.getUnicodeValue(), name: "生日", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon128.getUnicodeValue(), name: "请客", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon129.getUnicodeValue(), name: "礼物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon130.getUnicodeValue(), name: "红包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon131.getUnicodeValue(), name: "红包1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon132.getUnicodeValue(), name: "聚餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon133.getUnicodeValue(), name: "喜酒", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon134.getUnicodeValue(), name: "婚宴", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon135.getUnicodeValue(), name: "婚纱", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon136.getUnicodeValue(), name: "婚礼", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon137.getUnicodeValue(), name: "婚礼1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon138.getUnicodeValue(), name: "鲜花", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon139.getUnicodeValue(), name: "丧礼", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon140.getUnicodeValue(), name: "盆栽", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon141.getUnicodeValue(), name: "会员", sort: 0),
]
// 公
var gong:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon142.getUnicodeValue(), name: "赔付", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon143.getUnicodeValue(), name: "赔偿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon144.getUnicodeValue(), name: "钱包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon145.getUnicodeValue(), name: "公益", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon146.getUnicodeValue(), name: "爱心", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon147.getUnicodeValue(), name: "文具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon148.getUnicodeValue(), name: "办公", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon149.getUnicodeValue(), name: "维修", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon150.getUnicodeValue(), name: "维修1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon151.getUnicodeValue(), name: "办证", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon152.getUnicodeValue(), name: "处罚", sort: 0),
]
// 投
var tou:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon153.getUnicodeValue(), name: "存款", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon154.getUnicodeValue(), name: "经营", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon155.getUnicodeValue(), name: "货币", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon156.getUnicodeValue(), name: "理财", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon157.getUnicodeValue(), name: "基金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon158.getUnicodeValue(), name: "黄金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon159.getUnicodeValue(), name: "工资", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon160.getUnicodeValue(), name: "保险", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon161.getUnicodeValue(), name: "奖金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon162.getUnicodeValue(), name: "收益", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon163.getUnicodeValue(), name: "股票", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon164.getUnicodeValue(), name: "珠宝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon165.getUnicodeValue(), name: "首饰", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon166.getUnicodeValue(), name: "比特币", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon203.getUnicodeValue(), name: "兑换", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon205.getUnicodeValue(), name: "转入", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon206.getUnicodeValue(), name: "转出", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon207.getUnicodeValue(), name: "收入", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon208.getUnicodeValue(), name: "支出", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon215.getUnicodeValue(), name: "信用卡", sort: 0),
    
    
]
// 其
var qita:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon1.getUnicodeValue(), name: "阳光", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon167.getUnicodeValue(), name: "兼职", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon9.getUnicodeValue(), name: "骨头", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon168.getUnicodeValue(), name: "狗粮", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon169.getUnicodeValue(), name: "鸡尾酒", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon170.getUnicodeValue(), name: "风景", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon171.getUnicodeValue(), name: "名宿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon172.getUnicodeValue(), name: "勋章", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon173.getUnicodeValue(), name: "头盔", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon174.getUnicodeValue(), name: "证件", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon175.getUnicodeValue(), name: "计算", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon176.getUnicodeValue(), name: "充电", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon177.getUnicodeValue(), name: "交易", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon178.getUnicodeValue(), name: "粉丝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon179.getUnicodeValue(), name: "旗子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon180.getUnicodeValue(), name: "监控", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon181.getUnicodeValue(), name: "其它", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon182.getUnicodeValue(), name: "菜单", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon183.getUnicodeValue(), name: "耳机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon184.getUnicodeValue(), name: "服务", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon185.getUnicodeValue(), name: "房价", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon186.getUnicodeValue(), name: "美发", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon187.getUnicodeValue(), name: "婴儿玩具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon188.getUnicodeValue(), name: "婴儿用品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon189.getUnicodeValue(), name: "尿片", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon190.getUnicodeValue(), name: "奶粉", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon191.getUnicodeValue(), name: "应用商店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon192.getUnicodeValue(), name: "微信", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon194.getUnicodeValue(), name: "回收", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon195.getUnicodeValue(), name: "正方体", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon196.getUnicodeValue(), name: "插头", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon197.getUnicodeValue(), name: "硬盘", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon198.getUnicodeValue(), name: "云盘", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon199.getUnicodeValue(), name: "电脑", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon200.getUnicodeValue(), name: "手机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon201.getUnicodeValue(), name: "平板", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon202.getUnicodeValue(), name: "打印", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon204.getUnicodeValue(), name: "文稿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon210.getUnicodeValue(), name: "隐私", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon211.getUnicodeValue(), name: "手表", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon212.getUnicodeValue(), name: "香水", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon213.getUnicodeValue(), name: "剃须刀", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon214.getUnicodeValue(), name: "美甲", sort: 0),
    
    
]
