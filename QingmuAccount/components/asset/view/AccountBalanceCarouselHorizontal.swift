//
//  AccountBalanceCarouselHorizontal.swift
//  QingmuAccount
//  账户余额轮播（横向：金额 + 币型编码并排，上下切换）。
//  Created by 周荥马 on 2026/8/14.
//

import SwiftUI

struct AccountBalanceCarouselHorizontal: View {
    let balances: [(currency: String, totalCents: Int64)]
    @State private var currentIndex = 0
    @State private var timer: Timer?

    var body: some View {
        let current = current
        return HStack(spacing: 6) {
            // 金额
            Text(amountText)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(current.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .id("amount-\(current.currency)")
                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)),
                                        removal: .opacity.combined(with: .move(edge: .top))))
            // 币型编码
            Text(current.currency)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(current.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
                .opacity(0.7)
                .id("code-\(current.currency)")
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
