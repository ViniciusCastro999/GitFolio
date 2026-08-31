import SwiftUI

/// Lightweight dependency injection using SwiftUI's Environment, so
/// ViewModels/Views can receive a `GitHubServiceProtocol` implementation
/// without a global singleton. Makes previews and tests trivial to set up.
private struct GitHubServiceKey: EnvironmentKey {
    static let defaultValue: GitHubServiceProtocol = GitHubService()
}

extension EnvironmentValues {
    var gitHubService: GitHubServiceProtocol {
        get { self[GitHubServiceKey.self] }
        set { self[GitHubServiceKey.self] = newValue }
    }
}
