import Foundation

// MARK: - Search response

struct GitHubSearchResponse: Decodable, Sendable {
    let totalCount: Int
    let items: [GitHubUser]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

// MARK: - User

struct GitHubUser: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let login: String
    let avatarURL: URL?
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

/// Extra profile fields only returned by the "get single user" endpoint,
/// fetched separately (in parallel with repositories) on the detail screen.
struct GitHubUserProfile: Decodable, Equatable, Sendable {
    let login: String
    let name: String?
    let bio: String?
    let avatarURL: URL?
    let followers: Int
    let following: Int
    let publicRepos: Int
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case login, name, bio, followers, following
        case avatarURL = "avatar_url"
        case publicRepos = "public_repos"
        case htmlURL = "html_url"
    }
}

// MARK: - Repository

struct GitHubRepository: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let fullName: String
    let repositoryDescription: String?
    let stargazersCount: Int
    let language: String?
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case id, name, language
        case fullName = "full_name"
        case repositoryDescription = "description"
        case stargazersCount = "stargazers_count"
        case htmlURL = "html_url"
    }
}

// MARK: - Errors

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding
    case rateLimited
    case cancelled
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .httpStatus(let code):
            return "O servidor respondeu com o código \(code)."
        case .decoding:
            return "Não foi possível interpretar os dados recebidos."
        case .rateLimited:
            return "Limite de requisições da API do GitHub atingido. Tente novamente mais tarde."
        case .cancelled:
            return "Requisição cancelada."
        case .underlying(let message):
            return message
        }
    }
}
