//
//  MoreController.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

public final class MoreController: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var sections: [MoreSection] = []

    private var allSections: [MoreSection] = []
    private var cancellables = Set<AnyCancellable>()

    public init() {
        self.allSections = MoreMockData.sections
        self.sections = allSections

        $searchText
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.filterSections(query: query)
            }
            .store(in: &cancellables)
    }

    private func filterSections(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.sections = allSections
            return
        }

        self.sections = allSections.compactMap { section in
            let filteredItems = section.items.filter { item in
                item.title.localizedCaseInsensitiveContains(trimmed) ||
                item.subtitle.localizedCaseInsensitiveContains(trimmed) ||
                section.title.localizedCaseInsensitiveContains(trimmed)
            }
            if filteredItems.isEmpty {
                return nil
            }
            return MoreSection(
                id: section.id,
                title: section.title,
                actionTitle: section.actionTitle,
                items: filteredItems
            )
        }
    }
}
