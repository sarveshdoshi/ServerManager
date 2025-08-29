import Foundation

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

final class HTTPClient {
    private let session: NetworkSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let logger: Logger
    private let retryPolicy: RetryPolicy
    private let reachability: NetworkReachabilityProtocol

    init(
        session: NetworkSession = URLSessionAdapter(),
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        logger: Logger = .init(),
        retryPolicy: RetryPolicy = .default,
        reachability: NetworkReachabilityProtocol = NetworkReachability()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.logger = logger
        self.retryPolicy = retryPolicy
        self.reachability = reachability
    }

    func execute<Response: Codable>(
        _ request: URLRequest,
        maxRetries: Int
    ) async throws -> Response {
        // Check network connectivity before making request
        guard reachability.isNetworkAvailable else {
            logger.error("No internet connection available")
            throw NetworkingError.noInternet
        }
        
        var attemptIndex = 0
        var lastError: Error?

        while attemptIndex <= maxRetries {
            do {
                logger.info("📤 Executing request: \(request.httpMethod ?? "-") \(request.url?.absoluteString ?? "-")")
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkingError.invalidResponse
                }

                logger.info("📡 Response status: \(httpResponse.statusCode)")

                try Self.validateStatusCode(httpResponse.statusCode)
                do {
                    let decoded = try decoder.decode(Response.self, from: data)
                    logger.prettyJSON(data)
                    return decoded
                } catch {
                    logger.error("Decoding failed into \(Response.self): \(error)")
                    if let raw = String(data: data, encoding: .utf8) {
                        logger.error("Raw body: \(raw)")
                    }
                    throw NetworkingError.decodingFailed("Failed to decode response into type \(Response.self)", error)
                }
            } catch {
                lastError = error
                if attemptIndex < maxRetries, retryPolicy.shouldRetry(error: error, attempt: attemptIndex) {
                    let delay = retryPolicy.delay(for: attemptIndex)
                    logger.info("🔁 Retry #\(attemptIndex + 1) in \(String(format: "%.2f", delay))s due to: \(error)")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    attemptIndex += 1
                    continue
                }
                break
            }
        }

        throw lastError ?? NetworkingError.requestFailed(NSError(domain: "", code: -1, userInfo: nil))
    }

    private static func validateStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkingError.unexpectedStatusCode(statusCode)
        case 403:
            throw NetworkingError.unexpectedStatusCode(statusCode)
        case 404:
            throw NetworkingError.unexpectedStatusCode(statusCode)
        case 429:
            throw NetworkingError.unexpectedStatusCode(statusCode)
        case 500...599:
            throw NetworkingError.unexpectedStatusCode(statusCode)
        default:
            throw NetworkingError.unexpectedStatusCode(statusCode)
        }
    }
}





