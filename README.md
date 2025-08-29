# ServerManager

A lightweight, testable HTTP client for Swift with async await along with retries, logging, and iOS 13+ compatibility.

## Requirements
- iOS 13+, tvOS 12+, macOS 11+
- Swift tools 5.7+

## Installation (Swift Package Manager)
- In Xcode: File → Add Packages… → enter your repository URL → Add Package
- Link the `ServerManager` library to your app target

Or add to your `Package.swift`:
```swift
.package(url: "https://github.com/sarveshdoshi/ServerManager.git", from: "1.0.0")
```

## Quick Start
Initialize once (e.g., at app startup):
```swift
import ServerManager

ServerManager.initialize(baseURL: "https://api.example.com")
```

### GET without body
```swift
struct User: Codable { let id: Int; let name: String }

let user: User = try await ServerManager.request(
    path: "/users/1",
    method: .get,
    queryParameters: ["include": "profile"],
    maxRetries: 2
)
```

### POST with JSON body
```swift
struct CreateUserRequest: Codable { let name: String }
struct CreateUserResponse: Codable { let id: Int }

let created: CreateUserResponse = try await ServerManager.request(
    path: "/users",
    method: .post,
    body: CreateUserRequest(name: "Alice"),
    headers: ["Authorization": "Bearer <token>"],
    timeoutInterval: 20,
    maxRetries: 3
)
```

### PUT to update a resource
```swift
struct UpdateUserRequest: Codable { let name: String; let email: String }

let updated: User = try await ServerManager.request(
    path: "/users/1",
    method: .put,
    body: UpdateUserRequest(name: "Alice Updated", email: "alice@example.com"),
    headers: ["Authorization": "Bearer <token>"]
)
```

### PATCH for partial updates
```swift
struct PatchUserRequest: Codable { let name: String? }

let patched: User = try await ServerManager.request(
    path: "/users/1",
    method: .patch,
    body: PatchUserRequest(name: "New Name"),
    headers: ["Authorization": "Bearer <token>"]
)
```

### DELETE a resource
```swift
let deleted: EmptyResponse = try await ServerManager.request(
    path: "/users/1",
    method: .delete,
    headers: ["Authorization": "Bearer <token>"]
)
```

### Error handling
```swift
import ServerManager

do {
    let _: User = try await ServerManager.request(path: "/users/404", method: .get)
} catch let error as NetworkingError {
    switch error {
    case .invalidURL: break
    case .invalidResponse: break
    case .unexpectedStatusCode(let status): print(status)
    case .decodingFailed(let context, let underlying): print(context, underlying)
    case .requestFailed(let underlying): print(underlying)
    case .noInternet: 
        print("No internet connection available")
        // Handle offline state - show cached data, offline message, etc.
        break
    }
} catch {
    print("Unknown error: \(error)")
}
```

## What’s inside
- `HTTPClient`: Executes requests with exponential backoff + jitter retry policy
- `RequestBuilder`: Builds `URLRequest` from path, method, query, headers, body
- `NetworkingError`: Unified error surface
- `Logger`: Structured logs with pretty-printed JSON (toggle-able)
- `URLSessionAdapter`: iOS 13-friendly async wrapper around `URLSession`

## Testing
Use a mock session to simulate server behavior:
```swift
import XCTest
@testable import ServerManager

final class ExampleTests: XCTestCase {
    private final class MockSession: NetworkSession {
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            let body = try JSONEncoder().encode(["message": "ok"]) // sample payload
            let url = request.url ?? URL(string: "https://example.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (body, response)
        }
    }

    func test_example() async throws {
        let client = HTTPClient(session: MockSession())
        let builder = RequestBuilder(baseURL: "https://api.example.com")
        let request = try builder.buildRequest(path: "/ping", method: .get, query: nil, body: Optional<String>.none)
        let result: [String: String] = try await client.execute(request, maxRetries: 0)
        XCTAssertEqual(result["message"], "ok")
    }
}
```

## Customization
You can inject your own dependencies via `HTTPClient` initializer:
- `NetworkSession` (custom `URLSession` or mock)
- `NetworkReachabilityProtocol` (custom network monitoring or mock)
- `JSONDecoder` and `JSONEncoder`
- `Logger`
- `RetryPolicy`

## Recommended usage pattern
- Keep app-specific request/response DTOs and concrete endpoints in your app
- Keep the package focused on transport, retries, logging, and error handling

## License
MIT License - see [LICENSE](LICENSE) file for details

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## Support
If you encounter any issues or have questions, please [open an issue](https://github.com/sarveshdoshi/ServerManager/issues) on GitHub.
