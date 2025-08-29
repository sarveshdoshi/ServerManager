// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation


public class ServerManager {
    public static let shared = ServerManager()
    private init() {}

    internal static var baseURL: String = ""
    private static var client: HTTPClient = HTTPClient()

    public static func initialize(baseURL: String) {
        Self.baseURL = baseURL
    }

    // Static method to construct full URL
    private static func constructURL(path: String) -> String {
        return baseURL + path
    }


    // MARK: - Request Method
    public static func request<T: Codable, U: Codable>(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: String]? = nil,
        body: T? = nil,
        headers: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30.0,
        maxRetries: Int = 1
    ) async throws -> U {
        let builder = RequestBuilder(
            baseURL: baseURL,
            defaultHeaders: headers ?? [:],
            timeoutInterval: timeoutInterval
        )
        let request = try builder.buildRequest(
            path: path,
            method: method,
            query: queryParameters,
            body: body
        )
        return try await client.execute(request, maxRetries: maxRetries)
    }
}
