import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteUser.addedAt, order: .reverse) private var favorites: [FavoriteUser]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(favorites) { favorite in
                            NavigationLink(value: favorite.login) {
                                FavoriteRowView(favorite: favorite)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .navigationDestination(for: String.self) { login in
                        UserDetailView(login: login)
                    }
                }
            }
            .gitFolioBackground()
            .navigationTitle("Favoritos")
            .gitFolioNavigationBar()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "star")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(GitFolioTheme.accent)
                .frame(width: 76, height: 76)
                .background {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                }

            VStack(spacing: 6) {
                Text("Nenhum favorito ainda")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("Favorite um perfil na tela de detalhes para vê-lo aqui.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.70))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(28)
        .frame(maxWidth: 360)
        .gitFolioCard()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
        try? modelContext.save()
    }
}

private struct FavoriteRowView: View {
    let favorite: FavoriteUser

    var body: some View {
        HStack(spacing: 14) {
            CachedAsyncImage(url: favorite.avatarURL)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(GitFolioTheme.accent.opacity(0.65), lineWidth: 1.5)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(favorite.login)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Label("Favorito salvo", systemImage: "star.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.62))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(GitFolioTheme.secondaryAccent)
        }
        .gitFolioCard()
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: FavoriteUser.self, inMemory: true)
}
