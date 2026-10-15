# QingmuAccount (青木账本)

[English](README_en.md) | [中文](README.md)

A **fully offline** iOS bookkeeping app built with SwiftUI. No network requests, no iCloud dependency — all data is stored locally in an on-device SQLite database. Supports dark mode, multiple ledgers, multiple currencies, budgets, statistical charts, and complete asset/liability management.

> Deployment target iOS 17.6, iPhone only, Swift 5, **zero third-party dependencies**.

---

## Screenshots

<table>
  <tr>
    <td align="center"><img src="doc/01-home-list.png" width="220"><br><sub>Ledger Home · List View</sub></td>
    <td align="center"><img src="doc/02-home-calendar.png" width="220"><br><sub>Ledger Home · Calendar View</sub></td>
    <td align="center"><img src="doc/03-statistics.png" width="220"><br><sub>Statistics · Trend &amp; Category Split</sub></td>
    <td align="center"><img src="doc/04-budget.png" width="220"><br><sub>Current Month Budget</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="doc/05-budget-history.png" width="220"><br><sub>Budget History</sub></td>
    <td align="center"><img src="doc/06-assets.png" width="220"><br><sub>Asset Summary &amp; Monthly Records</sub></td>
    <td align="center"><img src="doc/07-account-picker.png" width="220"><br><sub>Account Picker</sub></td>
    <td align="center"><img src="doc/08-add-account.png" width="220"><br><sub>Add Asset Account</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="doc/09-overview.png" width="220"><br><sub>Overview · All Ledgers</sub></td>
    <td align="center"><img src="doc/10-ledger-edit.png" width="220"><br><sub>Edit Ledger</sub></td>
    <td></td>
    <td></td>
  </tr>
</table>

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

## How to Install the IPA

The IPA provided by this project is an **unsigned clean build**. Users must sign it with their own Apple ID, a paid developer account, or a third-party certificate before installing.

### 1. Desktop Tools (sign and install over a USB cable from PC/Mac)

- **Aisi Assistant (Windows/Mac)**: The most widely used device-management tool in China, and the lowest barrier to entry. It has a built-in IPA signing feature that supports Apple ID re-signing or importing personal/enterprise certificates, and installs the signed app to the phone in one click.
- **Sideloadly (Windows/Mac)**: The mainstream overseas tool for clean personal sideloading. Drag the IPA in, enter your Apple ID, and it signs and installs automatically; it also supports injecting tweaks (.dylib/.deb).
- **AltStore / AltServer (Windows/Mac)**: Runs as a server on your computer and automatically refreshes your apps over the local Wi-Fi. A free personal account can hold 3 apps at once, and re-signing is wireless as long as the computer and phone are on the same network.
- **Xcode (Mac only)**: Apple's official developer tool. Users can create a blank project, use a free or paid developer account, and sideload the IPA onto a connected iOS device.
- **Apple Configurator 2 (Mac only)**: Apple's official enterprise and device deployment tool. Built for managing iOS devices in bulk; it can distribute a valid IPA package by dragging it onto a connected device.
- **iFunbox / i4 Tools (Windows/Mac)**: Traditional iOS file and app transfer tools, mainly for installing already-validly-signed IPA packages or installing apps on jailbroken devices.

### 2. On-device Tools (fully computer-free, operated directly on iPhone)

- **ESign (全能签)**: A widely popular iOS local signing and installing tool in China. It imports p12 certificates and mobileprovision profiles, or self-signs with an Apple ID, and supports multiple app instances, bundle-ID changes, and tweak injection.
- **EasySign (轻松签)**: A lightweight yet powerful on-device signing tool. It supports one-tap signing, dynamic library injection, and changing app icons and names, with a clean, ad-free interface.
- **SideStore**: A phone-based sideloading tool that evolved from AltStore. It uses a local WireGuard VPN so users can refresh their personal Apple ID certificate and install the IPA entirely on the phone, with no computer involved.
- **TrollStore (巨魔商店)**: The legendary signature-free installer. It exploits specific low-level iOS vulnerabilities (supported on certain iOS versions between 14.0 and 17.0). IPAs installed through it need no signature at all, never expire, and get the highest app privileges similar to jailbreaking.

### 3. Special Platform Helpers

- **PlayCover (Apple Silicon Mac only)**: If you distribute a game or other mobile app IPA, users on Apple Silicon Macs (M1/M2/M3/M4, etc.) can use PlayCover to install the IPA directly and run it on the Mac, with custom keyboard and mouse mapping support.

---

## About the Icons

- Icon font download: <https://pan.baidu.com/s/1wpGmW57sJhjsfkaxTbAzrw> (code `bi6b`)
- Icon sources: iconpark (most), iconfinder (some), iconfont (a few, all open-source/commercial-use), figma (custom-made icons)
- Icon font generator: <https://icomoon.io/>
