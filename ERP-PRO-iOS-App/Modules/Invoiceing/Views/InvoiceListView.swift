//
//  InvoiceListView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import PDFKit

/// Main Accounts Receivable & Invoice management view supporting iPhone card list, iPad multi-column table view, and Mac Catalyst navigation split inspector.
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
                ProgressView("Loading Invoices & Accounts Receivable...")
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
        .sheet(isPresented: $controller.isShowingNewInvoiceSheet) {
            NewInvoiceSheetView()
        }
        .sheet(isPresented: $controller.isShowingPDFPreview) {
            if let inv = controller.selectedInvoice ?? controller.invoices.first {
                InvoicePDFPreviewView(invoice: inv)
            }
        }
        .sheet(isPresented: $controller.isShowingThermalPrintSheet) {
            if let inv = controller.selectedInvoice ?? controller.invoices.first {
                InvoiceThermalPrintView(invoice: inv)
            }
        }
    }
}

// MARK: - 4 KPI Summary Cards Header Component

struct KPIDashboardHeaderView: View {
    @ObservedObject var controller: InvoiceController
    @State private var currentPage: Int = 0

    var body: some View {
        VStack(spacing: 6) {
            TabView(selection: $currentPage) {
                // Page 0: First 2 KPI Cards
                HStack(spacing: 10) {
                    card1.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                    card2.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                }
                .padding(.horizontal, CommonSpacing.pageMargin)
                .tag(0)

                // Page 1: Second 2 KPI Cards
                HStack(spacing: 10) {
                    card3.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                    card4.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                }
                .padding(.horizontal, CommonSpacing.pageMargin)
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 108)

            // Page Indicator Dots
            HStack(spacing: 6) {
                Capsule()
                    .fill(currentPage == 0 ? Color.blue : Color.gray.opacity(0.35))
                    .frame(width: currentPage == 0 ? 16 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)

                Capsule()
                    .fill(currentPage == 1 ? Color.blue : Color.gray.opacity(0.35))
                    .frame(width: currentPage == 1 ? 16 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.vertical, 6)
    }

    private var card1: some View {
        KPICard(
            title: ConstantString.totalOutstanding,
            value: CommonCurrencyFormatter.format(controller.totalOutstandingAmount, currencyCode: "INR"),
            subtitle: "\(controller.totalOutstandingCount) Unpaid (\(controller.outstandingPercentageText))",
            icon: "exclamationmark.circle.fill",
            accentColor: .orange
        )
    }

    private var card2: some View {
        KPICard(
            title: ConstantString.overdueAmount,
            value: CommonCurrencyFormatter.format(controller.overdueAmount, currencyCode: "INR"),
            subtitle: "\(controller.overdueCount) Overdue",
            icon: "clock.badge.exclamationmark.fill",
            accentColor: controller.overdueAmount > 0 ? .red : .gray,
            isWarning: controller.overdueAmount > 0
        )
    }

    private var card3: some View {
        KPICard(
            title: ConstantString.dueThisWeek,
            value: CommonCurrencyFormatter.format(controller.dueThisWeekAmount, currencyCode: "INR"),
            subtitle: "\(controller.dueThisWeekCount) Dues in 7 days",
            icon: "calendar.badge.clock",
            accentColor: .blue
        )
    }

    private var card4: some View {
        KPICard(
            title: ConstantString.paidThisMonth,
            value: CommonCurrencyFormatter.format(controller.paidThisMonthAmount, currencyCode: "INR"),
            subtitle: "↑ \(String(format: "%.1f", controller.collectionRatePercentage))% rate",
            icon: "arrow.up.forward.circle.fill",
            accentColor: .green,
            badgeText: "↑ \(String(format: "%.1f", controller.collectionRatePercentage))%"
        )
    }
}

struct KPICard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    var isWarning: Bool = false
    var badgeText: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header Row: Title Only (Icon removed)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isWarning ? .red : .secondary)
                .lineLimit(1)

            Spacer(minLength: 2)

            // Primary Amount Value
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isWarning ? .red : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            // Bottom Subtitle Badge
            HStack {
                Text(subtitle)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isWarning ? .red : .secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isWarning ? Color.red.opacity(0.12) : Color(uiColor: .tertiarySystemFill))
                    .clipShape(Capsule())

                Spacer()
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CommonSpacing.cardCornerRadius, style: .continuous)
                .stroke(isWarning ? Color.red.opacity(0.3) : CommonColor.cardBorder, lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// MARK: - 19 Status Segmented Filter Bar

struct StatusSegmentedFilterBar: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(InvoiceFilterChip.allCases) { chip in
                    let count = controller.countForFilterChip(chip)
                    let isSelected = controller.selectedFilterChip == chip

                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            controller.selectedFilterChip = chip
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(chip.rawValue)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))

                            Text("\(count)")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(isSelected ? Color.white.opacity(0.3) : Color(uiColor: .tertiarySystemFill))
                                .foregroundColor(isSelected ? .white : .secondary)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.blue : Color(uiColor: .secondarySystemBackground))
                        .foregroundColor(isSelected ? .white : .primary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CommonSpacing.pageMargin)
            .padding(.vertical, 6)
        }
    }
}

// MARK: - iPhone / Compact Layout View

struct CompactInvoiceLayoutView: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. KPI Cards Header (2x2 grid on iPhone)
                KPIDashboardHeaderView(controller: controller)

                // 2. 19 Status Filter Bar
                StatusSegmentedFilterBar(controller: controller)

                // 3. Search & Sort Bar
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField(ConstantString.searchInvoicePlaceholder, text: $controller.searchText)
                            .font(CommonFont.body)
                            .autocorrectionDisabled()
                        if !controller.searchText.isEmpty {
                            Button(action: { controller.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(10)

                    Button(action: {
                        withAnimation {
                            controller.isFilterPopoverPresented.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                                .background(Circle().fill(controller.activeFilterCount > 0 ? Color.blue.opacity(0.15) : Color(uiColor: .systemBackground)))
                                .frame(width: 36, height: 36)
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(controller.activeFilterCount > 0 ? .blue : .primary)
                        }
                    }
                    .popover(isPresented: $controller.isFilterPopoverPresented, arrowEdge: .top) {
                        InvoiceFilterView(controller: controller)
                    }
                }
                .padding(.horizontal, CommonSpacing.pageMargin)
                .padding(.vertical, 6)

                // 4. Invoices List / Card View
                if controller.filteredInvoices.isEmpty {
                    EmptyInvoiceStateView()
                } else {
                    List {
                        ForEach(controller.filteredInvoices) { item in
                            if controller.isEditingMode {
                                CompactInvoiceCardRow(item: item, controller: controller)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            } else {
                                ZStack {
                                    CompactInvoiceCardRow(item: item, controller: controller)
                                    NavigationLink(destination: InvoiceDetailView(controller: controller, invoice: item)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }

            // Floating Bulk Toolbar when 1+ selected
            if !controller.selectedInvoiceIDs.isEmpty {
                BulkActionToolbarView(controller: controller)
                    .padding(.bottom, 12)
            }
        }
        .navigationTitle(ConstantString.invoices)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if controller.isEditingMode {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: controller.toggleSelectAll) {
                        Text(controller.selectedInvoiceIDs.count == controller.filteredInvoices.count && !controller.filteredInvoices.isEmpty ? ConstantString.deselectAll : ConstantString.selectAll)
                            .font(CommonFont.subheadline)
                            .bold()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            controller.isEditingMode = false
                            controller.selectedInvoiceIDs.removeAll()
                        }
                    }) {
                        Text(ConstantString.done)
                            .font(CommonFont.headline)
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                controller.isEditingMode = true
                            }
                        }) {
                            Text(ConstantString.edit)
                                .font(CommonFont.subheadline)
                        }

                        Button(action: { controller.isShowingNewInvoiceSheet = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - iPhone Card Row Component

struct CompactInvoiceCardRow: View {
    let item: Invoice
    @ObservedObject var controller: InvoiceController

    var isSelected: Bool {
        controller.selectedInvoiceIDs.contains(item.invoiceId)
    }

    var body: some View {
        HStack(spacing: 12) {
            if controller.isEditingMode {
                Button(action: { controller.toggleSelection(item.invoiceId) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }

            // Customer Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(item.customerInitials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.blue)
            }

            // Middle Column (Invoice ID, Customer Name, Due Date)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.invoiceId)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)

                Text(item.customerName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Due: \(item.formattedDueDate)")
                    .font(.system(size: 11))
                    .foregroundColor(item.isOverdue ? .red : .secondary)
            }

            Spacer()

            // Right Column (Status Badge above amount, Total Amount, Balance Due)
            VStack(alignment: .trailing, spacing: 4) {
                InvoiceStatusBadge(status: item.status)

                Text(item.formattedTotal)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                Text("Bal: \(item.formattedBalanceDue)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(item.balanceDue > 0 ? .orange : .green)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - iPadOS & Mac Catalyst Wide Layout View

struct WideInvoiceLayoutView: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        NavigationSplitView {
            // Sidebar List of Filters & Statuses
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                    Text(ConstantString.accountsReceivable)
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .padding()

                Divider()

                // Status Chips List
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(InvoiceFilterChip.allCases) { chip in
                            let count = controller.countForFilterChip(chip)
                            let isSelected = controller.selectedFilterChip == chip

                            Button(action: { controller.selectedFilterChip = chip }) {
                                HStack {
                                    Text(chip.rawValue)
                                        .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                                    Spacer()
                                    Text("\(count)")
                                        .font(.system(size: 12, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(isSelected ? Color.white.opacity(0.3) : Color(uiColor: .tertiarySystemFill))
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.blue : Color.clear)
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                }

                Divider()

                Button(action: { controller.isShowingNewInvoiceSheet = true }) {
                    Label(ConstantString.newInvoice, systemImage: "plus")
                        .font(CommonFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 260, max: 300)
        } content: {
            // Center Column: Table & KPI Dashboard
            VStack(spacing: 0) {
                // KPI Summary Cards
                KPIDashboardHeaderView(controller: controller)

                Divider()

                // Search & Column Toggle Toolbar
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField(ConstantString.searchInvoicePlaceholder, text: $controller.searchText)
                            .font(.system(size: 14))
                        if !controller.searchText.isEmpty {
                            Button(action: { controller.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(10)
                    .frame(maxWidth: 320)

                    Spacer()

                    // Optional Column Selection Menu
                    Menu {
                        Text("Show/Hide Columns")
                            .font(CommonFont.caption)
                        ForEach(OptionalColumn.allCases) { col in
                            Button(action: {
                                if controller.visibleOptionalColumns.contains(col) {
                                    controller.visibleOptionalColumns.remove(col)
                                } else {
                                    controller.visibleOptionalColumns.insert(col)
                                }
                            }) {
                                Label(col.rawValue, systemImage: controller.visibleOptionalColumns.contains(col) ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Label("Columns", systemImage: "slider.horizontal.3")
                            .font(CommonFont.subheadline)
                    }

                    // Sort Menu
                    Menu {
                        Picker("Sort By", selection: $controller.sortField) {
                            ForEach(InvoiceSortField.allCases) { f in
                                Text(f.rawValue).tag(f)
                            }
                        }
                        Button(action: controller.toggleSortOrder) {
                            Label(controller.sortAscending ? "Ascending" : "Descending", systemImage: controller.sortAscending ? "arrow.up" : "arrow.down")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                    }

                    Button(action: {
                        withAnimation {
                            controller.isFilterPopoverPresented.toggle()
                        }
                    }) {
                        Image(systemName: "funnel")
                            .foregroundColor(controller.activeFilterCount > 0 ? .blue : .primary)
                    }
                    .popover(isPresented: $controller.isFilterPopoverPresented, arrowEdge: .top) {
                        InvoiceFilterView(controller: controller)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground))

                Divider()

                // Multi-Column Data Table View
                if controller.filteredInvoices.isEmpty {
                    EmptyInvoiceStateView()
                } else {
                    Table(controller.filteredInvoices, selection: $controller.selectedInvoiceIDs) {
                        TableColumn("Invoice ID") { inv in
                            HStack {
                                Text(inv.invoiceId)
                                    .font(.system(size: 13, weight: .bold))
                                Spacer()
                            }
                        }
                        .width(min: 120, ideal: 140)

                        TableColumn("Customer") { inv in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 24, height: 24)
                                    .overlay(Text(inv.customerInitials).font(.system(size: 10, weight: .bold)).foregroundColor(.blue))
                                Text(inv.customerName)
                                    .font(.system(size: 13))
                            }
                        }
                        .width(min: 160, ideal: 200)

                        TableColumn("Issue Date") { inv in
                            Text(inv.formattedIssueDate)
                                .font(.system(size: 12))
                        }
                        .width(min: 90, ideal: 110)

                        TableColumn("Due Date") { inv in
                            Text(inv.formattedDueDate)
                                .font(.system(size: 12))
                                .foregroundColor(inv.isOverdue ? .red : .primary)
                        }
                        .width(min: 90, ideal: 110)

                        TableColumn("Status") { inv in
                            Menu {
                                ForEach(InvoiceStatus.allCases) { st in
                                    Button(st.rawValue) {
                                        controller.updateStatus(for: inv, newStatus: st)
                                    }
                                }
                            } label: {
                                InvoiceStatusBadge(status: inv.status)
                            }
                        }
                        .width(min: 110, ideal: 130)

                        TableColumn("Total") { inv in
                            Text(inv.formattedTotal)
                                .font(.system(size: 13, weight: .bold))
                        }
                        .width(min: 100, ideal: 120)

                        TableColumn("Balance") { inv in
                            Text(inv.formattedBalanceDue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(inv.balanceDue > 0 ? .orange : .green)
                        }
                        .width(min: 100, ideal: 120)

                        TableColumn("Salesperson") { inv in
                            Text(inv.salesperson ?? "-")
                                .font(.system(size: 12))
                        }
                        .width(min: 100, ideal: 120)

                        TableColumn("PO #") { inv in
                            Text(inv.poReference ?? "-")
                                .font(.system(size: 12))
                        }
                        .width(min: 90, ideal: 110)
                    }
                    .onChange(of: controller.selectedInvoiceIDs) { _, newSelection in
                        if let firstID = newSelection.first, let found = controller.invoices.first(where: { $0.invoiceId == firstID }) {
                            controller.selectedInvoice = found
                        }
                    }
                }

                // Bulk Action Floating Toolbar
                if !controller.selectedInvoiceIDs.isEmpty {
                    BulkActionToolbarView(controller: controller)
                        .padding(.bottom, 12)
                }
            }
            .navigationSplitViewColumnWidth(min: 500, ideal: 680)
        } detail: {
            // 3rd Column: Detail Inspector Panel
            if let selected = controller.selectedInvoice ?? controller.filteredInvoices.first {
                InvoiceDetailView(controller: controller, invoice: selected)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select an invoice to inspect details")
                        .font(CommonFont.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Multi-Select Bulk Action Toolbar Component

struct BulkActionToolbarView: View {
    @ObservedObject var controller: InvoiceController

    var body: some View {
        HStack(spacing: 16) {
            Text("\(controller.selectedInvoiceIDs.count) selected")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)

            Divider()
                .frame(height: 20)
                .background(Color.white.opacity(0.4))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: {
                        controller.bulkUpdateStatus(newStatus: .sent)
                    }) {
                        Label("Send Email", systemImage: "paperplane.fill")
                    }

                    Button(action: {
                        controller.bulkUpdateStatus(newStatus: .sent)
                    }) {
                        Label("Send Reminder", systemImage: "bell.fill")
                    }

                    Button(action: {
                        controller.isShowingPDFPreview = true
                    }) {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }

                    Button(action: {
                        controller.bulkUpdateStatus(newStatus: .paid)
                    }) {
                        Label("Mark Paid", systemImage: "checkmark.circle.fill")
                    }

                    Button(action: {
                        controller.bulkUpdateStatus(newStatus: .archived)
                    }) {
                        Label("Archive", systemImage: "archivebox.fill")
                    }

                    Button(action: {
                        controller.bulkDelete()
                    }) {
                        Label("Delete", systemImage: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
            }

            Button(action: { controller.selectedInvoiceIDs.removeAll() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.85))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
}

// MARK: - Reusable Status Badge Component

struct InvoiceStatusBadge: View {
    let status: InvoiceStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: 10))
            Text(status.rawValue)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(status.badgeTextColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.badgeBackgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Empty State View Component

struct EmptyInvoiceStateView: View {
    var body: some View {
        VStack(spacing: CommonSpacing.md) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(ConstantString.noInvoicesFound)
                .font(CommonFont.title2)
                .foregroundColor(.primary)
            Text(ConstantString.noInvoicesMessage)
                .font(CommonFont.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - New Invoice Sheet Placeholder View

struct NewInvoiceSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var customerName: String = ""
    @State private var totalAmountText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Customer Details") {
                    TextField("Customer Name", text: $customerName)
                }

                Section("Invoice Total") {
                    TextField("Total Amount (₹)", text: $totalAmountText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Invoice Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .font(CommonFont.headline)
                }
            }
        }
    }
}

