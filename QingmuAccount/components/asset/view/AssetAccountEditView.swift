//
//  AssetAccountEditView.swift
//  QingmuAccount
//  资产账户添加/编辑（sheet）。
//  Created by 周荥马 on 2026/8/12.
//

import SwiftUI

struct AssetAccountEditView: View {
    enum Mode {
        case add
        case edit
    }

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var globalModel: GlobalModel

    let mode: Mode
    var account: AssetAccountModel?
    var onSave: () -> Void = {}

    @State private var name: String = ""
    @State private var type: Int = 0
    @State private var icon: String = ""
    @State private var selectedCurrencies: Set<String> = ["CNY"]
    @State private var initialMoney: String = ""
    @State private var description: String = ""
    @State private var showIconPicker = false
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")

    private let currencyColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    private let typeColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderComponent(title: mode == .add ? "添加资产账户" : "编辑资产账户")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    iconNameSection
                    typeSection
                    currencySection
                    if mode == .add {
                        formCard {
                            HStack {
                                Text("初始金额")
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                TextField("0.00", text: $initialMoney)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color("DefaultButtonBackgroud"))
                                    .keyboardType(.decimalPad)
                                    .onTapGesture { toHideKeyboard() }
                            }
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("负数代表负债，正数代表资产")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 6)
                    }
                    // 备注
                    formCard {
                        HStack(spacing: 8) {
                            Text("备注")
                                .font(.system(size: 15, weight: .bold))
                            TextField("如：每月10号还款、还款方式等", text: $description)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .onTapGesture { toHideKeyboard() }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .padding(.top, 12)

            // 保存
            Button {
                save()
            } label: {
                Text("保存")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Color("DefaultButtonBackgroud").opacity(canSave() ? 1 : ColorConfig.UNABLE_COLOR_OPCITY),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .shadow(color: canSave() ? Color("MainShadowColor").opacity(0.25) : Color.clear, radius: 6, x: 0, y: 3)
            }
            .disabled(!canSave())
            .padding(.horizontal, 15)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .onTapGesture { toHideKeyboard() }
        .onAppear {
            if mode == .edit, let account = account {
                name = account.name
                type = account.type
                icon = account.icon
                selectedCurrencies = account.currencyList.isEmpty ? ["CNY"] : Set(account.currencyList)
                description = account.description
            }
        }
        .sheet(isPresented: $showIconPicker) {
            AssetAccountIconPickerView(selectedIcon: $icon, accountName: name)
        }
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    /// 图标 + 名称合并行：点击图标进入选择器；未手动选择时图标默认取名称前1个字
    private var iconNameSection: some View {
        HStack(spacing: 12) {
            Button {
                keyFeedback()
                showIconPicker = true
            } label: {
                AssetAccountIconView(icon: resolvedIcon, iconSize: 34, textCornerRadius: 11)
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 11))
                    .shadow(color: Color("MainShadowColor").opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            TextField("输入账户名称", text: $name)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color("FontColor"))
                .onTapGesture { toHideKeyboard() }
            if !name.isEmpty {
                Button {
                    name = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 56)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
    }

    /// 类型选择卡片
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("类型")
                .font(.system(size: 15, weight: .bold))
            LazyVGrid(columns: typeColumns, spacing: 8) {
                ForEach(AssetAccountType.allCases, id: \.rawValue) { item in
                    typeChip(item)
                }
            }
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 6, x: 0, y: 3)
    }

    /// 币型选择卡片（网格，中文展示）
    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("币型（可多选）")
                .font(.system(size: 15, weight: .bold))
            LazyVGrid(columns: currencyColumns, spacing: 8) {
                ForEach(AssetCurrency.allCases, id: \.rawValue) { item in
                    currencyChip(item)
                }
            }
        }
        .padding(14)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func currencyChip(_ item: AssetCurrency) -> some View {
        let selected = selectedCurrencies.contains(item.rawValue)
        return VStack(spacing: 2) {
            Text(item.name)
                .font(.system(size: 13, weight: .bold))
            Text(item.rawValue)
                .font(.system(size: 9))
                .opacity(0.7)
        }
        .foregroundColor(selected ? .white : Color("FontColor"))
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(
            selected ? Color("DefaultButtonBackgroud") : Color("ViewBackgroundColor"),
            in: RoundedRectangle(cornerRadius: 9)
        )
        .shadow(color: selected ? Color("MainShadowColor").opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.15), value: selected)
        .onTapGesture {
            keyFeedback(0)
            if selected {
                // 至少保留一个币型
                if selectedCurrencies.count > 1 {
                    selectedCurrencies.remove(item.rawValue)
                }
            } else {
                selectedCurrencies.insert(item.rawValue)
            }
        }
    }

    /// 通用表单卡片
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack {
            content()
        }
        .padding(.horizontal, 14)
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 52)
        .background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color("MainShadowColor").opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private func typeChip(_ item: AssetAccountType) -> some View {
        Text(item.name)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(type == item.rawValue ? .white : Color("FontColor"))
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(
                type == item.rawValue ? Color("DefaultButtonBackgroud") : Color("ViewBackgroundColor"),
                in: RoundedRectangle(cornerRadius: 9)
            )
            .shadow(color: type == item.rawValue ? Color("MainShadowColor").opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.15), value: type)
            .onTapGesture {
                keyFeedback(0)
                type = item.rawValue
            }
    }

    /// 当前展示图标：未手动选择时，默认取账户名称前1个字作为文字图标（随输入实时变化）
    private var resolvedIcon: String {
        if !icon.isEmpty { return icon }
        let first = AccountIconConfig.firstChars(of: name, count: 1)
        return first.isEmpty ? "" : AccountIconConfig.makeTextIcon(chars: first, colorHex: AccountIconConfig.defaultTextIconColor)
    }

    private func canSave() -> Bool {
        return StringUtils.trimCount(name) > 0
    }

    private func save() {
        keyFeedback()
        let saveIcon = icon.isEmpty
            ? AccountIconConfig.makeTextIcon(chars: AccountIconConfig.firstChars(of: name, count: 1),
                                             colorHex: AccountIconConfig.defaultTextIconColor)
            : icon
        let currencyStr = selectedCurrencies.sorted().joined(separator: ",")
        do {
            if mode == .add {
                let newAccount = AssetAccountModel(name: name, type: type, icon: saveIcon, currency: currencyStr, description: description)
                let initialCents = SQLiteManager.cents(fromMoney: initialMoney.isEmpty ? "0" : initialMoney)
                try AssetAccountOfCacheService.addAccount(newAccount, initialCents: initialCents, cache: globalModel)
            } else if let account = account {
                let updated = AssetAccountModel(
                    id: account.id, name: name, type: type, icon: saveIcon, currency: currencyStr,
                    totalCents: account.totalCents, sort: account.sort, description: description,
                    gmtCreated: account.gmtCreated, gmtModfied: Date()
                )
                try AssetAccountOfCacheService.updateAccount(updated, cache: globalModel)
            }
            onSave()
            presentationMode.wrappedValue.dismiss()
        } catch AssetAccountError.ISEXIT {
            alterConfig.desc = "账户名称已存在"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        } catch {
            alterConfig.desc = "保存失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }
}
