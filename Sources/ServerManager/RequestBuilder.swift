import Foundation

struct RequestBuilder {
    var baseURL: String
    var defaultHeaders: [String: String] = [:]
    var timeoutInterval: TimeInterval = 30.0

    func buildRequest<T: Codable>(
        path: String,
        method: HTTPMethod,
        query: [String: String]?,
        body: T?
    ) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkingError.invalidURL
        }

        if let query = query, !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else { throw NetworkingError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval

        for (k, v) in defaultHeaders { request.setValue(v, forHTTPHeaderField: k) }

        if method != .get, let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}


