import Foundation

public enum HTTPMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
    
    /// Indicates whether this HTTP method typically supports a request body
    var supportsBody: Bool {
        switch self {
        case .get, .head, .options, .trace, .connect:
            return false
        case .post, .put, .patch, .delete:
            return true
        }
    }
}

public enum NetworkingError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(String, Error)
    case unexpectedStatusCode(Int)
    case noInternet
}


