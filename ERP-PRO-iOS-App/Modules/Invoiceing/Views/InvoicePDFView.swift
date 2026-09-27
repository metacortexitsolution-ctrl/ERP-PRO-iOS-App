//
//  InvoicePDFView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - Native PDFKit Interactive Viewer Representable

struct PDFKitRepresentable: UIViewRepresentable {
    let pdfData: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous
        if let doc = PDFDocument(data: pdfData) {
            pdfView.document = doc
        }
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let doc = PDFDocument(data: pdfData) {
            pdfView.document = doc
        }
    }
}

// MARK: - PDF Preview & Export Sheet View

public struct InvoicePDFPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let invoice: Invoice
    
    @State private var pdfData: Data? = nil
    
    public init(invoice: Invoice) {
        self.invoice = invoice
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if let pdfData {
                    PDFKitRepresentable(pdfData: pdfData)
                } else {
                    ProgressView("Generating PDF Document...")
                }
            }
            .navigationTitle("Invoice PDF - \(invoice.invoiceId)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    HStack(spacing: 12) {
                        Button(action: printInvoice) {
                            Image(systemName: "printer")
                        }
                        
                        if let pdfData {
                            ShareLink(item: pdfData, preview: SharePreview(invoice.invoiceId, image: Image(systemName: "doc.text"))) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                }
            }
            .task {
                self.pdfData = InvoicePDFGenerator.generatePDF(for: invoice)
            }
        }
    }
    
    private func printInvoice() {
        guard let pdfData else { return }
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = invoice.invoiceId
        printController.printInfo = printInfo
        printController.printingItem = pdfData
        printController.present(animated: true, completionHandler: nil)
    }
}

// MARK: - POS Thermal Receipt Generator Sheet

public struct InvoiceThermalPrintView: View {
    @Environment(\.dismiss) private var dismiss
    let invoice: Invoice
    
    public init(invoice: Invoice) {
        self.invoice = invoice
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Simulated POS Thermal 80mm Receipt Preview
                    VStack(alignment: .leading, spacing: 4) {
                        Group {
                            Text("================================")
                            Text(invoice.companyName.uppercased())
                                .bold()
                            Text("GSTIN: 27AAACM99881Z4")
                            Text("POS RECEIPT: \(invoice.invoiceId)")
                            Text("DATE: \(invoice.formattedIssueDate)")
                            Text("CUSTOMER: \(invoice.customerName)")
                            Text("================================")
                        }
                        .font(.system(.caption, design: .monospaced))
                        
                        ForEach(invoice.items) { item in
                            HStack {
                                Text("\(item.name) x\(Int(item.quantity))")
                                Spacer()
                                Text(CommonCurrencyFormatter.format(item.amount, currencyCode: invoice.currency))
                            }
                            .font(.system(.caption, design: .monospaced))
                        }
                        
                        Group {
                            Text("--------------------------------")
                            HStack {
                                Text("SUBTOTAL:")
                                Spacer()
                                Text(CommonCurrencyFormatter.format(invoice.subtotalAmount, currencyCode: invoice.currency))
                            }
                            HStack {
                                Text("TAX (18%):")
                                Spacer()
                                Text(CommonCurrencyFormatter.format(invoice.taxAmount, currencyCode: invoice.currency))
                            }
                            HStack {
                                Text("TOTAL:")
                                    .bold()
                                Spacer()
                                Text(invoice.formattedTotal)
                                    .bold()
                            }
                            Text("================================")
                            Text("THANK YOU FOR YOUR BUSINESS!")
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .font(.system(.caption, design: .monospaced))
                    }
                    .padding(16)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                    .frame(maxWidth: 320)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Label("Print to Bluetooth Thermal Printer", systemImage: "printer.fill")
                            .font(CommonFont.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 10)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("POS Thermal Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Dynamic PDF Renderer

public struct InvoicePDFGenerator {
    public static func generatePDF(for invoice: Invoice) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "ERP-PRO Invoicing Engine",
            kCGPDFContextAuthor: invoice.companyName,
            kCGPDFContextTitle: invoice.invoiceId
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            // Background Header Bar
            let headerRect = CGRect(x: 36, y: 36, width: pageWidth - 72, height: 60)
            let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: 8)
            UIColor.systemBlue.withAlphaComponent(0.12).setFill()
            headerPath.fill()
            
            // Company Name
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.systemBlue
            ]
            invoice.companyName.draw(at: CGPoint(x: 50, y: 52), withAttributes: titleAttributes)
            
            // Invoice ID
            let invIdAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
            let invIdText = "INVOICE: \(invoice.invoiceId)"
            let invIdSize = invIdText.size(withAttributes: invIdAttr)
            invIdText.draw(at: CGPoint(x: pageWidth - 50 - invIdSize.width, y: 54), withAttributes: invIdAttr)
            
            // Dates & Customer Info
            var currentY: CGFloat = 120
            let bodyFont = UIFont.systemFont(ofSize: 11)
            let boldFont = UIFont.boldSystemFont(ofSize: 11)
            
            let billToHeader = "BILL TO:"
            billToHeader.draw(at: CGPoint(x: 50, y: currentY), withAttributes: [.font: boldFont, .foregroundColor: UIColor.secondaryLabel])
            
            currentY += 16
            invoice.customerName.draw(at: CGPoint(x: 50, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            
            currentY += 18
            if let addr = invoice.billingAddress {
                let rect = CGRect(x: 50, y: currentY, width: 300, height: 40)
                addr.draw(in: rect, withAttributes: [.font: bodyFont, .foregroundColor: UIColor.darkGray])
                currentY += 36
            }
            
            if let gstin = invoice.gstin {
                "GSTIN: \(gstin)".draw(at: CGPoint(x: 50, y: currentY), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.systemBlue])
                currentY += 24
            }
            
            // Table Header Line
            currentY += 20
            let tableHeaderRect = CGRect(x: 50, y: currentY, width: pageWidth - 100, height: 24)
            UIColor.secondarySystemBackground.setFill()
            UIRectFill(tableHeaderRect)
            
            "Description".draw(at: CGPoint(x: 60, y: currentY + 4), withAttributes: [.font: boldFont])
            "Qty".draw(at: CGPoint(x: 340, y: currentY + 4), withAttributes: [.font: boldFont])
            "Rate".draw(at: CGPoint(x: 410, y: currentY + 4), withAttributes: [.font: boldFont])
            "Amount".draw(at: CGPoint(x: 480, y: currentY + 4), withAttributes: [.font: boldFont])
            
            currentY += 28
            for item in invoice.items {
                item.name.draw(at: CGPoint(x: 60, y: currentY), withAttributes: [.font: bodyFont])
                "\(Int(item.quantity))".draw(at: CGPoint(x: 340, y: currentY), withAttributes: [.font: bodyFont])
                CommonCurrencyFormatter.format(item.rate, currencyCode: invoice.currency).draw(at: CGPoint(x: 410, y: currentY), withAttributes: [.font: bodyFont])
                CommonCurrencyFormatter.format(item.amount, currencyCode: invoice.currency).draw(at: CGPoint(x: 480, y: currentY), withAttributes: [.font: boldFont])
                currentY += 20
            }
            
            // Total Line
            currentY += 20
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: 50, y: currentY))
            linePath.addLine(to: CGPoint(x: pageWidth - 50, y: currentY))
            UIColor.separator.setStroke()
            linePath.stroke()
            
            currentY += 12
            "Grand Total:".draw(at: CGPoint(x: 380, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            invoice.formattedTotal.draw(at: CGPoint(x: 480, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.systemBlue])
        }
    }
}
