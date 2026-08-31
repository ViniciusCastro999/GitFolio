import Foundation

protocol GitHubServiceProtocol: Sendable {
    func searchUsers(matching query: String) async throws -> [GitHubUser]
    /// Fetches the user's profile and their repositories concurrently and
    /// returns both once both have finished.
    func fetchUserDetail(login: String) async throws -> (profile: GitHubUserProfile, repositories: [GitHubRepository])
}

/// Talks to the public GitHub REST API (no auth token required for the
/// read-only endpoints used here, though real-world apps would inject one).
struct GitHubService: GitHubServiceProtocol {
    private let network: NetworkServiceProtocol
    private let baseURL = URL(string: "https://api.github.com")!

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    func searchUsers(matching query: String) async throws -> [GitHubUser] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("search/users"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "25")
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let response = try await network.fetch(GitHubSearchResponse.self, from: url)
        return response.items
    }

    func fetchUserDetail(login: String) async throws -> (profile: GitHubUserProfile, repositories: [GitHubRepository]) {
        let profileURL = baseURL.appendingPathComponent("users/\(login)")
        let reposURL = baseURL
            .appendingPathComponent("users/\(login)/repos")
            .appending(queryItems: [
                URLQueryItem(name: "sort", value: "updated"),
                URLQueryItem(name: "per_page", value: "20")
            ])

        // Structured concurrency: both requests run in parallel, and if
        // either one throws, the group cancels the other automatically and
        // rethrows — no manual cancellation bookkeeping needed.
        return try await withThrowingTaskGroup(of: DetailFetchResult.self) { group in
            group.addTask {
                let profile = try await network.fetch(GitHubUserProfile.self, from: profileURL)
                return .profile(profile)
            }
            group.addTask {
                let repos = try await network.fetch([GitHubRepository].self, from: reposURL)
                return .repositories(repos)
            }

            var profile: GitHubUserProfile?
            var repositories: [GitHubRepository]?

            for try await result in group {
                switch result {
                case .profile(let value):
                    profile = value
                case .repositories(let value):
                    repositories = value
                }
            }

            guard let profile, let repositories else {
                throw APIError.invalidResponse
            }
            return (profile, repositories)
        }
    }

    private enum DetailFetchResult: Sendable {
        case profile(GitHubUserProfile)
        case repositories([GitHubRepository])
    }
}
