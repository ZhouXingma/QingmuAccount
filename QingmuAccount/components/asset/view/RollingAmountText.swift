//
//  RollingAmountText.swift
//  QingmuAccount
//  金额数字跳动：金额变化时数字从旧值平滑滚动到新值（逐帧插值）。
//  Created by 周荥马 on 2026/8/13.
//

import SwiftUI

struct RollingAmountText: View {
    let cents: Int64
    var prefix: String = ""
    var font: Font = .system(size: 16, weight: .bold)
    var color: Color = .primary

    @State private var displayCents: Int64 = 0
    @State private var rollTimer: Timer?

    var body: some View {
        Text(prefix + numberText)
            .font(font)
            .foregroundColor(color)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .onAppear {
                displayCents = cents
            }
            .onDisappear {
                rollTimer?.invalidate()
                rollTimer = nil
            }
            .onChange(of: cents) { newValue in
                roll(to: newValue)
            }
    }

    private var numberText: String {
        let isNeg = displayCents < 0
        let absMoney = SQLiteManager.money(fromCents: abs(displayCents))
        return isNeg ? "-" + absMoney : absMoney
    }

    private func roll(to target: Int64) {
        rollTimer?.invalidate()
        let start = displayCents
        let diff = target - start
        guard diff != 0 else {
            displayCents = target
            return
        }
        let steps = 30
        let interval = 0.45 / Double(steps)
        var step = 0
        rollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            step += 1
            let p = Double(step) / Double(steps)
            let eased = 1 - pow(1 - p, 3) // easeOut 三次曲线
            displayCents = start + Int64(Double(diff) * eased)
            if step >= steps {
                displayCents = target
                t.invalidate()
                rollTimer = nil
            }
        }
    }
}
