// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public class ServerManager {
    public static let shared = ServerManager()
    private init() {}

    internal static var baseURL: String = ""
    private static var client: HTTPClient = HTTPClient()
    private static var reachability: NetworkReachabilityProtocol = NetworkReachability()

    public static func initialize(baseURL: String) {
        Self.baseURL = baseURL
        // Rebuild the HTTPClient with the shared reachability so only one NWPathMonitor is used.
        Self.client = HTTPClient(
            session: URLSessionAdapter(),
            decoder: JSONDecoder(),
            encoder: JSONEncoder(),
            logger: Logger(),
            retryPolicy: .default,
            reachability: Self.reachability
        )
    }

    // Static method to construct full URL
    private static func constructURL(path: String) -> String {
        return baseURL + path
    }

    // MARK: - Request Method
    public static func requestWithBody<T: Codable, U: Codable>(
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
        let request = try builder.buildRequestWithBody(
            path: path,
            method: method,
            query: queryParameters,
            body: body
        )
        return try await client.execute(request, maxRetries: maxRetries)
    }
    
    public static func requestWithoutBody<U: Codable>(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30.0,
        maxRetries: Int = 1
    ) async throws -> U {
        let builder = RequestBuilder(
            baseURL: baseURL,
            defaultHeaders: headers ?? [:],
            timeoutInterval: timeoutInterval
        )
        let request = try builder.buildRequestWithoutBody(
            path: path,
            method: method,
            query: queryParameters
        )
        return try await client.execute(request, maxRetries: maxRetries)
    }
}
