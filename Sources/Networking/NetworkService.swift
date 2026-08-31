import Foundation

/// Abstraction over URLSession so the rest of the app depends only on
/// this protocol. This is what makes the ViewModels/Services unit-testable
/// with a fake implementation instead of hitting the real network.
protocol NetworkServiceProtocol: Sendable {
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}

struct NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let request = URLRequest(url: url)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw APIError.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw APIError.cancelled
        } catch {
            throw APIError.underlying(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 403 || httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
