import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem { Label("Buscar", systemImage: "magnifyingglass") }

            FavoritesView()
                .tabItem { Label("Favoritos", systemImage: "star.fill") }
        }
        .tint(GitFolioTheme.accent)
    }
}

#Preview {
    RootTabView()
}
