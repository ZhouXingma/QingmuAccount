//
//  iconfontEnum.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/28.
//

import Foundation
import SwiftUI
import UIKit


public enum IconFontEnum:String,Encodable,Decodable,CaseIterable  {
    // icon-sun-one
    case icon1 = "\u{e90b}"
    // icon-peoples-two
    case icon2 = "\u{e9b9}"
    // icon-degree-hat
    case icon3 = "\u{e9f9}"
    // icon-finance
    case icon4 = "\u{eb4a}"
    // icon-like
    case icon5 = "\u{f0e5}"
    // icon-hospital
    case icon6 = "\u{ebc9}"
    // icon-baby
    case icon7 = "\u{e99b}"
    // icon-outdoor
    case icon8 = "\u{ea34}"
    // icon-dog_pet_bone_dog-toy_icon
    case icon9 = "\u{e904}"
    // icon-black_cat_halloween_witch_icon
    case icon10 = "\u{e93f}"
    // icon-format-brush
    case icon11 = "\u{ede7}"
    // icon-fork-spoon
    case icon12 = "\u{ed19}"
    // icon-gift
    case icon13 = "\u{f0d7}"
    // icon-banana
    case icon14 = "\u{ecea}"
    // icon-book-one
    case icon15 = "\u{f05f}"
    // icon-application-two
    case icon16 = "\u{ed98}"
    // icon-boy-stroller
    case icon17 = "\u{ef4b}"
    // icon-car
    case icon18 = "\u{ebf4}"
    // icon-buy
    case icon19 = "\u{e9e6}"
    // icon-game-handle
    case icon20 = "\u{ea0b}"
    // icon-local
    case icon21 = "\u{ea23}"
    // icon-exchange-three
    case icon22 = "\u{eb45}"
    // icon-treadmill
    case icon23 = "\u{e98f}"
    // icon-tool
    case icon24 = "\u{f13c}"
    
    // 衣
    // icon-clothes-cardigan
    case icon25 = "\u{ef08}"
    // icon-clothes-crew-neck
    case icon26 = "\u{ef09}"
    // icon-clothes-diapers
    case icon27 = "\u{ef0a}"
    // icon-clothes-pants-short
    case icon28 = "\u{ef0e}"
    // icon-clothes-pants
    case icon29 = "\u{ef10}"
    // icon-full-dress-longuette
    case icon30 = "\u{ef1e}"
    // icon-glasses-one
    case icon31 = "\u{ef1f}"
    // icon-hat
    case icon32 = "\u{ef23}"
    // icon-necktie
    case icon33 = "\u{ef29}"
    // icon-short-skirt
    case icon34 = "\u{ef2d}"
    // icon-retro-bag
    case icon35 = "\u{ef2c}"
    // icon-socks
    case icon36 = "\u{ef32}"
    // icon-swimsuit
    case icon37 = "\u{ef37}"
    // icon-skates
    case icon38 = "\u{ef2f}"
    // icon-high-heeled-shoes
    case icon39 = "\u{ef25}"
    // icon-slippers-one
    case icon40 = "\u{ef30}"
    
    // 食
    // icon-peach
    case icon41 = "\u{ed3e}"
    // icon-cola
    case icon42 = "\u{ed0b}"
    // icon-drink
    case icon43 = "\u{ed13}"
    // icon-candy
    case icon44 = "\u{ecfe}"
    // icon-chopsticks-fork
    case icon45 = "\u{ed0a}"
    // icon-chicken-leg
    case icon46 = "\u{ed06}"
    // icon-crab
    case icon47 = "\u{ed0e}"
    // icon-broccoli_brocoli_brocolli_icon
    case icon48 = "\u{e92e}"
    // con-barbecue
    case icon49 = "\u{eceb}"
    // icon-cake-three
    case icon50 = "\u{ecfb}"
    // icon-egg-one
    case icon51 = "\u{ed15}"
    // icon-garlic
    case icon52 = "\u{ed1b}"
    // icon-goblet-full
    case icon53 = "\u{ed1e}"
    // icon-milk-one
    case icon54 = "\u{ed35}"
    // icon-tea
    case icon55 = "\u{ed53}"
    // icon-sandwich
    case icon56 = "\u{ed4b}"
    // icon-noodles
    case icon57 = "\u{ed37}"
    // icon-hot-pot
    case icon58 = "\u{ed25}"
    // icon-french-fries
    case icon59 = "\u{ed1a}"
    // icon-icecream-three
    case icon60 = "\u{ed29}"
    
    // 住
    // icon-hotel
    case icon61 = "\u{eff1}"
    // icon-home-two
    case icon62 = "\u{efef}"
    // icon-sofa
    case icon63 = "\u{ea59}"
    // icon-air-conditioning
    case icon64 = "\u{ebe7}"
    // icon-water-rate
    case icon65 = "\u{ea7a}"
    // icon-lightning
    case icon66 = "\u{f0e4}"
    // icon-wifi
    case icon67 = "\u{ea87}"
    // icon-icon_fangdai
    case icon68 = "\u{e955}"
    // icon-icon_fangzu
    case icon69 = "\u{e964}"
    // icon-bank_bitcoin_cryptocurrency_fintec
    case icon126 = "\u{e9b7}"
    
    // 行
    // icon-bus-two
    case icon70 = "\u{e9e5}"
    // icon-acceleration
    case icon71 = "\u{e910}"
    // icon-train_railway_railroad_locomotive_i
    case icon72 = "\u{ea1d}"
    // icon-cruise
    case icon73 = "\u{e91c}"
    // icon-tour-bus
    case icon74 = "\u{e941}"
    // icon-transport
    case icon75 = "\u{e942}"
    // icon-taxi
    case icon76 = "\u{ea64}"
    // icon-metro
    case icon77 = "\u{ea65}"
    // icon-car_wash_icon
    case icon78 = "\u{ea36}"
    // icon-fix_car_auto_automobile_icon
    case icon79 = "\u{ea18}"
    // icon-parking_square_icon
    case icon80 = "\u{ea05}"
    // con-gas_station_oil_gasoline_icon
    case icon81 = "\u{ea03}"
    // icon-bicycle_icon-1
    case icon82 = "\u{f260}"
    // icon-motorcycle_motorbike_bike_trans
    case icon83 = "\u{e9c0}"
    // icon-shinkansen_train_railway_locomo
    case icon84 = "\u{e9f1}"
    // icon-barrier_barriers_road_secure_sec
    case icon85 = "\u{e9e2}"
    // icon-charger_charging_station_tesla_e
    case icon86 = "\u{e99a}"
    // 购
    // icon-application
    case icon87 = "\u{efc9}"
    // icon-booth
    case icon88 = "\u{efcb}"
    // icon-shopping
    case icon89 = "\u{eb62}"
    // icon-pinduoduo
    case icon90 = "\u{eacf}"
    // icon-taobao11
    case icon91 = "\u{eaee}"
    // icon-jingdong
    case icon92 = "\u{ea8b}"
    // icon-tianmao_t
    case icon93 = "\u{ecc8}"
    // icon-meituan
    case icon94 = "\u{eab8}"
    // icon-eleme
    case icon95 = "\u{ebbe}"
    // icon-douyin
    case icon96 = "\u{eb97}"
    // icon-kuaishou
    case icon97 = "\u{ea77}"
    // icon-meiriyouxian
    case icon98 = "\u{eb7c}"
    // icon-care_health_hygienic_paste_tooth_icon
    case icon99 = "\u{ea7e}"
    // icon-ad-product
    case icon100 = "\u{f1cb}"
    // icon-devices
    case icon101 = "\u{f0b8}"
    // icon-lip-gloss
    case icon102 = "\u{eb7f}"
    // icon-handwashing-fluid
    case icon103 = "\u{eb7b}"
    
    // 乐
    // icon-music
    case icon104 = "\u{eb1e}"
    // icon-piano
    case icon105 = "\u{eb21}"
    // icon-movie
    case icon106 = "\u{f0f8}"
    // icon-game-three
    case icon107 = "\u{ec1f}"
    // icon-microphone-one
    case icon108 = "\u{ec3d}"
    // icon-tickets-two
    case icon109 = "\u{e93e}"
    // icon-outdoor
    case icon110 = "\u{ea35}"
    // icon-game
    case icon111 = "\u{ea0d}"
    // icon-camera-three
    case icon112 = "\u{ebf2}"
    
    // 医
    // icon-medical-box
    case icon113 = "\u{ebcd}"
    // icon-medicine-bottle
    case icon114 = "\u{ebcf}"
    // icon-injection
    case icon115 = "\u{ebca}"
    // icon-pills
    case icon116 = "\u{ebda}"
    // icon-ico_med_doctor
    case icon117 = "\u{e912}"
    // icon-mask
    case icon118 = "\u{ebcc}"
    // con-healthcare_medical_icon-1
    case icon119 = "\u{ebce}"
    // icon-toxins
    case icon120 = "\u{ebe3}"
    
    // 育
    // icon-preschool
    case icon121 = "\u{ef63}"
    // icon-book
    case icon122 = "\u{f061}"
    // icon-school
    case icon123 = "\u{f002}"
    // icon-treadmill-one
    case icon124 = "\u{e990}"
    // icon-classroom
    case icon125 = "\u{e99d}"
    
    // 情
    // icon-birthday-cake
    case icon127 = "\u{ecee}"
    // icon-beer-mug
    case icon128 = "\u{ecec}"
    // icon-gift-box
    case icon129 = "\u{f0d6}"
    // icon-red-envelopes
    case icon130 = "\u{ea47}"
    // icon-red-envelope
    case icon131 = "\u{eb5e}"
    // icon-alcohol_banquet_beer_beverage_
    case icon132 = "\u{ebd2}"
    // icon-wine_love_valentines_romantic_di
    case icon133 = "\u{ebd5}"
    // icon-dinner_wine_love_valentines_rom
    case icon134 = "\u{ebdf}"
    // icon-dress_happiness_love_marriage_p
    case icon135 = "\u{ec9d}"
    // icon-bride_couple_love_romance_vale
    case icon136 = "\u{ec95}"
    // icon-bell_happiness_love_marriage_party
    case icon137 = "\u{ec9c}"
    //  icon-bouquet_roses_valenticons_valen
    case icon138 = "\u{ec67}"
    // icon-death_funeral_grave_gravestone_h
    case icon139 = "\u{ec46}"
    // icon-brown_dead-plant_dried-out_plant_potted-plant_icon
    case icon140 = "\u{ebd1}"
    // icon-crown
    case icon141 = "\u{e9f5}"
    
    // 公
    // icon-money_payment_cash_dollar_eco
    case icon142 = "\u{ecc6}"
    // icon-hold-seeds
    case icon143 = "\u{ecb5}"
    // icon-wallet-one
    case icon144 = "\u{eb67}"
    // icon-hold_heat_love_hands_gesture_ic
    case icon145 = "\u{eca8}"
    // icon-aid_charity_non_organization_pro
    case icon146 = "\u{ecaa}"
    // icon-accessories_education_equipment
    case icon147 = "\u{eca7}"
    // icon-attachment_office_paperclip_suppl
    case icon148 = "\u{ecb8}"
    // icon-service_repair_tool_automobile_e
    case icon149 = "\u{ecb2}"
    // icon-general_office_repair_repair-tool_screwdriver_icon
    case icon150 = "\u{ecba}"
    // icon-seal
    case icon151 = "\u{ec64}"
    // icon-file-tips
    case icon152 = "\u{eb09}"
    
    // 投
    // icon-deposit
    case icon153 = "\u{eb40}"
    // icon-currency
    case icon154 = "\u{eb3f}"
    // icon-financing
    case icon155 = "\u{eb4d}"
    //  icon-financing-one
    case icon156 = "\u{eb4b}"
    // icon-funds
    case icon157 = "\u{eb4f}"
    // icon-heavy-metal
    case icon158 = "\u{eb50}"
    // icon-paper-money-two
    case icon159 = "\u{eb5a}"
    // icon-umbrella
    case icon160 = "\u{f142}"
    // icon-trophy
    case icon161 = "\u{f13e}"
    // icon-chart-line
    case icon162 = "\u{ef7c}"
    // icon-chart-stock
    case icon163 = "\u{ef81}"
    // icon-diamond_diamonds_icon
    case icon164 = "\u{ec2c}"
    // icon-luxury-icon_fashion_accessories_earring
    case icon165 = "\u{ebe1}"
    // icon-bitcoin
    case icon166 = "\u{efaf}"
    
    // 其
    // icon-timer
    case icon167 = "\u{ec7d}"
    // icon-bowl_canine_dog_feed_food_icon
    case icon168 = "\u{e938}"
    // icon-cocktail
    case icon169 = "\u{e919}"
    // icon-coconut-tree
    case icon170 = "\u{e91a}"
    // icon-homestay
    case icon171 = "\u{e925}"
    // icon-five-star-badge
    case icon172 = "\u{e968}"
    // icon-helmet
    case icon173 = "\u{e970}"
    // icon-id-card-h
    case icon174 = "\u{e9a1}"
    // icon-arithmetic-one
    case icon175 = "\u{ef70}"
    // icon-battery-charge
    case icon176 = "\u{e9d5}"
    // icon-cooperative-handshake
    case icon177 = "\u{e9f2}"
    // icon-fan
    case icon178 = "\u{ea01}"
    // icon-pennant
    case icon179 = "\u{ea3b}"
    // icon-surveillance-cameras-two
    case icon180 = "\u{ea5e}"
    // icon-system
    case icon181 = "\u{ea61}"
    // icon-application-menu
    case icon182 = "\u{ea90}"
    // icon-airpods
    case icon183 = "\u{eb0d}"
    // icon-headset-one
    case icon184 = "\u{eb15}"
    // icon-exchange-two
    case icon185 = "\u{eb46}"
    // icon-screenshot
    case icon186 = "\u{f123}"
    // icon-rocking-horse
    case icon187 = "\u{ef67}"
    // icon-steoller
    case icon188 = "\u{ef6b}"
    // icon-diapers-one
    case icon189 = "\u{ef1d}"
    // icon-baby-bottle
    case icon190 = "\u{e9cf}"
    // icon-app-store
    case icon191 = "\u{f015}"
    // icon-wechat
    case icon192 = "\u{f056}"
    // icon-alipay
    case icon193 = "\u{f013}"
    // icon-recycling
    case icon194 = "\u{f19f}"
    // icon-cube
    case icon195 = "\u{f1e7}"
    // icon-bolt-one
    case icon196 = "\u{ebeb}"
    // icon-charging-treasure
    case icon197 = "\u{ebf6}"
    // icon-cloud-storage
    case icon198 = "\u{ebf8}"
    // icon-computer
    case icon199 = "\u{ebfa}"
    // icon-iphone
    case icon200 = "\u{ec30}"
    // icon-ipad
    case icon201 = "\u{ec2f}"
    // icon-printer
    case icon202 = "\u{ec53}"
    // icon-exchange-four
    case icon203 = "\u{eb43}"
    // icon-doc-detail
    case icon204 = "\u{f065}"
    // icon-income
    case icon205 = "\u{eb53}"
    // icon-expenses
    case icon206 = "\u{eb49}"
    // icon-income-one
    case icon207 = "\u{eb52}"
    // icon-expenses-one
    case icon208 = "\u{eb48}"
    // icon-vegetable-basket
    case icon209 = "\u{ed59}"
    // icon-personal-privacy
    case icon210 = "\u{e9bd}"
    // icon-watch-one
    case icon211 = "\u{ec91}"
    // icon-perfume
    case icon212 = "\u{ef2b}"
    // icon-shaver-one
    case icon213 = "\u{eb92}"
    // icon-fingernail
    case icon214 = "\u{eb76}"
    // icon-bank-card
    case icon215 = "\u{eb39}"
    
    // 获取unicode的编码
    func getUnicodeValue() -> String {
        var str = ""
        for scalar in self.rawValue.unicodeScalars {
            str += String(scalar.value, radix: 16)
        }
        return pod(str)
    }
    // 补位
    func pod(_ str:String) -> String {
        var value = str
        while value.count % 4 != 0 {
            value = "0"+value
        }
        return value
    }
    // 根据unicode编码找出相应的枚举
    static func findByUnicodeValue(_ value:String) -> IconFontEnum? {
        for item in IconFontEnum.allCases {
            if item.getUnicodeValue() == value {
                return item
            }
        }
        return nil
    }
    // 根据值找到相应的枚举
    static func findByValue(_ value:String) -> IconFontEnum? {
        for item in IconFontEnum.allCases {
            if item.rawValue == value {
                return item
            }
        }
        return nil
    }
}




func hexStr2Unicode(_ hexStr:String, _ defaultHexStr:String = IconFontEnum.icon1.getUnicodeValue()) -> String {
    var transValue = hexStr
    if (hexStr.count <= 0) {
        transValue = defaultHexStr
    }
    return String(Int(transValue, radix: 16).map{ Character(UnicodeScalar($0)!)}!)
}

// 账本图标，不同账本，设置不同的图标
var accountBookIconArray:[IconFontEnum] = [
    .icon1,.icon2,.icon3,.icon4,.icon5,.icon6,.icon7,.icon8,.icon9,.icon10,
    .icon11,.icon12,.icon13,.icon14,.icon15,.icon16,.icon17,.icon18,.icon19,.icon20,
    .icon21,.icon22,.icon23,.icon24
]




