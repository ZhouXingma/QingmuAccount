//
//  File.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

class ColorConfig {
    // 失效颜色的透明度，比如：禁用按钮的时候
    public static let UNABLE_COLOR_OPCITY:Double = 0.7
    
    
    public static let SOFT_COLORS:[String] = [
        "#ECE2EB","#F4E0EA","#EFC9D6","#EFB1C7","#FCD97D",
        "#84C9EF","#B4D2ED","#CBBDDD","#DCB5D4","#E3B1D2",
        "#D9CEDA","#D6ACC3","#C6B3CF","#AF689B","#B7B577",
        "#CBE0F4","#9BC4E0","#E5E1EB","#E3D7E6","#C7C9E0",
        "#DBE1F0","#ABCCDD","#75A5B8","#A7D0D8","#E0C323",
        "#DEEBEC","#BED9DD","#AECFD0","#73B3B2","#3C979F",
        "#E1EFF5","#C6E4E8","#ABDAD9","#E1A779","#ECD1E2",
        "#EEACCB","#E094B2","#954B63","#ADC0DA","#7083A6",
        "#DEEBEC","#BED9DD","#AECFD0","#73B3B2","#3C979F",
        "#D3DFDE","#CBC7D0","#E5E1BB","#DFC0C2","#CB98A1",
        "#F5D8C8","#DFE2E3","#C6CCDF","#ACBEDD","#709ED0",
        "#F1CCE1","#DFABCF","#8FD2E6","#5D7AB5","#EBCDA7"
    ]
}


extension Color {
    init(hex string: String) {
            var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if string.hasPrefix("#") {
                _ = string.removeFirst()
            }

            // Double the last value if incomplete hex
            if !string.count.isMultiple(of: 2), let last = string.last {
                string.append(last)
            }

            // Fix invalid values
            if string.count > 8 {
                string = String(string.prefix(8))
            }

            // Scanner creation
            let scanner = Scanner(string: string)

            var color: UInt64 = 0
            scanner.scanHexInt64(&color)

            if string.count == 2 {
                let mask = 0xFF

                let g = Int(color) & mask

                let gray = Double(g) / 255.0

                self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

            } else if string.count == 4 {
                let mask = 0x00FF

                let g = Int(color >> 8) & mask
                let a = Int(color) & mask

                let gray = Double(g) / 255.0
                let alpha = Double(a) / 255.0

                self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

            } else if string.count == 6 {
                let mask = 0x0000FF
                let r = Int(color >> 16) & mask
                let g = Int(color >> 8) & mask
                let b = Int(color) & mask

                let red = Double(r) / 255.0
                let green = Double(g) / 255.0
                let blue = Double(b) / 255.0

                self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

            } else if string.count == 8 {
                let mask = 0x000000FF
                let r = Int(color >> 24) & mask
                let g = Int(color >> 16) & mask
                let b = Int(color >> 8) & mask
                let a = Int(color) & mask

                let red = Double(r) / 255.0
                let green = Double(g) / 255.0
                let blue = Double(b) / 255.0
                let alpha = Double(a) / 255.0

                self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

            } else {
                self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
            }
        }
}
