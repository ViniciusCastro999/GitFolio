import Foundation

@MainActor
@Observable
final class UserDetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(profile: GitHubUserProfile, repositories: [GitHubRepository])
        case failed(String)
    }

    private(set) var state: State = .loading

    private let login: String
    private let service: GitHubServiceProtocol
    private var loadTask: Task<Void, Never>?

    init(login: String, service: GitHubServiceProtocol) {
        self.login = login
        self.service = service
    }

    func load() {
        loadTask?.cancel()
        state = .loading
        loadTask = Task {
            do {
                let result = try await service.fetchUserDetail(login: login)
                guard !Task.isCancelled else { return }
                state = .loaded(profile: result.profile, repositories: result.repositories)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed((error as? APIError)?.errorDescription ?? error.localizedDescription)
            }
        }
    }

    func cancel() {
        loadTask?.cancel()
    }
}
