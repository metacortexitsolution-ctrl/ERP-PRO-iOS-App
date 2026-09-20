//
//  PeriodFilterSheet.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

public enum TimePeriodOption: Equatable, Hashable {
    case today
    case thisWeek
    case thisMonth
    case thisQuarter
    case thisYear
    case custom(startDate: Date, endDate: Date)

    public var title: String {
        switch self {
        case .today:
            return "Today"
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        case .thisQuarter:
            return "This Quarter"
        case .thisYear:
            return "This Year"
        case .custom(let start, let end):
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
        }
    }

    public var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }
}

public final class PeriodFilterViewState: ObservableObject {
    @Published public var showingCustomRangeSheet: Bool = false
    public init() {}
}

public struct PeriodFilterSheet: View {
    @Binding var selectedOption: TimePeriodOption
    let onSelect: (TimePeriodOption) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewState = PeriodFilterViewState()

    private let presetOptions: [TimePeriodOption] = [
        .today,
        .thisWeek,
        .thisMonth,
        .thisQuarter,
        .thisYear
    ]

    public init(
        selectedOption: Binding<TimePeriodOption>,
        onSelect: @escaping (TimePeriodOption) -> Void
    ) {
        self._selectedOption = selectedOption
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator Handle
            Capsule()
                .fill(Color(UIColor.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                // Preset Option Rows
                ForEach(Array(presetOptions.enumerated()), id: \.offset) { index, option in
                    Button {
                        selectedOption = option
                        onSelect(option)
                        dismiss()
                    } label: {
                        HStack {
                            Text(option.title)
                                .font(.system(size: 16, weight: isSelected(option) ? .semibold : .regular))
                                .foregroundColor(isSelected(option) ? .blue : .primary)

                            Spacer()

                            if isSelected(option) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }

                    Divider()
                        .padding(.leading, 16)
                }

                // Custom Range Row
                Button {
                    viewState.showingCustomRangeSheet = true
                } label: {
                    HStack {
                        Text(customRangeRowTitle)
                            .font(.system(size: 16, weight: selectedOption.isCustom ? .semibold : .regular))
                            .foregroundColor(selectedOption.isCustom ? .blue : .primary)

                        Spacer()

                        if selectedOption.isCustom {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                                .padding(.trailing, 4)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
            }
            .background(CommonColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(CommonColor.cardBorder, lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(CommonColor.background)
        .sheet(isPresented: $viewState.showingCustomRangeSheet) {
            CustomDateRangeSheet(
                initialOption: selectedOption,
                onApply: { customOption in
                    selectedOption = customOption
                    onSelect(customOption)
                    dismiss()
                }
            )
            .presentationDetents([.height(320), .medium])
            .presentationCornerRadius(20)
        }
    }

    private func isSelected(_ option: TimePeriodOption) -> Bool {
        if case .custom = selectedOption {
            return false
        }
        return selectedOption == option
    }

    private var customRangeRowTitle: String {
        if case .custom(let start, let end) = selectedOption {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
        }
        return "Custom Range"
    }
}

// MARK: - Custom Date Range Selection Sheet

public final class CustomDateRangeViewState: ObservableObject {
    @Published public var startDate: Date
    @Published public var endDate: Date

    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

public struct CustomDateRangeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onApply: (TimePeriodOption) -> Void

    @StateObject private var viewState: CustomDateRangeViewState

    public init(
        initialOption: TimePeriodOption,
        onApply: @escaping (TimePeriodOption) -> Void
    ) {
        self.onApply = onApply
        
        let start: Date
        let end: Date
        if case .custom(let s, let e) = initialOption {
            start = s
            end = e
        } else {
            let calendar = Calendar.current
            let now = Date()
            start = calendar.date(byAdding: .day, value: -18, to: now) ?? now
            end = now
        }
        _viewState = StateObject(wrappedValue: CustomDateRangeViewState(startDate: start, endDate: end))
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar with Cancel & Apply
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.blue)

                Spacer()

                Button("Apply") {
                    let customOption = TimePeriodOption.custom(startDate: viewState.startDate, endDate: viewState.endDate)
                    onApply(customOption)
                    dismiss()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()

            VStack(spacing: 16) {
                // Start Date Picker Row
                HStack {
                    Text("Start Date")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $viewState.startDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(CommonColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CommonColor.cardBorder, lineWidth: 0.8)
                )

                // End Date Picker Row
                HStack {
                    Text("End Date")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $viewState.endDate,
                        in: viewState.startDate...,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(CommonColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CommonColor.cardBorder, lineWidth: 0.8)
                )
            }
            .padding(16)

            Spacer()
        }
        .background(CommonColor.background)
    }
}
