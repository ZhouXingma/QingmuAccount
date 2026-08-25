//
//  AccountBookItemComponent.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/28.
//

import SwiftUI

struct AccountBookItem : View {
    let name: String
    let iconValue: String
    let bgColor: String
    // 备注
    let description: String?
    // 默认账户名称（未设置时为空串）
    let defaultAccountName: String
    // 默认币型（ISO 代码）
    let defaultCurrency: String
    @Binding var selectAccountBookName:String

    private var isSelected: Bool {
        selectAccountBookName == name
    }

    var body: some View {
        HStack(spacing: 12) {
            // 左侧彩色图标
            ZStack {
                Color(hex: bgColor.count <= 0 ? ColorConfig.SOFT_COLORS[0] : bgColor)
                    .cornerRadius(8)

                Text(hexStr2Unicode(iconValue))
                    .font(.custom("icomoon", size: 20))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)

            // 中间：名称 + 备注
            VStack(alignment: .leading, spacing: 3) {
                Text(StringUtils.trim(name))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("FontColor"))
                    .lineLimit(1)

                if let description = description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 右侧：默认账户 · 默认币型 + 选中对勾
            VStack(alignment: .trailing, spacing: 4) {
                Text(accountBookTag)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 17))
                    .foregroundColor(Color("DefaultButtonBackgroud"))
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 60)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color("DefaultButtonBackgroud") : Color("MainShadowColor").opacity(0.06), lineWidth: isSelected ? 1.5 : 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(isSelected ? 0.18 : 0.06), radius: isSelected ? 5 : 3, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 默认账户 · 默认币型文案
    private var accountBookTag: String {
        if defaultAccountName.isEmpty {
            return AssetCurrency.name(of: defaultCurrency)
        }
        return "\(defaultAccountName) · \(AssetCurrency.name(of: defaultCurrency))"
    }
}
