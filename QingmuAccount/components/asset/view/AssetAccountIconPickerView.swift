//
//  AssetAccountIconPickerView.swift
//  QingmuAccount
//  资产账户图标选择器（半屏 sheet）：
//    - 图标页：一个页面内按小节分组（账户/借贷/通用），支持搜索
//    - 文字图标页：输入 1~2 个字（最多2字）+ 调色盘（系统选色 + 推荐柔和色）
//
//  同文件提供 AssetAccountIconView：统一渲染 图片 / SF / 文字 三类图标。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI
import UIKit

// MARK: - 统一图标渲染器

/// 资产账户图标：image / SF / text 三类统一渲染
struct AssetAccountIconView: View {
    let icon: String
    /// 图标显示尺寸（正方形边长）
    var iconSize: CGFloat = 30
    /// 文字图标的圆角
    var textCornerRadius: CGFloat = 12

    var body: some View {
        let data = AccountIconConfig.parse(icon)
        return Group {
            switch data.type {
            case .text:
                ZStack {
                    RoundedRectangle(cornerRadius: textCornerRadius)
                        .fill(Color(hex: data.colorHex.hasPrefix("#") ? data.colorHex : "#" + data.colorHex))
                    Text(data.chars)
                        .font(.system(size: data.chars.count > 1 ? iconSize * 0.38 : iconSize * 0.46, weight: .bold))
                        .foregroundColor(foreground(for: data.colorHex))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .padding(.horizontal, iconSize * 0.1)
                }
                .frame(width: iconSize, height: iconSize)
            case .sfSymbol:
                Image(systemName: data.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(Color("DefaultButtonBackgroud"))
            case .image:
                // 资源名缺失或已被删除（存量旧品牌/银行图标）时兜底
                if data.name.isEmpty || !AccountIconConfig.validImageIcons.contains(data.name) {
                    Image(systemName: "creditcard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(Color("DefaultButtonBackgroud"))
                        .opacity(0.4)
                } else {
                    Image(data.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                }
            }
        }
    }

    /// 根据背景色明度自动选择文字颜色（浅色背景用深字，深色背景用白字）
    private func foreground(for hex: String) -> Color {
        let h = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard h.count >= 6, let val = UInt64(h.prefix(6), radix: 16) else { return .white }
        let r = Double((val >> 16) & 0xFF) / 255.0
        let g = Double((val >> 8) & 0xFF) / 255.0
        let b = Double(val & 0xFF) / 255.0
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.62 ? Color(hex: "37474F") : .white
    }
}

// MARK: - 图标选择器

struct AssetAccountIconPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedIcon: String
    /// 账户名称（文字图标默认取名称前 N 个字）
    var accountName: String = ""

    @State private var mode: Int = 0       // 0=图标，1=文字图标
    @State private var keyword: String = ""
    @State private var imageSelected: String = ""

    // 文字图标参数
    @State private var textChars: String = ""
    @State private var textColorHex: String = AccountIconConfig.defaultTextIconColor

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)

    var body: some View {
        VStack(spacing: 14) {
            header
            modePicker
            if mode == 0 {
                iconContent
            } else {
                textContent
            }
            confirmButton
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .onTapGesture { toHideKeyboard() }
        .onAppear { prepare() }
    }

    // MARK: - 标题栏

    private var header: some View {
        HStack {
            Text("选择图标")
                .font(.system(size: 17, weight: .bold))
            Spacer()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    /// 图标 / 文字图标 切换
    private var modePicker: some View {
        Picker("", selection: $mode) {
            Text("图标").tag(0)
            Text("文字图标").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 15)
        .onChange(of: mode) { newValue in
            if newValue == 1 && textChars.isEmpty {
                let first = AccountIconConfig.firstChars(of: accountName, count: 1)
                if !first.isEmpty { textChars = first }
            }
        }
    }

    // MARK: - 图标页（单页小节分组 + 搜索）

    private var iconContent: some View {
        VStack(spacing: 12) {
            searchBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if keyword.trimmingCharacters(in: .whitespaces).isEmpty {
                        if !AccountIconConfig.accountIcons.isEmpty {
                            sectionTitle("账户")
                            iconGrid(AccountIconConfig.accountIcons)
                        }
                        if !AccountIconConfig.loanIcons.isEmpty {
                            sectionTitle("借贷")
                            iconGrid(AccountIconConfig.loanIcons)
                        }
                        sectionTitle("通用")
                        iconGrid(AccountIconConfig.sfIcons)
                    } else {
                        iconGrid(allFilteredIcons())
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            TextField("搜索图标", text: $keyword)
                .font(.system(size: 14))
            if !keyword.isEmpty {
                Button {
                    keyword = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 42)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color("MainShadowColor").opacity(0.1), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 15)
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color("DefaultButtonBackgroud"))
                .frame(width: 5, height: 5)
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func allFilteredIcons() -> [String] {
        let kw = keyword.trimmingCharacters(in: .whitespaces)
        let all = AccountIconConfig.accountIcons + AccountIconConfig.loanIcons + AccountIconConfig.sfIcons
        guard !kw.isEmpty else { return all }
        return all.filter { iconName in
            if iconName.range(of: kw, options: .caseInsensitive) != nil { return true }
            return (AccountIconConfig.iconNameMap[iconName] ?? "").range(of: kw) != nil
        }
    }

    private func iconGrid(_ icons: [String]) -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(icons, id: \.self) { item in
                iconCell(item)
            }
        }
        .padding(.bottom, 6)
    }

    private func iconCell(_ item: String) -> some View {
        let isSF = AccountIconConfig.sfIcons.contains(item)
        let iconStr = isSF ? AccountIconConfig.makeSfIcon(name: item) : item
        let isSelected = imageSelected == iconStr
        return VStack(spacing: 5) {
            if isSF {
                Image(systemName: item)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color("DefaultButtonBackgroud"))
                    .frame(width: 32, height: 32)
                    .padding(9)
                    .background(
                        isSelected ? Color("DefaultButtonBackgroud") : Color("MainBackgroundColor"),
                        in: RoundedRectangle(cornerRadius: 13)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(isSelected ? Color("DefaultButtonBackgroud") : Color.clear, lineWidth: 1.5)
                    )
                    .shadow(color: Color("MainShadowColor").opacity(isSelected ? 0.25 : 0.08), radius: 4, x: 0, y: 2)
            } else {
                Image(item)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(9)
                    .background(
                        isSelected ? Color("DefaultButtonBackgroud").opacity(0.12) : Color("MainBackgroundColor"),
                        in: RoundedRectangle(cornerRadius: 13)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(isSelected ? Color("DefaultButtonBackgroud") : Color.clear, lineWidth: 1.5)
                    )
                    .shadow(color: Color("MainShadowColor").opacity(isSelected ? 0.25 : 0.08), radius: 4, x: 0, y: 2)
                Text(AccountIconConfig.iconNameMap[item] ?? item)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? Color("DefaultButtonBackgroud") : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .onTapGesture {
            keyFeedback(0)
            imageSelected = iconStr
        }
    }

    // MARK: - 文字图标页

    private var textContent: some View {
        VStack(spacing: 0) {
            // 顶部固定：预览 + 文字内容设置同一行，不随颜色区滚动
            HStack(alignment: .center, spacing: 14) {
                previewSection
                textInputSection
            }
            .padding(.horizontal, 15)
            .padding(.top, 12)
            .padding(.bottom, 12)

            // 填充颜色区：可上下滚动
            ScrollView(showsIndicators: false) {
                colorSection
                    .padding(.horizontal, 15)
                    .padding(.bottom, 16)
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var previewSection: some View {
        VStack(spacing: 5) {
            AssetAccountIconView(icon: AccountIconConfig.makeTextIcon(chars: textChars, colorHex: textColorHex),
                                iconSize: 44, textCornerRadius: 14)
            Text("预览")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .fixedSize()
    }

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("文字内容")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("最多2个字")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            MaxLengthTextField(text: $textChars, maxLength: 2, placeholder: "请输入")
                .padding(.horizontal, 12)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 42)
                .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 11))
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("填充颜色")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            SoftColorPanel(hex: $textColorHex)
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
    }

    // 颜色组件统一由 SoftColorPanel 提供（2D取色区 + 色相条 + 推荐色卡）

    // MARK: - 确定

    private var confirmButton: some View {
        Button {
            confirm()
        } label: {
            Text("确定")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(
                    canConfirm() ? Color("DefaultButtonBackgroud")
                        : Color("DefaultButtonBackgroud").opacity(ColorConfig.UNABLE_COLOR_OPCITY),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .shadow(color: canConfirm() ? Color("MainShadowColor").opacity(0.25) : Color.clear, radius: 6, x: 0, y: 3)
        }
        .disabled(!canConfirm())
        .padding(.bottom, 22)
    }

    private func canConfirm() -> Bool {
        if mode == 0 { return !imageSelected.isEmpty }
        return !textChars.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func confirm() {
        keyFeedback()
        if mode == 0 {
            if !imageSelected.isEmpty {
                selectedIcon = imageSelected
            }
        } else {
            let chars = textChars.trimmingCharacters(in: .whitespacesAndNewlines)
            if !chars.isEmpty {
                selectedIcon = AccountIconConfig.makeTextIcon(chars: chars, colorHex: textColorHex)
            }
        }
        presentationMode.wrappedValue.dismiss()
    }

    // MARK: - 初始化

    private func prepare() {
        if selectedIcon.isEmpty {
            mode = 1
            textColorHex = AccountIconConfig.defaultTextIconColor
            let first = AccountIconConfig.firstChars(of: accountName, count: 1)
            if !first.isEmpty { textChars = first }
            return
        }
        let data = AccountIconConfig.parse(selectedIcon)
        if data.type == .text {
            mode = 1
            textChars = String(data.chars.prefix(2))
            textColorHex = data.colorHex.isEmpty ? AccountIconConfig.defaultTextIconColor : data.colorHex
        } else {
            mode = 0
            imageSelected = selectedIcon
        }
    }
}

// MARK: - 智能限长输入框（输入期间不截断，结束编辑后截断）

/// 最多 maxLength 字；输入过程中不限制（拼音组合、多字都能打），退出编辑/失焦后再截断到 maxLength 字
struct MaxLengthTextField: UIViewRepresentable {
    @Binding var text: String
    var maxLength: Int = 2
    var placeholder: String = ""

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate = context.coordinator
        tf.borderStyle = .none
        tf.placeholder = placeholder
        tf.textAlignment = .right
        tf.font = .systemFont(ofSize: 15, weight: .bold)
        tf.textColor = .label
        tf.setContentHuggingPriority(.init(rawValue: 749), for: .horizontal)
        tf.setContentCompressionResistancePriority(.init(rawValue: 749), for: .horizontal)
        tf.returnKeyType = .done
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholder = placeholder
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: MaxLengthTextField

        init(_ parent: MaxLengthTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // 输入过程中不限制长度（含拼音组合/多字），退出编辑时再截断到最多2个字
            return true
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if let t = textField.text, t.count > parent.maxLength {
                let truncated = String(t.prefix(parent.maxLength))
                textField.text = truncated
                parent.text = truncated
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

// MARK: - 通用柔和调色板（文字图标 / 账本主题色共用）

/// 2D 取色区 + 色相条 + 推荐色卡。绑定六位 HEX（不含 #），拖/点选色后写回 binding。
struct SoftColorPanel: View {
    @Binding var hex: String
    /// 推荐色卡（六位 HEX，不含 #）
    var swatchColors: [String] = AccountIconConfig.textIconColors

    @State private var hue: Double = 0.6
    @State private var saturation: Double = 0.3
    @State private var brightness: Double = 0.5

    private let colorColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    private let hueSpectrum: [Color] = [
        Color(hex: "FF0000"), Color(hex: "FF7F00"), Color(hex: "FFFF00"),
        Color(hex: "00FF00"), Color(hex: "00FF7F"), Color(hex: "00FFFF"),
        Color(hex: "007FFF"), Color(hex: "0000FF"), Color(hex: "7F00FF"),
        Color(hex: "FF00FF"), Color(hex: "FF007F"), Color(hex: "FF0000")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 2D 取色区 + 色相条
            VStack(alignment: .leading, spacing: 12) {
                colorField
                hueStrip
            }
            .padding(12)
            .background(Color("ViewBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))

            // 推荐柔和色
            LazyVGrid(columns: colorColumns, spacing: 12) {
                ForEach(swatchColors, id: \.self) { colorHex in
                    colorSwatch(colorHex)
                }
            }
        }
        .onAppear { seedHSB() }
        .onChange(of: hex) { _ in seedHSB() }
    }

    /// 饱和度×明度 二维取色区（点击 / 拖动取色）
    private var colorField: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color(hue: hue, saturation: 1, brightness: 1))
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.white, Color(hue: hue, saturation: 1, brightness: 1)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.clear, .black],
                                       startPoint: .top, endPoint: .bottom)
                    )
                Circle()
                    .fill(Color(hue: hue, saturation: saturation, brightness: brightness))
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .frame(width: 20, height: 20)
                    .position(x: saturation * w, y: (1 - brightness) * h)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        saturation = max(0, min(1, value.location.x / max(w, 1)))
                        brightness = max(0, min(1, 1 - value.location.y / max(h, 1)))
                        syncHexFromHSB()
                    }
            )
        }
        .frame(height: 170)
    }

    /// 色相条（拖动 / 点击选色相）
    private var hueStrip: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(colors: hueSpectrum, startPoint: .leading, endPoint: .trailing))
                    .frame(height: 10)
                Circle()
                    .fill(.white)
                    .overlay(Circle().stroke(Color("FontColor").opacity(0.4), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                    .frame(width: 18, height: 18)
                    .offset(x: hue * max(w - 18, 0))
            }
            .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        hue = max(0, min(1, value.location.x / max(w, 1)))
                        syncHexFromHSB()
                    }
            )
        }
        .frame(height: 24)
    }

    private func colorSwatch(_ swatchHex: String) -> some View {
        let selected = normalized(hex).lowercased() == swatchHex.lowercased()
        return ZStack {
            Circle()
                .fill(Color(hex: "#" + swatchHex))
                .frame(width: 40, height: 40)
            Circle()
                .stroke(Color("FontColor").opacity(selected ? 0.9 : 0.15), lineWidth: 2)
                .frame(width: 40, height: 40)
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .opacity(selected ? 1 : 0)
        }
        .onTapGesture {
            apply(hex: swatchHex)
        }
    }

    private func seedHSB() {
        let effective = normalized(hex).isEmpty ? AccountIconConfig.defaultTextIconColor : normalized(hex)
        let (h, s, b) = hsb(of: effective)
        hue = h; saturation = s; brightness = b
    }

    private func apply(hex: String) {
        self.hex = hex
        seedHSB()
    }

    private func syncHexFromHSB() {
        hex = hexString(of: Color(hue: hue, saturation: saturation, brightness: brightness))
    }

    private func normalized(_ s: String) -> String {
        var x = s
        if x.hasPrefix("#") { x = String(x.dropFirst()) }
        return x.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func hsb(of hex: String) -> (Double, Double, Double) {
        var hx = hex
        if hx.hasPrefix("#") { hx = String(hx.dropFirst()) }
        guard hx.count >= 6, let v = UInt64(hx.prefix(6), radix: 16) else {
            return (hue, saturation, brightness)
        }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        let color = UIColor(red: r, green: g, blue: b, alpha: 1)
        var hh: CGFloat = 0, ss: CGFloat = 0, bb: CGFloat = 0, aa: CGFloat = 0
        color.getHue(&hh, saturation: &ss, brightness: &bb, alpha: &aa)
        return (Double(hh), Double(ss), Double(bb))
    }

    private func hexString(of color: Color) -> String {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return AccountIconConfig.defaultTextIconColor
        }
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
