import Foundation
@testable import GitFolio

/// Fake `NetworkServiceProtocol` used by tests to avoid real network calls.
/// Results are keyed by URL so a single mock can serve multiple endpoints
/// in the same test (e.g. profile + repos fetched via `TaskGroup`).
actor MockNetworkService: NetworkServiceProtocol {
    enum Result {
        case success(Any)
        case failure(Error)
    }

    private var results: [URL: Result] = [:]
    private(set) var requestedURLs: [URL] = []

    func stub<T>(_ url: URL, with value: T) {
        results[url] = .success(value)
    }

    func stub(_ url: URL, throwing error: Error) {
        results[url] = .failure(error)
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        requestedURLs.append(url)

        guard let result = results[url] else {
            throw APIError.invalidResponse
        }

        switch result {
        case .success(let value):
            guard let typed = value as? T else {
                throw APIError.decoding
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}
