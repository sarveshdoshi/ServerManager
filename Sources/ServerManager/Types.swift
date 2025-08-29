import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public enum NetworkingError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(String, Error)
    case unexpectedStatusCode(Int)
    case noInternet
}


