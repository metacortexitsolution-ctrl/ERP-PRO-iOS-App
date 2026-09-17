//
//  APIRequest.swift
//  ERP-PRO-iOS-App
//

import Foundation

/// Defines the HTTP request methods supported by the API Manager.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// Reusable object representing all parameters required to execute an API request.
public struct APIRequest {
    public let endpoint: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let body: Encodable?
    public let queryParams: [String: String]?
    public let timeoutInterval: TimeInterval?

    public init(
        endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Encodable? = nil,
        queryParams: [String: String]? = nil,
        timeoutInterval: TimeInterval? = nil
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.body = body
        self.queryParams = queryParams
        self.timeoutInterval = timeoutInterval
    }
}
