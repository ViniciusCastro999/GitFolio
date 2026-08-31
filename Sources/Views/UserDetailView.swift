import SwiftUI
import SwiftData

struct UserDetailView: View {
    let login: String

    @Environment(\.gitHubService) private var gitHubService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: UserDetailViewModel?
    @State private var favoritesViewModel: FavoritesViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(for: viewModel)
            } else {
                ProgressView()
                    .tint(GitFolioTheme.accent)
            }
        }
        .gitFolioBackground()
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            if viewModel == nil {
                let vm = UserDetailViewModel(login: login, service: gitHubService)
                viewModel = vm
                favoritesViewModel = FavoritesViewModel(modelContext: modelContext)
                vm.load()
            }
        }
        .onDisappear { viewModel?.cancel() }
    }

    @ViewBuilder
    private func content(for viewModel: UserDetailViewModel) -> some View {
        switch viewModel.state {
        case .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                    .tint(GitFolioTheme.accent)
                Text("Carregando perfil...")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.86))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(GitFolioTheme.accent)
                    Text("Não foi possível carregar")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.70))
                        .multilineTextAlignment(.center)
                }

                Button { viewModel.load() } label: {
                    Label("Tentar novamente", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(GitFolioTheme.accent)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .gitFolioCard()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        case .loaded(let profile, let repositories):
            List {
                Section {
                    profileHeader(profile)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                Section {
                    ForEach(repositories) { repo in
                        RepositoryRowView(repository: repo)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    Text("Repositórios (\(repositories.count))")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))
                        .textCase(.uppercase)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle(profile.login)
            .toolbar {
                if let favoritesViewModel {
                    Button {
                        favoritesViewModel.toggleFavorite(profile: profile)
                    } label: {
                        Image(systemName: favoritesViewModel.isFavorite(login: profile.login) ? "star.fill" : "star")
                            .foregroundStyle(GitFolioTheme.accent)
                    }
                }
            }
        }
    }

    private func profileHeader(_ profile: GitHubUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                CachedAsyncImage(url: profile.avatarURL)
                    .frame(width: 82, height: 82)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(GitFolioTheme.accent.opacity(0.75), lineWidth: 2)
                    }
                    .shadow(color: GitFolioTheme.accent.opacity(0.25), radius: 16, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 7) {
                    Text(profile.name ?? profile.login)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text("@\(profile.login)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(GitFolioTheme.accent)

                    if let bio = profile.bio {
                        Text(bio)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.72))
                            .lineLimit(4)
                    }
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], alignment: .leading, spacing: 8) {
                MetricChip(title: "\(profile.followers) seguidores", systemImage: "person.2.fill")
                MetricChip(title: "\(profile.following) seguindo", systemImage: "person.crop.circle.badge.checkmark")
                MetricChip(title: "\(profile.publicRepos) repos", systemImage: "shippingbox.fill")
            }
        }
        .gitFolioCard()
    }
}

#Preview {
    NavigationStack {
        UserDetailView(login: "apple")
    }
}
