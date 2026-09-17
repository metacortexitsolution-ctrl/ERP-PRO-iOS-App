//
//  DashboardController.swift
//  ERP-PRO-iOS-App
//

import Foundation
import Combine

/// Central controller managing Dashboard state and fetching data strictly via APIManager.
@MainActor
public final class DashboardController: ObservableObject {
    
    public enum State: Equatable {
        case loading
        case loaded(DashboardData)
        case empty
        case error(String)
        
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.empty, .empty):
                return true
            case (.error(let lMsg), .error(let rMsg)):
                return lMsg == rMsg
            case (.loaded, .loaded):
                return true
            default:
                return false
            }
        }
    }
    
    @Published public private(set) var state: State = .loading
    @Published public private(set) var isRefreshing: Bool = false
    
    public init() {}
    
    /// Executes API request using the centralized APIManager.
    public func fetchDashboardData() async {
        if case .loaded = state {
            isRefreshing = true
        } else {
            state = .loading
        }
        
        let apiRequest = APIRequest(
            endpoint: "/api/v1/dashboard",
            method: .get
        )
        
        do {
            // Decoding response wrapper or direct data model
            let response: DashboardResponse = try await APIManager.shared.request(apiRequest)
            
            if let data = response.data {
                if isDataEmpty(data) {
                    state = .empty
                } else {
                    state = .loaded(data)
                }
            } else {
                state = .empty
            }
        } catch let apiError as APIError {
            state = .error(apiError.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
        
        isRefreshing = false
    }
    
    private func isDataEmpty(_ data: DashboardData) -> Bool {
        return data.kpis == nil &&
               data.charts == nil &&
               data.ordersPipeline == nil &&
               (data.topCustomers?.isEmpty ?? true) &&
               (data.pendingApprovals?.isEmpty ?? true) &&
               (data.dealerPerformance?.isEmpty ?? true) &&
               data.supportTicketSummary == nil &&
               (data.recentActivities?.isEmpty ?? true) &&
               (data.lowStockItems?.isEmpty ?? true) &&
               (data.alertBanners?.isEmpty ?? true)
    }
}
