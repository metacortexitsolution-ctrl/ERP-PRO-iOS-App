//
//  APIManager.swift
//  ERP-PRO-iOS-App
//

import Foundation

/// Protocol abstraction for fetching authorization tokens securely from the security layer.
public protocol TokenProviding: AnyObject {
    func getAuthToken() -> String?
}

/// Centralized API errors returned to feature callers.
public enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case timeout
    case unauthorized
    case forbidden
    case notFound
    case validationError(Data?)
    case serverError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .networkError(let error):
            return "Network connection failed: \(error.localizedDescription)"
        case .timeout:
            return "The request timed out."
        case .unauthorized:
            return "Unauthorized access. Please log in again."
        case .forbidden:
            return "You do not have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .validationError:
            return "Validation error occurred."
        case .serverError(let statusCode, _):
            return "Server error occurred with status code \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

/// Centralized Singleton API Manager for executing all network requests across the ERP application.
public final class APIManager {
    public static let shared = APIManager()

    /// Delegate token provider from the centralized Security/Authentication layer.
    public weak var tokenProvider: TokenProviding?

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Makes a generic API request and decodes the response into a Codable model `T`.
    public func request<T: Decodable>(_ apiRequest: APIRequest) async throws -> T {
        let urlRequest = try buildURLRequest(from: apiRequest)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError {
            if error.code == .timedOut {
                throw APIError.timeout
            } else {
                throw APIError.networkError(error)
            }
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        try validateStatusCode(httpResponse.statusCode, data: data)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    /// Makes an API request without expecting a decodable response body.
    public func requestWithoutResponse(_ apiRequest: APIRequest) async throws {
        let urlRequest = try buildURLRequest(from: apiRequest)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError {
            if error.code == .timedOut {
                throw APIError.timeout
            } else {
                throw APIError.networkError(error)
            }
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        try validateStatusCode(httpResponse.statusCode, data: data)
    }

    // MARK: - Private Helpers

    private func buildURLRequest(from apiRequest: APIRequest) throws -> URLRequest {
        var urlString = apiRequest.endpoint
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            let base = APIConstant.baseURL
            if !base.isEmpty {
                urlString = base + (urlString.hasPrefix("/") ? urlString : "/" + urlString)
            }
        }

        guard var components = URLComponents(string: urlString) else {
            throw APIError.invalidURL
        }

        if let queryParams = apiRequest.queryParams, !queryParams.isEmpty {
            var queryItems = components.queryItems ?? []
            for (key, value) in queryParams {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }

        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = apiRequest.method.rawValue
        urlRequest.timeoutInterval = apiRequest.timeoutInterval ?? APIConstant.defaultTimeout

        // Centralized Common Headers
        urlRequest.setValue(APIConstant.ContentType.json, forHTTPHeaderField: APIConstant.Headers.contentType)
        urlRequest.setValue(APIConstant.ContentType.json, forHTTPHeaderField: APIConstant.Headers.accept)

        if let token = tokenProvider?.getAuthToken(), !token.isEmpty {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: APIConstant.Headers.authorization)
        }

        // Custom Feature Headers
        if let customHeaders = apiRequest.headers {
            for (key, value) in customHeaders {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Encode Body if present
        if let body = apiRequest.body {
            do {
                let encoder = JSONEncoder()
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.decodingError(error)
            }
        }

        return urlRequest
    }

    private func validateStatusCode(_ statusCode: Int, data: Data) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 422:
            throw APIError.validationError(data)
        case 400...499, 500...599:
            throw APIError.serverError(statusCode: statusCode, data: data)
        default:
            throw APIError.unknown
        }
    }
}
