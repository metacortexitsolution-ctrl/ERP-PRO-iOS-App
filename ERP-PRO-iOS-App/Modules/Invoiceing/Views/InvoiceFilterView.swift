//
//  InvoiceFilterView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Main Floating Filter Popover Container managing 8 filter categories with a Single Active Submenu state machine.
public struct InvoiceFilterView: View {
    @ObservedObject var controller: InvoiceController
    
    @State private var statusSearchText: String = ""
    @State private var customerSearchText: String = ""
    @State private var showCustomDatePicker: Bool = false
    
    public init(controller: InvoiceController) {
        self.controller = controller
    }
    
    private var filteredStatuses: [InvoiceStatus] {
        if statusSearchText.isEmpty {
            return InvoiceStatus.allCases
        } else {
            return InvoiceStatus.allCases.filter { $0.rawValue.lowercased().contains(statusSearchText.lowercased()) }
        }
    }
    
    private var filteredCustomerNames: [String] {
        if customerSearchText.isEmpty {
            return controller.allCustomerNames
        } else {
            return controller.allCustomerNames.filter { $0.lowercased().contains(customerSearchText.lowercased()) }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - 1. Top Header Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 18))
                    Text(ConstantString.filters)
                        .font(.system(size: 16, weight: .bold))
                    
                    if controller.activeFilterCount > 0 {
                        Text("\(controller.activeFilterCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                if controller.activeFilterCount > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            controller.clearAllFilters()
                        }
                    }) {
                        Text(ConstantString.clearAll)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    // MARK: - 2. Active Filter Chips Horizontal Bar
                    if controller.activeFilterCount > 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                if !controller.selectedStatuses.isEmpty {
                                    FilterChipPill(label: "Status: \(controller.selectedStatuses.count)") {
                                        controller.selectedStatuses.removeAll()
                                    }
                                }
                                if let preset = controller.selectedDatePreset {
                                    FilterChipPill(label: "Date: \(preset.rawValue)") {
                                        controller.selectedDatePreset = nil
                                    }
                                } else if controller.customFromDate != nil || controller.customToDate != nil {
                                    FilterChipPill(label: "Date: Custom") {
                                        controller.customFromDate = nil
                                        controller.customToDate = nil
                                    }
                                }
                                if controller.selectedCurrencyFilter != "All" {
                                    FilterChipPill(label: "Currency: \(controller.selectedCurrencyFilter)") {
                                        controller.selectedCurrencyFilter = "All"
                                    }
                                }
                                if controller.selectedPaymentStatus != .all {
                                    FilterChipPill(label: "Payment: \(controller.selectedPaymentStatus.rawValue)") {
                                        controller.selectedPaymentStatus = .all
                                    }
                                }
                                if let qRange = controller.quickAmountRange {
                                    FilterChipPill(label: "Amount: \(qRange.rawValue)") {
                                        controller.quickAmountRange = nil
                                    }
                                } else if !controller.minAmountText.isEmpty || !controller.maxAmountText.isEmpty {
                                    FilterChipPill(label: "Amount: Custom") {
                                        controller.minAmountText = ""
                                        controller.maxAmountText = ""
                                    }
                                }
                                if !controller.selectedCustomers.isEmpty {
                                    FilterChipPill(label: "Customers: \(controller.selectedCustomers.count)") {
                                        controller.selectedCustomers.removeAll()
                                    }
                                }
                                if let sp = controller.selectedSalesperson {
                                    FilterChipPill(label: "Sales: \(sp)") {
                                        controller.selectedSalesperson = nil
                                    }
                                }
                                if let branch = controller.selectedBranch {
                                    FilterChipPill(label: "Branch: \(branch)") {
                                        controller.selectedBranch = nil
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                        }
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground))
                        
                        Divider()
                    }
                    
                    // MARK: - 3. 8 Filter Categories List with Single Active Submenu
                    VStack(spacing: 8) {
                        ForEach(FilterCategory.allCases) { category in
                            categoryRowView(for: category)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.vertical, 10)
            }
        }
        .frame(width: 380, height: 540)
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Category Row View Builder
    
    @ViewBuilder
    private func categoryRowView(for category: FilterCategory) -> some View {
        let isOpen = controller.activeFilterCategory == category
        let subtitle = controller.subtitleForCategory(category)
        let isCategoryActive = subtitle != "All Statuses" && subtitle != "All Time" && subtitle != "All" && subtitle != "Any Amount" && subtitle != "All Customers" && subtitle != "All Salespersons" && subtitle != "All Branches"
        
        VStack(spacing: 0) {
            // Header Button
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    controller.toggleFilterCategory(category)
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(isCategoryActive ? Color.blue.opacity(0.15) : Color(uiColor: .tertiarySystemFill))
                            .frame(width: 32, height: 32)
                        Image(systemName: category.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isCategoryActive ? .blue : .secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(isCategoryActive ? .blue : .secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isOpen ? "chevron.up" : "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isOpen ? Color.blue.opacity(0.06) : (isCategoryActive ? Color.blue.opacity(0.03) : Color(uiColor: .secondarySystemGroupedBackground)))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isOpen ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Submenu Expansion Container (Single Active Menu Rule)
            if isOpen {
                VStack(spacing: 0) {
                    categorySubmenuView(for: category)
                }
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Category Submenu View Builder
    
    @ViewBuilder
    private func categorySubmenuView(for category: FilterCategory) -> some View {
        switch category {
        case .status:
            statusSubmenuView
        case .dateRange:
            dateRangeSubmenuView
        case .currency:
            currencySubmenuView
        case .paymentStatus:
            paymentStatusSubmenuView
        case .amount:
            amountSubmenuView
        case .customer:
            customerSubmenuView
        case .salesperson:
            salespersonSubmenuView
        case .branch:
            branchSubmenuView
        }
    }
    
    // MARK: - 1. Status Submenu View
    private var statusSubmenuView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header controls
            HStack {
                Text("Select Statuses (\(controller.selectedStatuses.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Button(controller.selectedStatuses.count == InvoiceStatus.allCases.count ? ConstantString.deselectAll : ConstantString.selectAll) {
                    if controller.selectedStatuses.count == InvoiceStatus.allCases.count {
                        controller.selectedStatuses.removeAll()
                    } else {
                        controller.selectedStatuses = Set(InvoiceStatus.allCases)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.blue)
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                TextField(ConstantString.searchStatusPlaceholder, text: $statusSearchText)
                    .font(.system(size: 13))
            }
            .padding(6)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(8)
            
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredStatuses) { status in
                        let count = controller.invoices.filter { $0.status == status }.count
                        let isSelected = controller.selectedStatuses.contains(status)
                        
                        Button(action: {
                            if isSelected {
                                controller.selectedStatuses.remove(status)
                            } else {
                                controller.selectedStatuses.insert(status)
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                    .foregroundColor(isSelected ? .blue : .secondary)
                                    .font(.system(size: 16))
                                
                                Text(status.rawValue)
                                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                    .foregroundColor(status.badgeTextColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(status.badgeBackgroundColor)
                                    .cornerRadius(6)
                                
                                Spacer()
                                
                                Text("\(count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(uiColor: .tertiarySystemFill))
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 180)
        }
    }
    
    // MARK: - 2. Date Range Submenu View
    private var dateRangeSubmenuView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Target Date Type Selector
            VStack(alignment: .leading, spacing: 4) {
                Text("Target Date Field")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                Picker("Date Type", selection: $controller.selectedDateType) {
                    ForEach(DateType.allCases) { dt in
                        Text(dt.rawValue).tag(dt)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 8 Quick Presets Grid
            VStack(alignment: .leading, spacing: 6) {
                Text("Quick Presets")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(DateRangePreset.allCases) { preset in
                        let isSelected = controller.selectedDatePreset == preset
                        Button(action: {
                            if isSelected {
                                controller.selectedDatePreset = nil
                            } else {
                                controller.selectedDatePreset = preset
                                controller.customFromDate = nil
                                controller.customToDate = nil
                            }
                        }) {
                            Text(preset.rawValue)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(isSelected ? Color.blue : Color(uiColor: .tertiarySystemFill))
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
            
            // Custom Date Inputs
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Custom Range")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    if controller.customFromDate != nil || controller.customToDate != nil {
                        Button("Clear Dates") {
                            controller.customFromDate = nil
                            controller.customToDate = nil
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.red)
                    }
                }
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("From")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        DatePicker("", selection: Binding(
                            get: { controller.customFromDate ?? Date() },
                            set: {
                                controller.customFromDate = $0
                                controller.selectedDatePreset = nil
                            }
                        ), displayedComponents: .date)
                        .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("To")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        DatePicker("", selection: Binding(
                            get: { controller.customToDate ?? Date() },
                            set: {
                                controller.customToDate = $0
                                controller.selectedDatePreset = nil
                            }
                        ), displayedComponents: .date)
                        .labelsHidden()
                    }
                }
            }
        }
    }
    
    // MARK: - 3. Currency Submenu View
    private var currencySubmenuView: some View {
        VStack(spacing: 4) {
            let currencies = ["All", "INR", "USD", "EUR"]
            ForEach(currencies, id: \.self) { curr in
                let isSelected = controller.selectedCurrencyFilter == curr
                Button(action: {
                    controller.selectedCurrencyFilter = curr
                }) {
                    HStack {
                        Text(curr == "All" ? "All Currencies" : (curr == "INR" ? "INR (₹) - Indian Rupee" : (curr == "USD" ? "USD ($) - US Dollar" : "EUR (€) - Euro")))
                            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                if curr != currencies.last {
                    Divider()
                }
            }
        }
    }
    
    // MARK: - 4. Payment Status Submenu View
    private var paymentStatusSubmenuView: some View {
        VStack(spacing: 4) {
            ForEach(PaymentStatusFilter.allCases) { option in
                let isSelected = controller.selectedPaymentStatus == option
                Button(action: {
                    controller.selectedPaymentStatus = option
                }) {
                    HStack {
                        Text(option.rawValue)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                if option != PaymentStatusFilter.allCases.last {
                    Divider()
                }
            }
        }
    }
    
    // MARK: - 5. Amount Range Submenu View
    private var amountSubmenuView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Amount Ranges")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 6) {
                ForEach(AmountQuickRange.allCases) { rangeOpt in
                    let isSelected = controller.quickAmountRange == rangeOpt
                    Button(action: {
                        if isSelected {
                            controller.quickAmountRange = nil
                        } else {
                            controller.quickAmountRange = rangeOpt
                            controller.minAmountText = ""
                            controller.maxAmountText = ""
                        }
                    }) {
                        Text(rangeOpt.rawValue)
                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.blue : Color(uiColor: .tertiarySystemFill))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            Text("Custom Range (₹)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Min")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    TextField("0", text: $controller.minAmountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .onChange(of: controller.minAmountText) { _ in
                            controller.quickAmountRange = nil
                        }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Max")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    TextField("Any", text: $controller.maxAmountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .onChange(of: controller.maxAmountText) { _ in
                            controller.quickAmountRange = nil
                        }
                }
            }
        }
    }
    
    // MARK: - 6. Customer Submenu View
    private var customerSubmenuView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Customers (\(controller.selectedCustomers.count))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Button(controller.selectedCustomers.count == controller.allCustomerNames.count ? ConstantString.deselectAll : ConstantString.selectAll) {
                    if controller.selectedCustomers.count == controller.allCustomerNames.count {
                        controller.selectedCustomers.removeAll()
                    } else {
                        controller.selectedCustomers = Set(controller.allCustomerNames)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.blue)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                TextField(ConstantString.searchCustomerPlaceholder, text: $customerSearchText)
                    .font(.system(size: 13))
            }
            .padding(6)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(8)
            
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(filteredCustomerNames, id: \.self) { customer in
                        let isSelected = controller.selectedCustomers.contains(customer)
                        let count = controller.invoices.filter { $0.customerName == customer }.count
                        
                        Button(action: {
                            if isSelected {
                                controller.selectedCustomers.remove(customer)
                            } else {
                                controller.selectedCustomers.insert(customer)
                            }
                        }) {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                    .foregroundColor(isSelected ? .blue : .secondary)
                                    .font(.system(size: 16))
                                Text(customer)
                                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                Spacer()
                                Text("\(count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 160)
        }
    }
    
    // MARK: - 7. Salesperson Submenu View
    private var salespersonSubmenuView: some View {
        VStack(spacing: 4) {
            Button(action: {
                controller.selectedSalesperson = nil
            }) {
                HStack {
                    Text("All Salespersons")
                        .font(.system(size: 13, weight: controller.selectedSalesperson == nil ? .semibold : .regular))
                    Spacer()
                    if controller.selectedSalesperson == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
            Divider()
            
            ForEach(controller.allSalespersons, id: \.self) { sp in
                let isSelected = controller.selectedSalesperson == sp
                Button(action: {
                    controller.selectedSalesperson = sp
                }) {
                    HStack {
                        Text(sp)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - 8. Branch Submenu View
    private var branchSubmenuView: some View {
        VStack(spacing: 4) {
            Button(action: {
                controller.selectedBranch = nil
            }) {
                HStack {
                    Text("All Branches")
                        .font(.system(size: 13, weight: controller.selectedBranch == nil ? .semibold : .regular))
                    Spacer()
                    if controller.selectedBranch == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
            Divider()
            
            ForEach(controller.allBranches, id: \.self) { branch in
                let isSelected = controller.selectedBranch == branch
                Button(action: {
                    controller.selectedBranch = branch
                }) {
                    HStack {
                        Text(branch)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Active Filter Chip Pill Component

struct FilterChipPill: View {
    let label: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.12))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}
