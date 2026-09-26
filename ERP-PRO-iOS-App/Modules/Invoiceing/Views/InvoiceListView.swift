//
//  InvoiceListView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Main Invoice List view supporting iPhone card view, iPad multi-column table view, and Mac Catalyst table/grid views.
public struct InvoiceListView: View {
    @StateObject private var controller = InvoiceController()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init() {}

    private var isWideLayout: Bool {
        DeviceInfo.isPad || DeviceInfo.isMacCatalyst || horizontalSizeClass == .regular
    }

    public var body: some View {
        Group {
            switch controller.state {
            case .loading:
                ProgressView("Loading Invoices...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded, .empty:
                if isWideLayout {
                    WideInvoiceLayoutView(controller: controller)
                } else {
                    CompactInvoiceLayoutView(controller: controller)
                }
            case .error(let message):
                VStack(spacing: CommonSpacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(CommonColor.danger)
                    Text("Error loading invoices")
                        .font(CommonFont.title2)
                    Text(message)
                        .font(CommonFont.body)
                        .foregroundColor(CommonColor.secondaryText)
                    Button("Retry") {
                        Task {
                            await controller.fetchInvoices()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await controller.fetchInvoices()
        }
    }
}

// MARK: - iPhone / Compact Screen Layout

struct CompactInvoiceLayoutView: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Total Revenue Summary Header Card (Matching reference design)
                InvoiceRevenueSummaryCard(controller: controller)

                // Native Full-Width Search Bar below revenue card
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    TextField("Search", text: $controller.searchText)
                        .font(CommonFont.body)
                        .autocorrectionDisabled()
                    if !controller.searchText.isEmpty {
                        Button(action: { controller.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(uiColor: .tertiarySystemFill))
                .cornerRadius(10)
                .padding(.horizontal, CommonSpacing.pageMargin)
                .padding(.top, 8)
                .padding(.bottom, 8)

                // Invoice List Content
                if controller.filteredInvoices.isEmpty {
                    EmptyInvoiceStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(controller.filteredInvoices) { item in
                                CompactInvoiceRowCard(item: item)
                            }
                        }
                        .padding(.horizontal, CommonSpacing.pageMargin)
                        .padding(.top, 12)
                        .padding(.bottom, 84)
                    }
                }
            }

            // Bottom-Right Floating Action Button (+ New Invoice)
            Button(action: { controller.isShowingNewInvoiceSheet = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Invoices")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    // Sort Button (Circular light button)
                    Menu {
                        Picker("Sort By", selection: $controller.sortField) {
                            Text("Date").tag(InvoiceSortField.date)
                            Text("Invoice No.").tag(InvoiceSortField.invoiceNumber)
                            Text("Customer").tag(InvoiceSortField.customerName)
                            Text("Amount").tag(InvoiceSortField.amount)
                        }
                        Button(action: controller.toggleSortOrder) {
                            Label(controller.sortAscending ? "Ascending" : "Descending", systemImage: controller.sortAscending ? "arrow.up" : "arrow.down")
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                                .background(Circle().fill(Color(uiColor: .systemBackground)))
                                .frame(width: 36, height: 36)
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }

                    // Filter Button (Circular light button with blue funnel icon)
                    Menu {
                        Picker("Filter", selection: $controller.selectedFilter) {
                            ForEach(InvoiceFilterOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                                .background(Circle().fill(Color(uiColor: .systemBackground)))
                                .frame(width: 36, height: 36)
                            Image(systemName: "funnel.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $controller.isShowingNewInvoiceSheet) {
            NewInvoiceSheetView()
        }
    }
}

// MARK: - Revenue Summary Card Component

struct InvoiceRevenueSummaryCard: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        HStack(alignment: .center) {
            // Left Info: TOTAL REVENUE & Invoice Count
            VStack(alignment: .leading, spacing: 3) {
                Text("TOTAL REVENUE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(uiColor: .secondaryLabel))

                Text(controller.totalInvoicesCountText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            .frame(minWidth: 90, alignment: .leading)

            Spacer()

            // Center Pill Capsule: Amount
            Text(controller.totalRevenueText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.14))
                .clipShape(Capsule())

            Spacer()

            // Right Info: Time Period
            Text(controller.revenuePeriodText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(minWidth: 90, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.94, green: 0.94, blue: 0.97))
    }
}

// MARK: - Compact Invoice Row Card

struct CompactInvoiceRowCard: View {
    let item: InvoiceItem

    var body: some View {
        HStack(spacing: 14) {
            // Left Document Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: 48, height: 48)
                Image(systemName: "doc.text")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.secondary)
            }

            // Middle Details Column
            VStack(alignment: .leading, spacing: 3) {
                Text(item.invoiceNumber)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)

                Text(item.customerName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Text(item.date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }

            Spacer(minLength: 8)

            // Right Amount & Status Column
            VStack(alignment: .trailing, spacing: 6) {
                Text(item.formattedAmount)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)

                InvoiceStatusBadge(status: item.status)
            }

            // Right Chevron Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .padding(.leading, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - iPad / Mac Wide Layout

struct WideInvoiceLayoutView: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        HStack(spacing: 0) {
            // Filter Sidebar Panel (iPad / Mac left navigation)
            VStack(alignment: .leading, spacing: 16) {
                // Header Label
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 18))
                    Text("Invoices")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // Category Items
                VStack(spacing: 4) {
                    ForEach(InvoiceFilterOption.allCases) { option in
                        Button(action: { controller.selectedFilter = option }) {
                            HStack(spacing: 12) {
                                Image(systemName: option.iconName)
                                    .font(.system(size: 15))
                                    .frame(width: 20)
                                Text(option.title)
                                    .font(.system(size: 14, weight: controller.selectedFilter == option ? .semibold : .regular))
                                Spacer()
                            }
                            .foregroundColor(controller.selectedFilter == option ? .blue : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(controller.selectedFilter == option ? Color.blue.opacity(0.12) : Color.clear)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)

                Spacer()

                // Bottom Action: + New Invoice
                Button(action: { controller.isShowingNewInvoiceSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("New Invoice")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .padding(.bottom, 16)
            }
            .frame(width: 240)
            .background(Color(uiColor: .secondarySystemBackground))

            Divider()

            // Main Details Content Area
            VStack(spacing: 0) {
                // Top Header Toolbar
                HStack(spacing: 14) {
                    Text("Invoices")
                        .font(.system(size: 22, weight: .bold))

                    Spacer()

                    // Native Search Input Box
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search", text: $controller.searchText)
                            .font(.system(size: 14))
                            .autocorrectionDisabled()
                        if !controller.searchText.isEmpty {
                            Button(action: { controller.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(10)
                    .frame(width: 240)

                    // Filter Context Menu
                    Menu {
                        Picker("Sort By", selection: $controller.sortField) {
                            Text("Date").tag(InvoiceSortField.date)
                            Text("Invoice No.").tag(InvoiceSortField.invoiceNumber)
                            Text("Customer").tag(InvoiceSortField.customerName)
                            Text("Amount").tag(InvoiceSortField.amount)
                        }
                        Button(action: controller.toggleSortOrder) {
                            Label(controller.sortAscending ? "Ascending" : "Descending", systemImage: controller.sortAscending ? "arrow.up" : "arrow.down")
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(9)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .cornerRadius(8)
                    }

                    // View Mode Switcher (List vs Grid on Mac)
                    if DeviceInfo.isMacCatalyst || DeviceInfo.isPad {
                        HStack(spacing: 2) {
                            Button(action: { controller.selectedViewMode = .list }) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(controller.selectedViewMode == .list ? .primary : .secondary)
                                    .padding(7)
                                    .background(controller.selectedViewMode == .list ? Color(uiColor: .systemGray5) : Color.clear)
                                    .cornerRadius(6)
                            }
                            Button(action: { controller.selectedViewMode = .grid }) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(controller.selectedViewMode == .grid ? .primary : .secondary)
                                    .padding(7)
                                    .background(controller.selectedViewMode == .grid ? Color(uiColor: .systemGray5) : Color.clear)
                                    .cornerRadius(6)
                            }
                        }
                        .padding(2)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .cornerRadius(8)
                    }

                    // Plus Action Button
                    Button(action: { controller.isShowingNewInvoiceSheet = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 30, height: 30)
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(uiColor: .systemBackground))

                Divider()

                // Total Revenue Summary Card for Wide View
                InvoiceRevenueSummaryCard(controller: controller)

                Divider()

                // Table or Grid View Content
                if controller.filteredInvoices.isEmpty {
                    EmptyInvoiceStateView()
                } else if controller.selectedViewMode == .grid {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                            ForEach(controller.filteredInvoices) { item in
                                CompactInvoiceRowCard(item: item)
                            }
                        }
                        .padding(24)
                    }
                    .background(Color(uiColor: .systemBackground))
                } else {
                    // Multi-Column Table View
                    VStack(spacing: 0) {
                        // Header Columns
                        HStack(spacing: 12) {
                            Text("")
                                .frame(width: 28)
                            Text("Invoice No.")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 140, alignment: .leading)
                            Text("Customer")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(minWidth: 140, alignment: .leading)
                            Button(action: controller.toggleSortOrder) {
                                HStack(spacing: 4) {
                                    Text("Date")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                    Image(systemName: controller.sortAscending ? "arrow.up" : "arrow.down")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(width: 120, alignment: .leading)
                            Text("Status")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .center)
                            Spacer()
                            Text("Amount")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 110, alignment: .trailing)
                            Text("")
                                .frame(width: 20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(uiColor: .secondarySystemBackground))

                        Divider()

                        // Scrollable Rows
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(controller.filteredInvoices) { item in
                                    WideInvoiceTableRow(item: item)
                                    Divider()
                                        .padding(.leading, 64)
                                }
                            }
                        }
                    }
                    .background(Color(uiColor: .systemBackground))
                }
            }
        }
        .sheet(isPresented: $controller.isShowingNewInvoiceSheet) {
            NewInvoiceSheetView()
        }
    }
}

// MARK: - Table Row Component for iPad / Mac Table Layout

struct WideInvoiceTableRow: View {
    let item: InvoiceItem

    var body: some View {
        HStack(spacing: 12) {
            // Doc icon
            Image(systemName: "doc.text")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(width: 28)

            // Invoice No.
            Text(item.invoiceNumber)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 140, alignment: .leading)

            // Customer
            Text(item.customerName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
                .frame(minWidth: 140, alignment: .leading)

            // Date
            Text(item.date)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)

            // Status
            HStack {
                Spacer()
                InvoiceStatusBadge(status: item.status)
                Spacer()
            }
            .frame(width: 100)

            Spacer()

            // Amount
            Text(item.formattedAmount)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 110, alignment: .trailing)

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .frame(width: 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Reusable Status Badge Component

struct InvoiceStatusBadge: View {
    let status: InvoiceStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(status.badgeTextColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.badgeBackgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - Empty State View

struct EmptyInvoiceStateView: View {
    var body: some View {
        VStack(spacing: CommonSpacing.md) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Invoices Found")
                .font(CommonFont.title2)
                .foregroundColor(.primary)
            Text("Try adjusting your search query or filter options.")
                .font(CommonFont.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - New Invoice Sheet Placeholder

struct NewInvoiceSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
                Text("New Invoice Creation")
                    .font(CommonFont.title2)
                Text("This action opens the new invoice builder workflow.")
                    .font(CommonFont.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
