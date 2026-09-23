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
    @Published var showingPeriodSheet: Bool = false
}

// MARK: - Loaded Content View

struct LoadedDashboardStateView: View {
    let data: DashboardData
    @ObservedObject var controller: DashboardController
    @StateObject private var headerViewState = DashboardHeaderViewState()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CommonSpacing.sectionSpacing) {
                // Header Area: Greeting & Business Overview
                VStack(alignment: .leading, spacing: CommonSpacing.elementSpacing) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning,")
                                .font(CommonFont.greetingSubtitle)
                                .foregroundColor(.secondary)

                            Text("Business Overview")
                                .font(CommonFont.dashboardTitle)
                                .foregroundColor(.primary)
                        }

                        Spacer()
                    }

                    // Filter Row Below Header
                    HStack {
                        // Month / Period Selection Button
                        Button {
                            headerViewState.showingPeriodSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(headerViewState.selectedPeriod.title)
                                    .font(CommonFont.secondaryText)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(CommonFont.captionBadge)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(CommonColor.cardBackground)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(CommonColor.border, lineWidth: 0.8)
                            )
                        }
                        .sheet(isPresented: $headerViewState.showingPeriodSheet) {
                            PeriodFilterSheet(
                                selectedOption: $headerViewState.selectedPeriod,
                                onSelect: { option in
                                    Task {
                                        await controller.fetchDashboardData()
                                    }
                                }
                            )
                            .presentationDetents([.height(350)])
                            .presentationCornerRadius(20)
                        }

                        Spacer()

                        // Filter Pill Button
                        Button {
                            // Filter Action
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(CommonFont.buttonText)
                                Text("Filter")
                                    .font(CommonFont.buttonText)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 5, height: 5)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(Capsule())
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
