//
//  SalesDocumentListView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Unified Sales Document Management View driving both Invoices and Sales Orders screens across iPhone, iPad, and Mac Catalyst.
public struct SalesDocumentListView: View {
    @StateObject private var controller: SalesDocumentController
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(documentType: SalesDocumentType) {
        _controller = StateObject(wrappedValue: SalesDocumentController(documentType: documentType))
    }

    private var isWideLayout: Bool {
        DeviceInfo.isPad || DeviceInfo.isMacCatalyst || horizontalSizeClass == .regular
    }

    public var body: some View {
        Group {
            switch controller.state {
            case .loading:
                ProgressView("Loading \(controller.documentType.pluralTitle)...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded, .empty:
                if isWideLayout {
                    WideSalesDocumentLayoutView(controller: controller)
                } else {
                    CompactSalesDocumentLayoutView(controller: controller)
                }
            case .error(let message):
                VStack(spacing: CommonSpacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(CommonColor.danger)
                    Text("Error loading \(controller.documentType.pluralTitle)")
                        .font(CommonFont.title2)
                    Text(message)
                        .font(CommonFont.body)
                        .foregroundColor(CommonColor.secondaryText)
                    Button("Retry") {
                        Task { await controller.fetchDocuments() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await controller.fetchDocuments()
        }
        .sheet(isPresented: $controller.isShowingPDFPreview) {
            if let doc = controller.selectedDocument ?? controller.documents.first {
                SalesDocumentPDFPreviewView(document: doc)
            }
        }
    }
}

// MARK: - 4 KPI Summary Cards Header Component

struct SalesDocumentKPIDashboardHeaderView: View {
    @ObservedObject var controller: SalesDocumentController
    @State private var currentPage: Int = 0

    var body: some View {
        VStack(spacing: 6) {
            TabView(selection: $currentPage) {
                HStack(spacing: 10) {
                    card1.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                    card2.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                }
                .padding(.horizontal, CommonSpacing.pageMargin)
                .tag(0)

                HStack(spacing: 10) {
                    card3.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                    card4.frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                }
                .padding(.horizontal, CommonSpacing.pageMargin)
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 108)

            HStack(spacing: 6) {
                Capsule()
                    .fill(currentPage == 0 ? Color.blue : Color.gray.opacity(0.35))
                    .frame(width: currentPage == 0 ? 16 : 6, height: 6)

                Capsule()
                    .fill(currentPage == 1 ? Color.blue : Color.gray.opacity(0.35))
                    .frame(width: currentPage == 1 ? 16 : 6, height: 6)
            }
        }
        .padding(.vertical, 6)
    }

    private var card1: some View {
        SalesDocumentMetricCardView(
            title: controller.card1Title,
            value: CommonCurrencyFormatter.format(controller.card1Value, currencyCode: "INR"),
            subtitle: controller.card1Subtitle,
            iconName: controller.documentType == .invoice ? "exclamationmark.circle.fill" : "cart.fill",
            accentColor: .blue
        )
    }

    private var card2: some View {
        SalesDocumentMetricCardView(
            title: controller.card2Title,
            value: CommonCurrencyFormatter.format(controller.card2Value, currencyCode: "INR"),
            subtitle: controller.card2Subtitle,
            iconName: "clock.badge.exclamationmark",
            accentColor: .orange,
            isWarning: controller.card2Value > 0
        )
    }

    private var card3: some View {
        SalesDocumentMetricCardView(
            title: controller.card3Title,
            value: CommonCurrencyFormatter.format(controller.card3Value, currencyCode: "INR"),
            subtitle: controller.card3Subtitle,
            iconName: "calendar.badge.clock",
            accentColor: .red
        )
    }

    private var card4: some View {
        SalesDocumentMetricCardView(
            title: controller.card4Title,
            value: CommonCurrencyFormatter.format(controller.card4Value, currencyCode: "INR"),
            subtitle: controller.card4Subtitle,
            iconName: controller.documentType == .invoice ? "arrow.up.forward.circle.fill" : "truck.box.fill",
            accentColor: .green
        )
    }
}

// MARK: - iPhone / Compact Layout View

struct CompactSalesDocumentLayoutView: View {
    @ObservedObject var controller: SalesDocumentController

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                SalesDocumentKPIDashboardHeaderView(controller: controller)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SalesDocumentFilterChip.allCases) { chip in
                            let count = controller.countForFilterChip(chip)
                            let isSelected = controller.selectedFilterChip == chip

                            Button(action: {
                                withAnimation { controller.selectedFilterChip = chip }
                            }) {
                                HStack(spacing: 6) {
                                    Text(chip.rawValue)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                    Text("\(count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(isSelected ? Color.white.opacity(0.3) : Color(uiColor: .tertiarySystemFill))
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

                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search \(controller.documentType.pluralTitle)...", text: $controller.searchText)
                            .font(CommonFont.body)
                    }
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(10)

                    Button(action: { controller.isFilterPopoverPresented.toggle() }) {
                        Image(systemName: "funnel")
                            .foregroundColor(controller.activeFilterCount > 0 ? .blue : .primary)
                    }
                    .popover(isPresented: $controller.isFilterPopoverPresented, arrowEdge: .top) {
                        SalesDocumentFilterView(controller: controller)
                    }
                }
                .padding(.horizontal, CommonSpacing.pageMargin)
                .padding(.vertical, 6)

                if controller.filteredDocuments.isEmpty {
                    ContentUnavailableView(
                        "No \(controller.documentType.pluralTitle) Found",
                        systemImage: controller.documentType.systemIcon,
                        description: Text("No documents match your search criteria.")
                    )
                } else {
                    List {
                        ForEach(controller.filteredDocuments) { doc in
                            SalesDocumentRowView(doc: doc, controller: controller)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }

            if !controller.selectedDocumentIDs.isEmpty {
                BulkSalesDocumentToolbarView(controller: controller)
                    .padding(.bottom, 60)
            }
        }
        .navigationTitle(controller.documentType.pluralTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { controller.isShowingNewSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Count: \(controller.filteredDocuments.count)")
                        .font(.system(size: 11, weight: .bold))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total: \(CommonCurrencyFormatter.format(controller.filteredTotalAmount, currencyCode: "INR"))")
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.thinMaterial)
        }
    }
}

// MARK: - iPadOS & Mac Catalyst Wide Layout View

struct WideSalesDocumentLayoutView: View {
    @ObservedObject var controller: SalesDocumentController

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: controller.documentType.systemIcon)
                        .foregroundColor(.blue)
                    Text(controller.documentType.pluralTitle)
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .padding()

                Divider()

                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(SalesDocumentFilterChip.allCases) { chip in
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

                Button(action: { controller.isShowingNewSheet = true }) {
                    Label(controller.documentType.newTitle, systemImage: "plus")
                        .font(CommonFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 260, max: 300)
        } content: {
            VStack(spacing: 0) {
                SalesDocumentKPIDashboardHeaderView(controller: controller)

                Divider()

                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search...", text: $controller.searchText)
                            .font(.system(size: 14))
                    }
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(10)

                    Spacer()

                    Button(action: { controller.isFilterPopoverPresented.toggle() }) {
                        Image(systemName: "funnel")
                            .foregroundColor(controller.activeFilterCount > 0 ? .blue : .primary)
                    }
                    .popover(isPresented: $controller.isFilterPopoverPresented, arrowEdge: .top) {
                        SalesDocumentFilterView(controller: controller)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground))

                Divider()

                List(controller.filteredDocuments) { doc in
                    SalesDocumentRowView(doc: doc, controller: controller)
                        .onTapGesture {
                            controller.selectedDocument = doc
                        }
                }
                .listStyle(.plain)
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 550)
        } detail: {
            if let selected = controller.selectedDocument ?? controller.filteredDocuments.first {
                SalesDocumentDetailView(controller: controller, document: selected)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: controller.documentType.systemIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a document to inspect details")
                        .font(CommonFont.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Row View Component

struct SalesDocumentRowView: View {
    let doc: SalesDocument
    @ObservedObject var controller: SalesDocumentController

    var isSelected: Bool {
        controller.selectedDocumentIDs.contains(doc.documentId)
    }

    var body: some View {
        HStack(spacing: 12) {
            if controller.isEditingMode {
                Button(action: { controller.toggleSelection(doc.documentId) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(doc.customerInitials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(doc.documentId)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.blue)

                Text(doc.customerName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text("Date: \(doc.formattedPrimaryDate) • Due: \(doc.formattedSecondaryDate)")
                    .font(.system(size: 11))
                    .foregroundColor(doc.isOverdue ? .red : .secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Menu {
                    ForEach(SalesDocumentStatus.allCases) { st in
                        Button(st.rawValue) {
                            controller.updateStatus(for: doc, newStatus: st)
                        }
                    }
                } label: {
                    SalesDocumentStatusBadgeView(status: doc.status)
                }

                Text(doc.formattedTotal)
                    .font(.system(size: 16, weight: .bold))

                if doc.secondaryAmount > 0 {
                    Text("Bal: \(doc.formattedSecondaryAmount)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation { controller.deleteDocument(doc) }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if doc.documentType == .salesOrder {
                Button {
                    controller.updateStatus(for: doc, newStatus: .invoiced)
                } label: {
                    Label("Convert", systemImage: "doc.text.fill")
                }
                .tint(.green)
            }

            Button {
                controller.selectedDocument = doc
                controller.isShowingPDFPreview = true
            } label: {
                Label("PDF", systemImage: "doc.richtext")
            }
            .tint(.blue)
        }
    }
}

// MARK: - Status Badge View

public struct SalesDocumentStatusBadgeView: View {
    let status: SalesDocumentStatus

    public var body: some View {
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

// MARK: - Bulk Action Toolbar Component

struct BulkSalesDocumentToolbarView: View {
    @ObservedObject var controller: SalesDocumentController

    var body: some View {
        HStack(spacing: 16) {
            Text("\(controller.selectedDocumentIDs.count) selected")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            if controller.documentType == .salesOrder {
                Button(action: { controller.bulkUpdateStatus(newStatus: .invoiced) }) {
                    Label("Convert to Invoice", systemImage: "doc.text.fill")
                        .foregroundColor(.green)
                }
            }

            Button(action: { controller.bulkDelete() }) {
                Label("Delete", systemImage: "trash.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.85))
        .cornerRadius(30)
        .padding(.horizontal, 24)
    }
}

// MARK: - Metric Card Subview Component

struct SalesDocumentMetricCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let accentColor: Color
    var isWarning: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isWarning ? .red : .secondary)
                    .lineLimit(1)
                Spacer()
            }
            Spacer(minLength: 2)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isWarning ? .red : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
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
        .padding(12)
        .frame(width: 175, height: 104)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
