//
//  AssetMonthlyView.swift
//  QingmuAccount
//  首页「资产」页：当月所有账户的进出项（汇总 + 按账户分组的流水）。
//  Created by 周荥马 on 2026/8/13.
//

import SwiftUI

struct AssetMonthlyView: View {
    @EnvironmentObject var globalModel: GlobalModel

    @State private var year: Int = DateUtils.findComponentsOfDate([.year], date: Date()).year ?? 2026
    @State private var month: Int = DateUtils.findComponentsOfDate([.month], date: Date()).month ?? 1
    @State private var accounts: [AssetAccountModel] = []
    @State private var records: [AssetAccountRecordModel] = []
    @State private var balanceMap: [String: [(currency: String, totalCents: Int64)]] = [:]
    @State private var expandedAccounts: Set<String> = []
    @State private var showDatePicker = false
    @State private var datePickerType = DatePickerType.YM
    @State private var datePickerValue = DatePickerValue()
    @State private var showAlter = false
    @State private var alterConfig = AlertComponentConfig(desc: "操作失败！")
    // 账户明细弹窗
    @State private var showDetail = false
    @State private var detailAccountId: String = ""
    @State private var detailRecords: [AssetAccountRecordModel] = []
    @State private var detailAccount: AssetAccountModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                if accounts.isEmpty {
                    emptyView
                } else {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // 资产汇总（吸顶）
                        Section {
                            AssetSummaryComponent(accounts: accounts, balanceMap: balanceMap, onAccountChanged: { loadData() })
                                .padding(.horizontal, 15)
                                .padding(.top, 10)
                                .padding(.bottom, 12)
                        } header: {
                            sectionHeader("资产汇总")
                        }
                        // 当月记录（吸顶标题 + 年月切换一起置顶）
                        Section {
                            if records.isEmpty {
                                emptyFlowView
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(groupedAccounts(), id: \.id) { group in
                                        accountGroupCard(group)
                                    }
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 6)
                                .padding(.bottom, 24)
                            }
                        } header: {
                            VStack(spacing: 0) {
                                sectionHeader("当月记录")
                                monthHeader
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 8)
                            }
                            .background(Color("ViewBackgroundColor"))
                        }
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("ViewBackgroundColor"))
        .ignoresSafeArea()
        .onAppear {
            loadData()
        }
        .onChange(of: year) { _ in loadRecords() }
        .onChange(of: month) { _ in loadRecords() }
        .selfDatePicker(showState: $showDatePicker, type: $datePickerType, param: $datePickerValue, sureAction: { newValue in
            guard let y = newValue.year, let m = newValue.month else { return }
            let cur = currentYM
            if y > cur.year || (y == cur.year && m > cur.month) {
                year = cur.year
                month = cur.month
            } else {
                year = y
                month = m
            }
        })
        .sheet(isPresented: $showDetail) {
            accountDetailSheet
        }
        .selfAlter(showState: $showAlter, config: alterConfig)
    }

    // MARK: - 月份切换

    private var monthHeader: some View {
        HStack {
            Button {
                keyFeedback(0)
                switchMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("FontColor"))
            }
            Spacer()
            Text("\(String(year))年\(String(format: "%02d", month))月")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("FontColor"))
                .onTapGesture {
                    keyFeedback()
                    datePickerValue.year = year
                    datePickerValue.month = month
                    showDatePicker = true
                }
            Spacer()
            Button {
                keyFeedback(0)
                switchMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(canGoNext ? Color("FontColor") : Color("FontColor").opacity(0.3))
            }
            .disabled(!canGoNext)
        }
    }

    /// 是否还能切换到下个月（当前已是当月时不可再往后）
    private var canGoNext: Bool {
        let cur = currentYM
        return year < cur.year || (year == cur.year && month < cur.month)
    }

    private func switchMonth(by delta: Int) {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        guard let base = Calendar.current.date(from: comps),
              let target = Calendar.current.date(byAdding: .month, value: delta, to: base) else { return }
        let c = Calendar.current.dateComponents([.year, .month], from: target)
        let ty = c.year ?? year
        let tm = c.month ?? month
        let cur = currentYM
        // 不允许切到未来月份
        if ty > cur.year || (ty == cur.year && tm > cur.month) {
            year = cur.year
            month = cur.month
        } else {
            year = ty
            month = tm
        }
    }

    private var currentYM: (year: Int, month: Int) {
        let c = Calendar.current.dateComponents([.year, .month], from: Date())
        return (c.year ?? 2026, c.month ?? 1)
    }

    // MARK: - 按币型的收入/支出统计

    private struct CurrencyIncomeExpense: Identifiable {
        let code: String
        var incomeCents: Int64 = 0
        var expenseCents: Int64 = 0
        var id: String { code }
        var netCents: Int64 { incomeCents - expenseCents }
    }

    // MARK: - 按账户分组

    private struct AssetAccountGroup: Identifiable {
        let account: AssetAccountModel
        let records: [AssetAccountRecordModel]
        var id: String { account.id.uuidString }

        var incomeCents: Int64 {
            records.filter { $0.moneyCents > 0 }.reduce(Int64(0)) { $0 + $1.moneyCents }
        }
        var expenseCents: Int64 {
            records.filter { $0.moneyCents < 0 }.reduce(Int64(0)) { $0 + abs($1.moneyCents) }
        }
    }

    private func groupedAccounts() -> [AssetAccountGroup] {
        var map: [String: [AssetAccountRecordModel]] = [:]
        for r in records {
            map[r.accountId, default: []].append(r)
        }
        let accountMap = Dictionary(uniqueKeysWithValues: accounts.map { ($0.id.uuidString, $0) })
        return map.keys.compactMap { id -> AssetAccountGroup? in
            guard let account = accountMap[id] else { return nil }
            return AssetAccountGroup(account: account, records: map[id] ?? [])
        }.sorted { $0.records.first?.gmtCreated ?? Date() > $1.records.first?.gmtCreated ?? Date() }
    }

				private func accountGroupCard(_ group: AssetAccountGroup) -> some View {
					VStack(spacing: 10) {
						// 头部：图标 + 名称 + 余额 + 明细按钮
							HStack(spacing: 10) {
								// 点击账户进入详情
								NavigationLink {
									AssetAccountDetailView(accountId: group.account.id.uuidString, onAccountChanged: { loadData() })
										.environmentObject(globalModel)
								} label: {
									HStack(spacing: 10) {
										AssetAccountIconView(icon: group.account.icon, iconSize: 30, textCornerRadius: 10)
											.padding(8)
											.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
										VStack(alignment: .leading, spacing: 4) {
											Text(group.account.name)
												.font(.system(size: 15, weight: .bold))
												.foregroundColor(Color("FontColor"))
												.lineLimit(1)
											if let balances = balanceMap[group.account.id.uuidString], !balances.isEmpty {
												AccountBalanceCarouselHorizontal(balances: balances)
											} else {
												RollingAmountText(cents: group.account.totalCents, font: .system(size: 14, weight: .bold),
												color: group.account.totalCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
											}
										}
									}
									.contentShape(Rectangle())
								}
								.buttonStyle(.plain)
							Spacer()
							// 明细按钮
							Button {
								keyFeedback()
								showDetail(account: group.account)
							} label: {
								Image(systemName: "list.bullet.rectangle")
									.font(.system(size: 18, weight: .bold))
									.foregroundColor(Color("DefaultButtonBackgroud"))
									.frame(width: 44, height: 44)
									.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
							}
							.buttonStyle(.plain)
						}
						// 账户内按币种收支统计
						let flows = accountCurrencyFlows(group)
						if !flows.isEmpty {
							Divider().overlay(Color("MainShadowColor").opacity(0.1))
							ForEach(flows) { flow in
								HStack(spacing: 10) {
									Text(AssetCurrency.name(of: flow.code))
										.font(.system(size: 13, weight: .bold))
										.foregroundColor(Color("FontColor"))
										.lineLimit(1)
									Text(flow.code)
										.font(.system(size: 10, weight: .bold))
										.foregroundColor(.secondary)
									Spacer()
									Text("收 +\(money(flow.incomeCents))")
										.font(.system(size: 13, weight: .bold))
										.foregroundColor(Color("DefaultButtonBackgroud"))
									Text("支 -\(money(flow.expenseCents))")
										.font(.system(size: 13, weight: .bold))
										.foregroundColor(Color("RedColor"))
								}
							}
						}
					}
					.padding(12)
					.background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 14))
					.overlay(
						RoundedRectangle(cornerRadius: 14)
							.stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
					)
					.shadow(color: Color("MainShadowColor").opacity(0.08), radius: 6, x: 0, y: 3)
				}

				/// 账户当月各币种收入/支出
				private func accountCurrencyFlows(_ group: AssetAccountGroup) -> [CurrencyIncomeExpense] {
					var map: [String: CurrencyIncomeExpense] = [:]
					for r in group.records {
						let code = r.currency.isEmpty ? "CNY" : r.currency
						var s = map[code] ?? CurrencyIncomeExpense(code: code)
						if r.moneyCents >= 0 {
							s.incomeCents += r.moneyCents
						} else {
							s.expenseCents += abs(r.moneyCents)
						}
						map[code] = s
					}
					return map.values.sorted { $0.code < $1.code }
				}

				/// 打开账户明细弹窗
				private func showDetail(account: AssetAccountModel) {
					detailAccount = account
					detailAccountId = account.id.uuidString
					detailRecords = []
					showDetail = true
				}

				/// 账户收支明细弹窗（全部记录，时间倒序）
				private var accountDetailSheet: some View {
					VStack(spacing: 0) {
						SheetHeaderComponent(title: detailAccount?.name ?? "账户明细")
						Text("\(String(year))年\(String(format: "%02d", month))月 · \(detailRecords.count) 笔")
							.font(.system(size: 12))
							.foregroundColor(.secondary)
							.padding(.top, 2)
							.padding(.bottom, 10)

						if detailRecords.isEmpty {
							Spacer()
							Text("暂无记录")
								.font(.system(size: 14))
								.foregroundColor(.secondary)
							Spacer()
						} else {
							ScrollView(showsIndicators: false) {
								LazyVStack(alignment: .leading, spacing: 8) {
									ForEach(groupedDetailRecords, id: \.key) { group in
										monthGroupHeader(group.key)
										ForEach(group.records, id: \.id) { record in
											detailRecordRow(record)
										}
									}
								}
								.padding(.horizontal, 15)
								.padding(.bottom, 20)
							}
						}
					}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
				.background(Color("ViewBackgroundColor"))
				.onAppear {
					if !detailAccountId.isEmpty {
						do {
							detailRecords = try AssetAccountRecordOfCacheService.getMonthlyRecords(accountId: detailAccountId, year: year, month: month)
						} catch {
							detailRecords = []
						}
					}
				}
				}

				/// 明细按年月分组（年月倒序）
				private var groupedDetailRecords: [(key: String, records: [AssetAccountRecordModel])] {
					let groups = Dictionary(grouping: detailRecords) { record -> String in
						let c = Calendar.current.dateComponents([.month, .day], from: record.gmtCreated)
						return "\(String(format: "%02d", c.month ?? 0))月\(String(format: "%02d", c.day ?? 0))日"
					}
					return groups.keys.sorted(by: >).compactMap { key in
						guard let recs = groups[key] else { return nil }
						return (key, recs)
					}
				}

				private func monthGroupHeader(_ text: String) -> some View {
					HStack(spacing: 6) {
						Circle()
							.fill(Color("DefaultButtonBackgroud"))
							.frame(width: 5, height: 5)
						Text(text)
							.font(.system(size: 13, weight: .bold))
							.foregroundColor(.secondary)
						Spacer()
					}
					.padding(.top, 8)
					.padding(.bottom, 2)
				}

				private func detailRecordRow(_ record: AssetAccountRecordModel) -> some View {
					HStack(spacing: 12) {
						Image(systemName: recordTypeIcon(record.changeType))
							.font(.system(size: 15, weight: .bold))
							.foregroundColor(.white)
							.frame(width: 34, height: 34)
							.background(record.moneyCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"), in: RoundedRectangle(cornerRadius: 10))
						VStack(alignment: .leading, spacing: 3) {
							Text(AssetRecordChangeType(rawValue: record.changeType)?.name ?? "变更")
								.font(.system(size: 14, weight: .bold))
								.foregroundColor(Color("FontColor"))
							Text(DateUtils.transDate2String(record.gmtCreated, format: "yyyy-MM-dd HH:mm"))
								.font(.system(size: 11))
								.foregroundColor(.secondary)
							if !record.relatedAccountName.isEmpty {
								Text(record.moneyCents >= 0 ? "来自\(record.relatedAccountName)" : "转至\(record.relatedAccountName)")
									.font(.system(size: 11))
									.foregroundColor(.secondary)
							}
						}
						Spacer()
						VStack(alignment: .trailing, spacing: 2) {
							Text("\(AssetCurrency.symbol(of: record.currency)) \(record.moneyText)")
								.font(.system(size: 15, weight: .bold))
								.foregroundColor(record.moneyCents >= 0 ? Color("DefaultButtonBackgroud") : Color("RedColor"))
							if !record.remark.isEmpty {
								Text(record.remark)
									.font(.system(size: 10))
									.foregroundColor(.secondary)
									.lineLimit(1)
							}
						}
					}
					.padding(.horizontal, 12)
					.frame(minWidth: 0, maxWidth: .infinity)
					.frame(minHeight: 58)
					.background(Color("MainBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color("MainShadowColor").opacity(0.06), lineWidth: 1)
					)
				}

				private func recordTypeIcon(_ type: Int) -> String {
					switch AssetRecordChangeType(rawValue: type) ?? .adjust {
						case .transferIn: return "arrow.down.left"
						case .transferOut: return "arrow.up.right"
						case .transfer: return "arrow.left.arrow.right"
						case .adjust: return "slider.horizontal.3"
					}
				}
    // MARK: - 吸顶标题 / 空态 / 工具

    /// 吸顶标题
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("FontColor"))
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color("ViewBackgroundColor"))
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("本月暂无进出记录")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text("可到「资产账户」中添加账户并记一笔")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    /// 当月无记录的空态
    private var emptyFlowView: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text("本月暂无进出记录")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func money(_ cents: Int64) -> String {
        return SQLiteManager.money(fromCents: cents)
    }

    /// 加载账户与分币种余额（与月份无关），再加载当月流水
    private func loadData() {
        do {
            let accts = try AssetAccountOfCacheService.getAccounts(cache: globalModel)
            let balances = (try? AssetAccountBalanceService.getAllBalances()) ?? [:]
            accounts = accts
            balanceMap = balances
        } catch {
            alterConfig.desc = "加载数据失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
            return
        }
        loadRecords()
    }

    /// 仅加载当前月份的流水记录（切换月份时资产汇总不刷新）
    private func loadRecords() {
        do {
            let recs = try AssetAccountRecordOfCacheService.getMonthlyRecords(year: year, month: month)
            withAnimation(.easeInOut(duration: 0.3)) {
                records = recs
            }
        } catch {
            alterConfig.desc = "加载数据失败"
            alterConfig.topBarColorStyle = .RED
            alterConfig.showCancelButton = false
            alterConfig.sureButtonName = "知道了"
            showAlter = true
        }
    }
}
