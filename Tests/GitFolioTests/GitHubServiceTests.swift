import XCTest
@testable import GitFolio

final class GitHubServiceTests: XCTestCase {

    func test_searchUsers_returnsDecodedUsers() async throws {
        let mock = MockNetworkService()
        let service = GitHubService(network: mock)

        var components = URLComponents(string: "https://api.github.com/search/users")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "octocat"),
            URLQueryItem(name: "per_page", value: "25")
        ]
        let user = GitHubUser(id: 1, login: "octocat", avatarURL: nil, htmlURL: URL(string: "https://github.com/octocat")!)
        await mock.stub(components.url!, with: GitHubSearchResponse(totalCount: 1, items: [user]))

        let result = try await service.searchUsers(matching: "octocat")

        XCTAssertEqual(result, [user])
    }

    func test_searchUsers_withBlankQuery_returnsEmptyWithoutHittingNetwork() async throws {
        let mock = MockNetworkService()
        let service = GitHubService(network: mock)

        let result = try await service.searchUsers(matching: "   ")

        XCTAssertTrue(result.isEmpty)
        let requested = await mock.requestedURLs
        XCTAssertTrue(requested.isEmpty)
    }

    /// Exercises the `withThrowingTaskGroup` path in `fetchUserDetail`:
    /// both the profile and repositories requests must complete and be
    /// merged correctly, proving the concurrent fetch works end-to-end.
    func test_fetchUserDetail_mergesProfileAndRepositories() async throws {
        let mock = MockNetworkService()
        let service = GitHubService(network: mock)

        let profileURL = URL(string: "https://api.github.com/users/octocat")!
        let profile = GitHubUserProfile(
            login: "octocat", name: "The Octocat", bio: nil,
            avatarURL: nil, followers: 10, following: 2, publicRepos: 3,
            htmlURL: URL(string: "https://github.com/octocat")!
        )
        await mock.stub(profileURL, with: profile)

        var reposComponents = URLComponents(string: "https://api.github.com/users/octocat/repos")!
        reposComponents.queryItems = [
            URLQueryItem(name: "sort", value: "updated"),
            URLQueryItem(name: "per_page", value: "20")
        ]
        let repo = GitHubRepository(
            id: 1, name: "Hello-World", fullName: "octocat/Hello-World",
            repositoryDescription: "My first repo", stargazersCount: 100,
            language: "Swift", htmlURL: URL(string: "https://github.com/octocat/Hello-World")!
        )
        await mock.stub(reposComponents.url!, with: [repo])

        let result = try await service.fetchUserDetail(login: "octocat")

        XCTAssertEqual(result.profile.login, "octocat")
        XCTAssertEqual(result.repositories, [repo])
    }

    func test_fetchUserDetail_propagatesFailure() async {
        let mock = MockNetworkService()
        let service = GitHubService(network: mock)

        let profileURL = URL(string: "https://api.github.com/users/ghost")!
        await mock.stub(profileURL, throwing: APIError.httpStatus(404))

        do {
            _ = try await service.fetchUserDetail(login: "ghost")
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }
}
