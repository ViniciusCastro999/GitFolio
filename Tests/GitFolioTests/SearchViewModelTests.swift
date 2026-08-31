import XCTest
@testable import GitFolio

@MainActor
final class SearchViewModelTests: XCTestCase {

    func test_search_transitionsThroughLoadingToLoaded() async throws {
        let stub = StubGitHubService()
        stub.usersToReturn = [
            GitHubUser(id: 1, login: "octocat", avatarURL: nil, htmlURL: URL(string: "https://github.com/octocat")!)
        ]
        let viewModel = SearchViewModel(service: stub)

        viewModel.query = "octo"

        // The view model debounces for 350ms before firing the request;
        // wait past that window, then poll briefly for the async result.
        try await Task.sleep(for: .milliseconds(500))

        XCTAssertEqual(viewModel.state, .loaded(stub.usersToReturn))
    }

    func test_emptyQuery_resetsStateToIdle() async throws {
        let stub = StubGitHubService()
        let viewModel = SearchViewModel(service: stub)

        viewModel.query = "octo"
        try await Task.sleep(for: .milliseconds(500))
        viewModel.query = ""

        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_rapidTyping_onlyResultsInLastSearchWinning() async throws {
        let stub = StubGitHubService()
        stub.usersToReturn = [
            GitHubUser(id: 2, login: "final-query-user", avatarURL: nil, htmlURL: URL(string: "https://github.com/x")!)
        ]
        let viewModel = SearchViewModel(service: stub)

        // Simulate fast typing: each assignment cancels the previous
        // debounce task via `didSet { scheduleSearch() }`.
        viewModel.query = "o"
        viewModel.query = "oc"
        viewModel.query = "octo"

        try await Task.sleep(for: .milliseconds(500))

        XCTAssertEqual(stub.receivedQueries.count, 1)
        XCTAssertEqual(stub.receivedQueries.first, "octo")
    }
}

/// Simple stub (as opposed to the URL-based `MockNetworkService`) since
/// these tests care about ViewModel state transitions, not networking.
private final class StubGitHubService: GitHubServiceProtocol, @unchecked Sendable {
    var usersToReturn: [GitHubUser] = []
    private(set) var receivedQueries: [String] = []

    func searchUsers(matching query: String) async throws -> [GitHubUser] {
        receivedQueries.append(query)
        return usersToReturn
    }

    func fetchUserDetail(login: String) async throws -> (profile: GitHubUserProfile, repositories: [GitHubRepository]) {
        fatalError("Not used in these tests")
    }
}
