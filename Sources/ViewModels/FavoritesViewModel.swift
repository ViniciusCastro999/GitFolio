import Foundation
import SwiftData

/// Thin wrapper around a SwiftData `ModelContext`. Kept as an
/// `@Observable` class (rather than doing raw `@Query` in the view) so the
/// add/remove/toggle logic is unit-testable independent of SwiftUI.
@MainActor
@Observable
final class FavoritesViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func isFavorite(login: String) -> Bool {
        let descriptor = FetchDescriptor<FavoriteUser>(predicate: #Predicate { $0.login == login })
        return ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }

    @discardableResult
    func toggleFavorite(profile: GitHubUserProfile) -> Bool {
        let login = profile.login
        let descriptor = FetchDescriptor<FavoriteUser>(predicate: #Predicate { $0.login == login })
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try? modelContext.save()
            return false
        } else {
            let favorite = FavoriteUser(
                login: profile.login,
                avatarURLString: profile.avatarURL?.absoluteString,
                htmlURLString: profile.htmlURL.absoluteString
            )
            modelContext.insert(favorite)
            try? modelContext.save()
            return true
        }
    }

    func remove(_ favorite: FavoriteUser) {
        modelContext.delete(favorite)
        try? modelContext.save()
    }
}
