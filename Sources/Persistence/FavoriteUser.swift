import Foundation
import SwiftData

/// SwiftData model persisted locally so the user's favorited GitHub
/// profiles survive app relaunches. All CRUD from `FavoritesViewModel`
/// happens on the main actor, matching SwiftData's `ModelContext` model.
@Model
final class FavoriteUser {
    @Attribute(.unique) var login: String
    var avatarURLString: String?
    var htmlURLString: String
    var addedAt: Date

    init(login: String, avatarURLString: String?, htmlURLString: String, addedAt: Date = .now) {
        self.login = login
        self.avatarURLString = avatarURLString
        self.htmlURLString = htmlURLString
        self.addedAt = addedAt
    }

    var avatarURL: URL? {
        avatarURLString.flatMap(URL.init(string:))
    }

    var htmlURL: URL {
        URL(string: htmlURLString) ?? URL(string: "https://github.com")!
    }
}
