import SwiftUI
import SwiftData

@main
struct GitFolioApp: App {
    // SwiftData container used to persist favorite users locally.
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: FavoriteUser.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.gitHubService, GitHubService())
        }
        .modelContainer(modelContainer)
    }
}
