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
    AccountBookSetingOfIconModel(id:"1",iconStr: IconFontEnum.icon159.rawValue, name: "工资", sort: 0),
    AccountBookSetingOfIconModel(id:"2",iconStr: IconFontEnum.icon156.rawValue, name: "理财", sort: 0),
    AccountBookSetingOfIconModel(id:"3",iconStr: IconFontEnum.icon167.rawValue, name: "兼职", sort: 0),
]

/**
 收入
 */
var defaultAccountBookOutRecordIcon:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(id:"1",iconStr: IconFontEnum.icon56.rawValue, name: "早餐", sort: 0),
    AccountBookSetingOfIconModel(id:"2",iconStr: IconFontEnum.icon57.rawValue, name: "午餐", sort: 0),
    AccountBookSetingOfIconModel(id:"3",iconStr: IconFontEnum.icon58.rawValue, name: "晚餐", sort: 0),
    AccountBookSetingOfIconModel(id:"4",iconStr: IconFontEnum.icon45.rawValue, name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(id:"5",iconStr: IconFontEnum.icon70.rawValue, name: "公交", sort: 0),
    AccountBookSetingOfIconModel(id:"6",iconStr: IconFontEnum.icon77.rawValue, name: "地铁", sort: 0),
    AccountBookSetingOfIconModel(id:"6",iconStr: IconFontEnum.icon84.rawValue, name: "高铁", sort: 0),
    AccountBookSetingOfIconModel(id:"7",iconStr: IconFontEnum.icon126.rawValue, name: "话费", sort: 0),
    AccountBookSetingOfIconModel(id:"8",iconStr: IconFontEnum.icon66.rawValue, name: "电费", sort: 0),
    AccountBookSetingOfIconModel(id:"9",iconStr: IconFontEnum.icon65.rawValue, name: "水费", sort: 0),
    AccountBookSetingOfIconModel(id:"10",iconStr: IconFontEnum.icon89.rawValue, name: "购物", sort: 0),
    AccountBookSetingOfIconModel(id:"11",iconStr: IconFontEnum.icon41.rawValue, name: "水果", sort: 0),
    AccountBookSetingOfIconModel(id:"12",iconStr: IconFontEnum.icon43.rawValue, name: "饮料", sort: 0),
    AccountBookSetingOfIconModel(id:"13",iconStr: IconFontEnum.icon209.rawValue, name: "买菜", sort: 0),
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
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon25.rawValue, name: "衣服", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon26.rawValue, name: "圆领衫", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon27.rawValue, name: "内裤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon28.rawValue, name: "短裤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon29.rawValue, name: "长裤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon30.rawValue, name: "裙子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon31.rawValue, name: "眼镜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon32.rawValue, name: "帽子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon33.rawValue, name: "领带", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon34.rawValue, name: "短裙", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon35.rawValue, name: "背包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon36.rawValue, name: "袜子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon37.rawValue, name: "内衣", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon38.rawValue, name: "鞋子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon39.rawValue, name: "高跟鞋", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon40.rawValue, name: "拖鞋", sort: 0),
]

// 食
var shi:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon41.rawValue, name: "水果", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon42.rawValue, name: "饮料2", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon43.rawValue, name: "饮料", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon44.rawValue, name: "零食", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon45.rawValue, name: "餐饮", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon46.rawValue, name: "肉类", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon47.rawValue, name: "海鲜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon48.rawValue, name: "蔬菜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon49.rawValue, name: "烧烤", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon50.rawValue, name: "蛋糕", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon51.rawValue, name: "蛋制品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon52.rawValue, name: "配料", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon53.rawValue, name: "酒水", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon54.rawValue, name: "牛奶", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon55.rawValue, name: "茶", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon56.rawValue, name: "早餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon57.rawValue, name: "午餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon58.rawValue, name: "晚餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon59.rawValue, name: "小吃", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon60.rawValue, name: "冰棍", sort: 0),
]

// 住
var zhu:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon61.rawValue, name: "酒店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon62.rawValue, name: "房租", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon63.rawValue, name: "家具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon64.rawValue, name: "家电", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon11.rawValue, name: "装修", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon65.rawValue, name: "水费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon66.rawValue, name: "电费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon67.rawValue, name: "网络", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon68.rawValue, name: "房贷", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon69.rawValue, name: "房租", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon126.rawValue, name: "话费", sort: 0),
    
]
// 行
var xing:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon70.rawValue, name: "公交", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon18.rawValue, name: "汽车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon71.rawValue, name: "飞机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon72.rawValue, name: "轻轨", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon73.rawValue, name: "轮船", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon74.rawValue, name: "大巴车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon75.rawValue, name: "托运", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon76.rawValue, name: "出租车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon77.rawValue, name: "地铁", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon78.rawValue, name: "洗车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon79.rawValue, name: "维修保养", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon80.rawValue, name: "停车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon81.rawValue, name: "油费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon82.rawValue, name: "自行车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon83.rawValue, name: "电瓶车", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon84.rawValue, name: "高铁", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon85.rawValue, name: "过路费", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon86.rawValue, name: "充电费", sort: 0),
    
]
// 购
var gou:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon87.rawValue, name: "超市", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon88.rawValue, name: "摊位", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon89.rawValue, name: "购物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon90.rawValue, name: "拼多多", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon91.rawValue, name: "淘宝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon92.rawValue, name: "京东", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon93.rawValue, name: "天猫", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon94.rawValue, name: "美团", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon95.rawValue, name: "饿了么", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon96.rawValue, name: "抖音", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon97.rawValue, name: "快手", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon98.rawValue, name: "每日优鲜", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon99.rawValue, name: "生活用品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon100.rawValue, name: "快递", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon101.rawValue, name: "电子设备", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon102.rawValue, name: "化妆品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon103.rawValue, name: "洗护用品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon209.rawValue, name: "买菜", sort: 0),
]
// 乐
var yue:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon104.rawValue, name: "音乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon105.rawValue, name: "文化娱乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon106.rawValue, name: "电影", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon107.rawValue, name: "游戏", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon108.rawValue, name: "KTV", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon109.rawValue, name: "票券", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon110.rawValue, name: "旅行", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon111.rawValue, name: "娱乐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon112.rawValue, name: "摄影", sort: 0),
]
// 医
var yiliao:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon113.rawValue, name: "医疗", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon114.rawValue, name: "药品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon115.rawValue, name: "注射", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon116.rawValue, name: "药丸", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon117.rawValue, name: "医生", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon6.rawValue, name: "医院", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon118.rawValue, name: "药店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon119.rawValue, name: "治疗", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon120.rawValue, name: "死亡", sort: 0),
]
// 育
var yu:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon121.rawValue, name: "学前教育", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon122.rawValue, name: "书籍", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon123.rawValue, name: "学校", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon3.rawValue, name: "教育", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon124.rawValue, name: "健身", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon125.rawValue, name: "自我提升", sort: 0),
]
// 情
var qing:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon127.rawValue, name: "生日", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon128.rawValue, name: "请客", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon129.rawValue, name: "礼物", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon130.rawValue, name: "红包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon131.rawValue, name: "红包1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon132.rawValue, name: "聚餐", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon133.rawValue, name: "喜酒", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon134.rawValue, name: "婚宴", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon135.rawValue, name: "婚纱", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon136.rawValue, name: "婚礼", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon137.rawValue, name: "婚礼1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon138.rawValue, name: "鲜花", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon139.rawValue, name: "丧礼", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon140.rawValue, name: "盆栽", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon141.rawValue, name: "会员", sort: 0),
]
// 公
var gong:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon142.rawValue, name: "赔付", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon143.rawValue, name: "赔偿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon144.rawValue, name: "钱包", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon145.rawValue, name: "公益", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon146.rawValue, name: "爱心", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon147.rawValue, name: "文具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon148.rawValue, name: "办公", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon149.rawValue, name: "维修", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon150.rawValue, name: "维修1", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon151.rawValue, name: "办证", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon152.rawValue, name: "处罚", sort: 0),
]
// 投
var tou:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon153.rawValue, name: "存款", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon154.rawValue, name: "经营", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon155.rawValue, name: "货币", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon156.rawValue, name: "理财", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon157.rawValue, name: "基金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon158.rawValue, name: "黄金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon159.rawValue, name: "工资", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon160.rawValue, name: "保险", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon161.rawValue, name: "奖金", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon162.rawValue, name: "收益", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon163.rawValue, name: "股票", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon164.rawValue, name: "珠宝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon165.rawValue, name: "首饰", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon166.rawValue, name: "比特币", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon203.rawValue, name: "兑换", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon205.rawValue, name: "转入", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon206.rawValue, name: "转出", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon207.rawValue, name: "收入", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon208.rawValue, name: "支出", sort: 0),
    
    
]
// 其
var qita:[AccountBookSetingOfIconModel] = [
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon1.rawValue, name: "阳光", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon167.rawValue, name: "兼职", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon9.rawValue, name: "骨头", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon168.rawValue, name: "狗粮", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon169.rawValue, name: "鸡尾酒", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon170.rawValue, name: "风景", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon171.rawValue, name: "名宿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon172.rawValue, name: "勋章", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon173.rawValue, name: "头盔", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon174.rawValue, name: "证件", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon175.rawValue, name: "计算", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon176.rawValue, name: "充电", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon177.rawValue, name: "交易", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon178.rawValue, name: "粉丝", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon179.rawValue, name: "旗子", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon180.rawValue, name: "监控", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon181.rawValue, name: "其它", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon182.rawValue, name: "菜单", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon183.rawValue, name: "耳机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon184.rawValue, name: "服务", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon185.rawValue, name: "房价", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon186.rawValue, name: "美发", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon187.rawValue, name: "婴儿玩具", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon188.rawValue, name: "婴儿用品", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon189.rawValue, name: "尿片", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon190.rawValue, name: "奶粉", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon191.rawValue, name: "应用商店", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon192.rawValue, name: "微信", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon194.rawValue, name: "回收", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon195.rawValue, name: "正方体", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon196.rawValue, name: "插头", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon197.rawValue, name: "硬盘", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon198.rawValue, name: "云盘", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon199.rawValue, name: "电脑", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon200.rawValue, name: "手机", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon201.rawValue, name: "平板", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon202.rawValue, name: "打印", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon204.rawValue, name: "文稿", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon210.rawValue, name: "隐私", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon211.rawValue, name: "手表", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon212.rawValue, name: "香水", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon213.rawValue, name: "剃须刀", sort: 0),
    AccountBookSetingOfIconModel(iconStr: IconFontEnum.icon214.rawValue, name: "美甲", sort: 0),
    
    
]
