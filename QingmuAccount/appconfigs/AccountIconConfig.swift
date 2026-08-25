//
//  AccountIconConfig.swift
//  QingmuAccount
//  资产账户图标配置：
//    1. 图片/SF/文字三类图标的字符串编码与解析
//    2. 图标分组（账户 / 借贷 / 通用SF）+ 文字图标选色卡
//
//  图标字符串编码：
//    - 图片资源：直接存资源名（如 "account_xinyongka"、"loan_jiekuan"）
//    - SF 符号：  "sf:" + 符号名（如 "sf:creditcard"）
//    - 文字图标： "text:" + 字符(1~2个) + ":" + 六位Hex色（如 "text:微:FF6E42"）
//

import Foundation

/// 图标类型
enum AssetAccountIconType {
    case image      // 图片资源（信用卡 / 公积金 / 借贷等）
    case sfSymbol   // Apple SF Symbol
    case text       // 文字图标（1~2字 + 颜色）
}

/// 图标解析结果
struct AssetAccountIconData {
    var type: AssetAccountIconType
    /// 图片资源名 / SF 符号名
    var name: String = ""
    /// 文字图标内容（1~2个字符）
    var chars: String = ""
    /// 文字图标背景色（六位十六进制，不含 #）
    var colorHex: String = ""
}

struct AccountIconConfig {
    static let textIconPrefix = "text:"
    static let sfIconPrefix = "sf:"
    /// 文字图标默认背景色（与账本设置默认主题色统一：SOFT_COLORS 首个颜色）
    static var defaultTextIconColor: String {
        return ColorConfig.SOFT_COLORS.first?.replacingOccurrences(of: "#", with: "") ?? "ECE2EB"
    }

    /// 账户类图标（通用 + 自定义新增图标）
    static let accountIcons: [String] = ["account_xinyongka", "account_gongjijin", "account_wx", "account_zfb", "account_yhk", "account_rz"]
    /// 借贷类图标（借款、欠款、车贷、房贷等）
    static let loanIcons: [String] = ["loan_jiekuan", "loan_qiankuan", "loan_chedaix", "loan_fangdai", "loan_qita"]
    /// Apple 原生 SF 通用图标（均为稳定的常见符号）
    static let sfIcons: [String] = [
        "creditcard", "creditcard.fill", "wallet.pass.fill",
        "building.columns.fill", "building.columns",
        "dollarsign.circle.fill",
        "bag.fill", "bag", "briefcase.fill", "briefcase",
        "house.fill", "car.fill", "graduationcap.fill",
        "heart.fill", "star.fill", "leaf.fill", "gift.fill",
        "cart.fill", "folder.fill", "doc.fill", "lock.fill",
        "tray.fill", "clock.fill", "calendar", "bell.fill",
        "person.fill", "phone.fill", "paperplane.fill", "music.note",
        "chart.bar", "percent", "sparkles", "pawprint.fill",
        "cross.case.fill", "pills.fill", "ellipsis.circle.fill"
    ]
    /// 文字图标推荐选色卡（与账本色系保持一致：直接复用 ColorConfig.SOFT_COLORS）
    static let textIconColors: [String] = ColorConfig.SOFT_COLORS.map {
        $0.replacingOccurrences(of: "#", with: "")
    }
    /// 图片资源名 → 中文名（网格标签 / 搜索用）
    static let iconNameMap: [String: String] = [
        "account_xinyongka": "信用卡",
        "account_gongjijin": "公积金",
        "account_wx": "微信",
        "account_zfb": "支付宝",
        "account_yhk": "银行卡",
        "account_rz": "其它",
        "loan_jiekuan": "借款",
        "loan_qiankuan": "欠款",
        "loan_chedaix": "车贷",
        "loan_fangdai": "房贷",
        "loan_qita": "其它贷款"
    ]

    /// 当前仍存留的图片图标资源名（合法集合，渲染兜底判断用）
    static var validImageIcons: [String] {
        return accountIcons + loanIcons
    }

    /// 解析图标字符串 → 图标数据
    static func parse(_ icon: String) -> AssetAccountIconData {
        if icon.hasPrefix(textIconPrefix) {
            let rest = icon.dropFirst(textIconPrefix.count)
            let parts = rest.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let chars = String(parts.first ?? "")
            let color = parts.count > 1 ? String(parts[1]) : defaultTextIconColor
            return AssetAccountIconData(type: .text, chars: chars, colorHex: color)
        }
        if icon.hasPrefix(sfIconPrefix) {
            return AssetAccountIconData(type: .sfSymbol, name: String(icon.dropFirst(sfIconPrefix.count)))
        }
        return AssetAccountIconData(type: .image, name: icon)
    }

    /// 组装文字图标字符串（最多2字）
    static func makeTextIcon(chars: String, colorHex: String) -> String {
        let c = chars.count > 2 ? String(chars.prefix(2)) : chars
        let hex = colorHex.isEmpty ? defaultTextIconColor : colorHex
        return "\(textIconPrefix)\(c):\(hex)"
    }

    /// 组装 SF 图标字符串
    static func makeSfIcon(name: String) -> String {
        return "\(sfIconPrefix)\(name)"
    }

    /// 取账户名称前 n 个字符（文字图标默认内容）
    static func firstChars(of name: String, count: Int) -> String {
        return String(name.prefix(count))
    }
}