//
//  DashboardView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

public struct DashboardView: View {
    @StateObject private var controller = DashboardController()

    public init() {}

    public var body: some View {
        Group {
            switch controller.state {
            case .loading:
                LoadingDashboardStateView()
            case .loaded(let data):
                LoadedDashboardStateView(data: data, controller: controller)
            case .empty:
                EmptyDashboardStateView(controller: controller)
            case .error(let errorMessage):
                ErrorDashboardStateView(errorMessage: errorMessage, controller: controller)
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        // Bell action
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Button {
                        // Profile action
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 26, height: 26)
                            Image(systemName: "person.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .task {
            await controller.fetchDashboardData()
        }
    }
}

final class DashboardHeaderViewState: ObservableObject {
    @Published var selectedPeriod: TimePeriodOption = .thisMonth
    @Published var showingCustomRangeSheet: Bool = false
}

// MARK: - Loaded Content View

struct LoadedDashboardStateView: View {
    let data: DashboardData
    @ObservedObject var controller: DashboardController
    @StateObject private var headerViewState = DashboardHeaderViewState()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CommonSpacing.sectionSpacing) {
                // Header Area: Greeting, Business Overview & Unified Filter Button
                VStack(alignment: .leading, spacing: CommonSpacing.elementSpacing) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning,")
                                .font(CommonFont.greetingSubtitle)
                                .foregroundColor(.secondary)

                            Text("Business Overview")
                                .font(CommonFont.dashboardTitle)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        // Single Unified Filter Context Menu
                        Menu {
                            Picker("Time Period", selection: $headerViewState.selectedPeriod) {
                                Text("Today").tag(TimePeriodOption.today)
                                Text("This Week").tag(TimePeriodOption.thisWeek)
                                Text("This Month").tag(TimePeriodOption.thisMonth)
                                Text("This Quarter").tag(TimePeriodOption.thisQuarter)
                                Text("This Year").tag(TimePeriodOption.thisYear)
                            }
                            .pickerStyle(.inline)

                            Divider()

                            Button {
                                headerViewState.showingCustomRangeSheet = true
                            } label: {
                                Label {
                                    Text(headerViewState.selectedPeriod.isCustom ? headerViewState.selectedPeriod.title : "Custom Range...")
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(headerViewState.selectedPeriod.title)
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .shadow(color: Color.blue.opacity(0.18), radius: 4, x: 0, y: 2)
                        }
                        .onChange(of: headerViewState.selectedPeriod) { _ in
                            Task {
                                await controller.fetchDashboardData()
                            }
                        }
                        .sheet(isPresented: $headerViewState.showingCustomRangeSheet) {
                            CustomDateRangeSheet(
                                initialOption: headerViewState.selectedPeriod,
                                onApply: { customOption in
                                    headerViewState.selectedPeriod = customOption
                                }
                            )
                            .presentationDetents([.height(320), .medium])
                            .presentationCornerRadius(20)
                        }
                    }
                }

                // 1. Priority Alerts
                if let alerts = data.alertBanners, !alerts.isEmpty {
                    DashboardAlertSection(alerts: alerts)
                }

                // 2. Key Metrics Grid
                if let kpis = data.kpis {
                    KeyMetricsGridSection(kpis: kpis)
                }

                // 3. Performance, Pipeline, Payment Collection, Approvals, Customers, Dealers
                DashboardListSection(
                    performanceMetrics: data.performanceMetrics,
                    pipeline: data.ordersPipeline,
                    paymentCollection: data.paymentCollection,
                    pendingApprovals: data.pendingApprovals,
                    topCustomers: data.topCustomers,
                    dealerPerformance: data.dealerPerformance
                )
            }
            .padding(.horizontal, CommonSpacing.pageMargin)
            .padding(.top, 12)
            .padding(.bottom, DeviceInfo.isPad ? 32 : 56)
            .frame(maxWidth: DeviceInfo.isPad ? 1040 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(CommonColor.background)
        .refreshable {
            await controller.fetchDashboardData()
        }
    }
}

// MARK: - State Views

struct LoadingDashboardStateView: View {
    var body: some View {
        VStack(spacing: CommonSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text(ConstantString.loadingDashboard)
                .font(CommonFont.subheadline)
                .foregroundColor(CommonColor.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CommonColor.background)
    }
}

struct EmptyDashboardStateView: View {
    @ObservedObject var controller: DashboardController

    var body: some View {
        VStack(spacing: CommonSpacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(CommonColor.secondaryText)

            Text(ConstantString.emptyTitle)
                .font(CommonFont.title2)
                .foregroundColor(CommonColor.primaryText)

            Text(ConstantString.emptyMessage)
                .font(CommonFont.body)
                .foregroundColor(CommonColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await controller.fetchDashboardData()
                }
            } label: {
                Label(ConstantString.refresh, systemImage: "arrow.clockwise")
                    .font(CommonFont.subheadline)
                    .bold()
                    .padding(.horizontal, CommonSpacing.lg)
                    .padding(.vertical, CommonSpacing.sm)
                    .foregroundColor(.white)
                    .background(CommonColor.primary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CommonColor.background)
    }
}

struct ErrorDashboardStateView: View {
    let errorMessage: String
    @ObservedObject var controller: DashboardController

    var body: some View {
        VStack(spacing: CommonSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(CommonColor.danger)

            Text(ConstantString.errorTitle)
                .font(CommonFont.title2)
                .foregroundColor(CommonColor.primaryText)

            Text(errorMessage)
                .font(CommonFont.body)
                .foregroundColor(CommonColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await controller.fetchDashboardData()
                }
            } label: {
                Label(ConstantString.retry, systemImage: "arrow.clockwise")
                    .font(CommonFont.subheadline)
                    .bold()
                    .padding(.horizontal, CommonSpacing.lg)
                    .padding(.vertical, CommonSpacing.sm)
                    .foregroundColor(.white)
                    .background(CommonColor.primary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CommonColor.background)
    }
}
