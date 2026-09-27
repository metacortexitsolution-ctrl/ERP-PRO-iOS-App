//
//  InvoiceDetailView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import VisionKit
import UniformTypeIdentifiers

public struct InvoiceDetailView: View {
    @ObservedObject var controller: InvoiceController
    let invoice: Invoice
    
    @State private var isNotesExpanded: Bool = true
    @State private var isAttachmentsExpanded: Bool = true
    @State private var isPaymentsExpanded: Bool = true
    @State private var attachments: [String] = ["Signed_PO_Contract.pdf", "Delivery_Receipt_Gate3.jpg"]
    @State private var isShowingFileImporter: Bool = false
    @State private var isShowingScanner: Bool = false
    @State private var isShowingPaymentModal: Bool = false
    @State private var paymentAmountInput: String = ""
    @State private var paymentMethodInput: String = "NEFT / Bank Transfer"
    
    public init(controller: InvoiceController, invoice: Invoice) {
        self.controller = controller
        self.invoice = invoice
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CommonSpacing.lg) {
                
                // MARK: - Document Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(invoice.invoiceId)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                InvoiceStatusBadge(status: invoice.status)
                            }
                            Text(invoice.companyName)
                                .font(CommonFont.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Total Billed")
                                .font(CommonFont.caption)
                                .foregroundColor(.secondary)
                            Text(invoice.formattedTotal)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ISSUE DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(invoice.formattedIssueDate)
                                .font(CommonFont.subheadline)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DUE DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(invoice.isOverdue ? .red : .secondary)
                            Text(invoice.formattedDueDate)
                                .font(CommonFont.subheadline)
                                .foregroundColor(invoice.isOverdue ? .red : .primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BALANCE DUE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(invoice.formattedBalanceDue)
                                .font(CommonFont.subheadline)
                                .bold()
                                .foregroundColor(invoice.balanceDue > 0 ? .orange : .green)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(16)
                
                // MARK: - Party Cards (Bill From, Bill To, Ship To)
                VStack(spacing: 12) {
                    PartyCardView(
                        title: "BILL FROM",
                        icon: "building.2.fill",
                        name: invoice.companyName,
                        address: "Corporate Towers, 12th Floor, Bandra Kurla Complex, Mumbai, MH 400051",
                        gstin: "27AAACM99881Z4",
                        email: "billing@metacortex.in",
                        phone: "+91 22 6677 8899"
                    )
                    
                    PartyCardView(
                        title: "BILL TO",
                        icon: "person.crop.square.fill",
                        name: invoice.customerName,
                        address: invoice.billingAddress ?? "Address not provided",
                        gstin: invoice.gstin ?? "N/A",
                        email: invoice.customerEmail ?? "N/A",
                        phone: invoice.customerPhone ?? "N/A"
                    )
                    
                    if let shipAddr = invoice.shippingAddress, !shipAddr.isEmpty {
                        PartyCardView(
                            title: "SHIP TO",
                            icon: "shippingbox.fill",
                            name: invoice.customerName,
                            address: shipAddr,
                            gstin: nil,
                            email: nil,
                            phone: nil
                        )
                    }
                }
                
                // MARK: - Metadata Summary Cards
                HStack(spacing: 12) {
                    MetadataBoxView(title: "PAYMENT TERMS", value: invoice.paymentTerms, icon: "calendar")
                    MetadataBoxView(title: "PO REFERENCE", value: invoice.poReference ?? "N/A", icon: "doc.plaintext")
                    MetadataBoxView(title: "SALESPERSON", value: invoice.salesperson ?? "Unassigned", icon: "person.fill")
                }
                
                // MARK: - Itemized Breakdown Table
                VStack(alignment: .leading, spacing: 10) {
                    Text("ITEMIZED BREAKDOWN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Item & Description").frame(minWidth: 140, alignment: .leading)
                            Text("HSN").frame(width: 50, alignment: .leading)
                            Text("Qty").frame(width: 40, alignment: .trailing)
                            Text("Rate").frame(width: 70, alignment: .trailing)
                            Text("GST %").frame(width: 50, alignment: .trailing)
                            Text("Total").frame(width: 80, alignment: .trailing)
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(uiColor: .tertiarySystemFill))
                        
                        Divider()
                        
                        ForEach(invoice.items) { item in
                            VStack(spacing: 0) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name)
                                            .font(.system(size: 13, weight: .semibold))
                                        if let desc = item.itemDescription, !desc.isEmpty {
                                            Text(desc)
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(minWidth: 140, alignment: .leading)
                                    
                                    Text(item.hsn)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text("\(String(format: "%.0f", item.quantity)) \(item.unit)")
                                        .font(.system(size: 12))
                                        .frame(width: 40, alignment: .trailing)
                                    
                                    Text(CommonCurrencyFormatter.format(item.rate, currencyCode: invoice.currency))
                                        .font(.system(size: 12))
                                        .frame(width: 70, alignment: .trailing)
                                    
                                    Text("\(String(format: "%.0f", item.gstRate))%")
                                        .font(.system(size: 12))
                                        .frame(width: 50, alignment: .trailing)
                                    
                                    Text(CommonCurrencyFormatter.format(item.amount, currencyCode: invoice.currency))
                                        .font(.system(size: 12, weight: .bold))
                                        .frame(width: 80, alignment: .trailing)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                Divider()
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                
                // MARK: - Financial Summary & Tax Split (CGST/SGST/IGST)
                VStack(alignment: .trailing, spacing: 6) {
                    FinancialLineRow(title: "Subtotal", amount: CommonCurrencyFormatter.format(invoice.subtotalAmount, currencyCode: invoice.currency))
                    
                    if invoice.discountAmount > 0 {
                        FinancialLineRow(title: "Discount", amount: "-\(CommonCurrencyFormatter.format(invoice.discountAmount, currencyCode: invoice.currency))", isNegative: true)
                    }
                    
                    let cgstSum = invoice.items.compactMap { $0.cgstAmount }.reduce(0, +)
                    let sgstSum = invoice.items.compactMap { $0.sgstAmount }.reduce(0, +)
                    
                    FinancialLineRow(title: "CGST (9%)", amount: CommonCurrencyFormatter.format(cgstSum, currencyCode: invoice.currency))
                    FinancialLineRow(title: "SGST (9%)", amount: CommonCurrencyFormatter.format(sgstSum, currencyCode: invoice.currency))
                    
                    if invoice.shippingAmount > 0 {
                        FinancialLineRow(title: "Shipping & Handling", amount: CommonCurrencyFormatter.format(invoice.shippingAmount, currencyCode: invoice.currency))
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("Grand Total")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(invoice.formattedTotal)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Paid Amount")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(CommonCurrencyFormatter.format(invoice.paidAmount, currencyCode: invoice.currency))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Balance Due")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text(invoice.formattedBalanceDue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(invoice.balanceDue > 0 ? .red : .green)
                    }
                }
                .padding()
                .background(Color(uiColor: .tertiarySystemFill))
                .cornerRadius(12)
                
                // MARK: - Collapsible Notes & Terms
                DisclosureGroup("Notes & Terms and Conditions", isExpanded: $isNotesExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let notes = invoice.notes, !notes.isEmpty {
                            Text("Notes:")
                                .font(CommonFont.caption)
                                .foregroundColor(.secondary)
                            Text(notes)
                                .font(CommonFont.body)
                        }
                        if let terms = invoice.termsAndConditions, !terms.isEmpty {
                            Text("Terms & Conditions:")
                                .font(CommonFont.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            Text(terms)
                                .font(CommonFont.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
                // MARK: - Collapsible Attachments & Document Camera Scanner
                DisclosureGroup("Attachments & Scanned Docs (\(attachments.count))", isExpanded: $isAttachmentsExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(attachments, id: \.self) { filename in
                            HStack {
                                Image(systemName: filename.hasSuffix(".pdf") ? "doc.fill" : "photo.fill")
                                    .foregroundColor(.blue)
                                Text(filename)
                                    .font(CommonFont.body)
                                Spacer()
                                Button(action: {
                                    attachments.removeAll { $0 == filename }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(8)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .cornerRadius(8)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: { isShowingFileImporter = true }) {
                                Label("Import File", systemImage: "doc.badge.plus")
                                    .font(CommonFont.caption)
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: { isShowingScanner = true }) {
                                Label("Scan Document", systemImage: "camera.viewfinder")
                                    .font(CommonFont.caption)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
                // MARK: - Payment History
                DisclosureGroup("Payment History (\(invoice.payments.count))", isExpanded: $isPaymentsExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        if invoice.payments.isEmpty {
                            Text("No payment records logged yet.")
                                .font(CommonFont.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(invoice.payments) { pay in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(pay.method)
                                            .font(.system(size: 13, weight: .semibold))
                                        if let ref = pay.referenceNumber {
                                            Text("Ref: \(ref)")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(CommonCurrencyFormatter.format(pay.amount, currencyCode: invoice.currency))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.green)
                                        Text(CommonDateFormatter.formatShort(pay.date))
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(8)
                                .background(Color(uiColor: .tertiarySystemFill))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
                // MARK: - Contextual Lifecycle Action Footer State Machine
                VStack(spacing: 12) {
                    Text("LIFECYCLE ACTIONS (\(invoice.status.rawValue))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 10) {
                        switch invoice.status {
                        case .draft:
                            Button("Save Draft") {
                                controller.updateStatus(for: invoice, newStatus: .draft)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Submit Approval") {
                                controller.updateStatus(for: invoice, newStatus: .pendingApproval)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Send Invoice") {
                                controller.updateStatus(for: invoice, newStatus: .sent)
                            }
                            .buttonStyle(.borderedProminent)
                            
                        case .sent, .viewed, .partiallyPaid, .overdue:
                            Button("Record Payment") {
                                isShowingPaymentModal = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Send Reminder") {
                                controller.updateStatus(for: invoice, newStatus: .sent)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Void") {
                                controller.updateStatus(for: invoice, newStatus: .void)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            
                        case .paid:
                            Button("Payment Receipt") {
                                controller.isShowingPDFPreview = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Thermal POS Print") {
                                controller.isShowingThermalPrintSheet = true
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Refund") {
                                controller.updateStatus(for: invoice, newStatus: .refunded)
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)
                            
                        default:
                            Button("Print PDF") {
                                controller.isShowingPDFPreview = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Archive") {
                                controller.updateStatus(for: invoice, newStatus: .archived)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .tertiarySystemFill))
                .cornerRadius(16)
            }
            .padding(CommonSpacing.pageMargin)
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                attachments.append(url.lastPathComponent)
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            DocumentScannerModalView { scannedImageName in
                attachments.append(scannedImageName)
            }
        }
        .sheet(isPresented: $isShowingPaymentModal) {
            RecordPaymentSheet(invoice: invoice) { amt, method, ref in
                let pay = InvoicePayment(method: method, amount: amt, referenceNumber: ref)
                invoice.payments.append(pay)
                invoice.recalculateTotals()
                if invoice.balanceDue <= 0 {
                    invoice.status = .paid
                } else {
                    invoice.status = .partiallyPaid
                }
            }
        }
    }
}

// MARK: - Reusable Subviews

struct PartyCardView: View {
    let title: String
    let icon: String
    let name: String
    let address: String
    let gstin: String?
    let email: String?
    let phone: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            Text(name)
                .font(.system(size: 15, weight: .bold))
            Text(address)
                .font(CommonFont.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                if let gstin, !gstin.isEmpty {
                    Text("GSTIN: \(gstin)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.blue)
                }
                if let email, !email.isEmpty {
                    Text(email)
                        .font(CommonFont.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .tertiarySystemFill))
        .cornerRadius(12)
    }
}

struct MetadataBoxView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct FinancialLineRow: View {
    let title: String
    let amount: String
    var isNegative: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(CommonFont.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(amount)
                .font(CommonFont.subheadline)
                .bold()
                .foregroundColor(isNegative ? .red : .primary)
        }
    }
}

// MARK: - Document Camera Scanner Representable

struct DocumentScannerModalView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerModalView
        
        init(_ parent: DocumentScannerModalView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            if scan.pageCount > 0 {
                parent.onScan("Scanned_Doc_\(Date().timeIntervalSince1970).jpg")
            }
            parent.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.dismiss()
        }
    }
}

// MARK: - Record Payment Modal Sheet

struct RecordPaymentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let invoice: Invoice
    let onRecord: (Double, String, String) -> Void
    
    @State private var amountText: String = ""
    @State private var selectedMethod: String = "NEFT / Bank Transfer"
    @State private var refNoText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice Information") {
                    LabeledContent("Invoice ID", value: invoice.invoiceId)
                    LabeledContent("Customer", value: invoice.customerName)
                    LabeledContent("Balance Due", value: invoice.formattedBalanceDue)
                }
                
                Section("Payment Details") {
                    TextField("Amount (₹)", text: $amountText)
                        .keyboardType(.decimalPad)
                    Picker("Payment Method", selection: $selectedMethod) {
                        Text("NEFT / Bank Transfer").tag("NEFT / Bank Transfer")
                        Text("UPI").tag("UPI")
                        Text("Credit Card").tag("Credit Card")
                        Text("Cheque").tag("Cheque")
                        Text("Cash").tag("Cash")
                    }
                    TextField("Reference / UTR Number", text: $refNoText)
                }
            }
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Record") {
                        if let amt = Double(amountText), amt > 0 {
                            onRecord(amt, selectedMethod, refNoText.isEmpty ? "REF\(Int.random(in: 10000...99999))" : refNoText)
                            dismiss()
                        }
                    }
                    .font(CommonFont.headline)
                }
            }
            .onAppear {
                amountText = String(format: "%.2f", invoice.balanceDue)
            }
        }
    }
}
