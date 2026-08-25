# QingmuAccount (青木账本)

[English](README_en.md) | [中文](README.md)

A **fully offline** iOS bookkeeping app built with SwiftUI. No network requests, no iCloud dependency — all data is stored locally in an on-device SQLite database. Supports dark mode, multiple ledgers, multiple currencies, budgets, statistical charts, and complete asset/liability management.

> Deployment target iOS 17.6, iPhone only, Swift 5, **zero third-party dependencies**.

---

## Features

### 📒 Ledger Management
- Create, edit, and switch between multiple ledgers; each ledger can customize its name, icon, and background color.
- Each ledger can set a **default currency** (fallback when no account is selected while entering a record).
- The currently selected ledger is persisted and restored on next launch.

### ✍️ Bookkeeping
- Record daily **expenses / income** with date, amount, category icon, and notes.
- Switch freely between **list view** and **calendar view** to see daily income & expenses.
- Amounts are stored and aggregated as integer cents, avoiding floating-point errors.

### 💱 Multi-Currency
- Supports **10 currencies**: CNY, USD, JPY, HKD, EUR, GBP, KRW, AUD, CAD, SGD.
- Records, budgets, asset accounts, and balances all carry a currency field.
- Currencies are **displayed separately with no FX conversion**.

### 💰 Budgets
- Set monthly budgets (with per-currency support).
- The budget detail page shows monthly usage and remaining amount.

### 📊 Statistics
- Monthly / yearly income & expense statistics.
- **Pie chart** for category breakdown, plus a **multi-line scrollable chart** (smooth curves, gradient fill, long-press to inspect values) for comparing dimensions.

### 🏦 Assets & Liabilities
- **6 account types**: Bank Account, Credit Card, Social Fund, Online Platform, Finance/Investment, Borrow/Loan.
- **4 transaction types**: Transfer-in, Transfer-out, Transfer, and Adjustment (manual increase/decrease).
- Complete pages: account detail, account edit, transaction editing, monthly asset view, asset summary, and balance carousel.
- **326 built-in bank/payment-platform icons** (Apple Pay, Alipay, WeChat Pay, UnionPay, major banks, etc.).

### 📈 Overview
- Monthly / yearly income & expense overview for a quick grasp of overall finances.

### 🎨 More
- Full **dark mode** support.
- **Haptic feedback** on key actions.
- Custom number keyboard tailored to the bookkeeping workflow.

---

## Architecture

The project follows a three-layer structure — **View layer → Component layer → Service layer (models + persistence)** — with `GlobalModel` as the central state container (`ObservableObject`), injected into views via `.environmentObject`.

### Service Pattern (Key Convention)
Each data domain is split into two services:
- **`XxxService`** — database read/write, executing SQL via `SQLiteManager` and throwing domain-specific error enums.
- **`XxxOfCacheService`** — the layer views actually call. Checks the `GlobalModel` cache first, falls back to the raw Service on a miss, then writes the result back to the cache.

Aggregate queries (overview, statistics, budget, calendar) all go through `AccountBookAggregateService` (SQL aggregation).

### Persistence (SQLite)
- Data is stored in `Documents/account/account.db` (WAL mode, SQLite3 C API wrapper, `libsqlite3.tbd` linked).
- Amounts use **dual columns**: `money TEXT` keeps the display text + `moneyCents INTEGER` (integer cents, the aggregation base); aggregation always uses `SUM(moneyCents)`.
- On first launch, legacy JSON data is migrated to SQLite in one transaction, with old JSON backed up to `Documents/account_backup_<timestamp>/`. Migration is idempotent.

### Icons
- Icons come from the built-in custom font `icomoon.ttf` (declared in `Info.plist` under `UIAppFonts`).
- `fonts/IconfontEnum.swift` maps enum cases to Unicode code points; the model's `iconStr` stores the enum `rawValue`.

### Colors & Theming
- Named colors from the asset catalog (e.g. `Color("ViewBackgroundColor")`, `Color("FontColor")`) are reused globally and drive dark-mode adaptation.

---

## Build & Run

```bash
xcodebuild -project QingmuAccount.xcodeproj -scheme QingmuAccount \
  -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Or open `QingmuAccount.xcodeproj` in Xcode and run.

- Bundle ID: `acthat.QingmuAccount`
- The project has no test target; verification is via build/run.

---

## About the Icons

- Icon font download: <https://pan.baidu.com/s/1wpGmW57sJhjsfkaxTbAzrw> (code `bi6b`)
- Icon sources: iconpark (most), iconfinder (some), iconfont (a few, all open-source/commercial-use), figma (custom-made icons)
- Icon font generator: <https://icomoon.io/>
