import Foundation

/// Drives the search screen. `@MainActor` pins all published state
/// mutations to the main thread, while the actual network call happens
/// off the main actor inside `GitHubService`.
@MainActor
@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([GitHubUser])
        case empty
        case failed(String)
    }

    private(set) var state: State = .idle
    var query: String = "" {
        didSet { scheduleSearch() }
    }

    private let service: GitHubServiceProtocol
    /// Holds the currently running debounce+search task so a new keystroke
    /// can cancel the previous, still-in-flight one instead of racing it.
    private var searchTask: Task<Void, Never>?

    init(service: GitHubServiceProtocol) {
        self.service = service
    }

    private func scheduleSearch() {
        searchTask?.cancel()

        let currentQuery = query
        guard !currentQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .idle
            return
        }

        searchTask = Task {
            // Debounce: wait a beat before firing the request so we don't
            // hit the API on every keystroke. `Task.sleep` is cancellable,
            // so cancelling the task (a new keystroke arrived) throws here
            // and we bail out before ever calling the network.
            do {
                try await Task.sleep(for: .milliseconds(350))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }

            state = .loading
            do {
                let users = try await service.searchUsers(matching: currentQuery)
                guard !Task.isCancelled else { return }
                state = users.isEmpty ? .empty : .loaded(users)
            } catch is CancellationError {
                // Superseded by a newer search; leave state untouched.
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed((error as? APIError)?.errorDescription ?? error.localizedDescription)
            }
        }
    }

    func cancelInFlightSearch() {
        searchTask?.cancel()
    }
}
