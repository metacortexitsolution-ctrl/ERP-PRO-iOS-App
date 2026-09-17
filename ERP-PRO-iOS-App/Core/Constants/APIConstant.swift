//
//  APIConstant.swift
//  ERP-PRO-iOS-App
//

import Foundation

public struct APIConstant {
    /// Base URL for the ERP API backend. Endpoint paths will be appended to this.
    public static var baseURL: String = ""
    
    /// Default request timeout interval in seconds.
    public static let defaultTimeout: TimeInterval = 30.0
    
    public struct Headers {
        public static let contentType = "Content-Type"
        public static let accept = "Accept"
        public static let authorization = "Authorization"
    }
    
    public struct ContentType {
        public static let json = "application/json"
    }
    
    public struct QueryParams {
        public static let page = "page"
        public static let limit = "limit"
        public static let search = "search"
        public static let sort = "sort"
    }
}
