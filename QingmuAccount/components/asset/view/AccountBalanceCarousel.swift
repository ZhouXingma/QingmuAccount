//
//  AccountBalanceCarousel.swift
//  QingmuAccount
//  账户列表行余额轮播：多币种时循环显示各币种金额（符号标记 + 数字滚动动画）。
//  Created by 周荥马 on 2026/8/14.
//

import SwiftUI

struct AccountBalanceCarousel: View {
    let balances: [(currency: String, totalCents: Int64)]
    @State private var currentIndex = 0
    @State private var timer: Timer?

    var body: some View {
        let current = current
        return VStack(alignment: .trailing, spacing: 1) {
            // 币型编码（右上）
            Text(current.currency)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(current.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .opacity(0.7)
                .id("code-\(current.currency)")
                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)),
                                        removal: .opacity.combined(with: .move(edge: .top))))
            // 金额（直接显示当前币种，不做数字滚动）
            Text(amountText)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(current.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .id("amount-\(current.currency)")
                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)),
                                        removal: .opacity.combined(with: .move(edge: .top))))
        }
        .animation(.easeInOut(duration: 0.35), value: currentIndex)
        .onAppear { start() }
        .onDisappear { timer?.invalidate(); timer = nil }
    }

    private var amountText: String {
        let absMoney = SQLiteManager.money(fromCents: abs(current.totalCents))
        return current.totalCents < 0 ? "-" + absMoney : absMoney
    }

    private var current: (currency: String, totalCents: Int64) {
        guard !sortedBalances.isEmpty else { return ("CNY", 0) }
        return sortedBalances[currentIndex % sortedBalances.count]
    }

    /// 币种排序：人民币优先，其余按代码字母序
    private var sortedBalances: [(currency: String, totalCents: Int64)] {
        balances.sorted { a, b in
            if a.currency == "CNY" { return true }
            if b.currency == "CNY" { return false }
            return a.currency < b.currency
        }
    }

    private func start() {
        guard sortedBalances.count > 1 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                currentIndex = (currentIndex + 1) % sortedBalances.count
            }
        }
    }
}
