import SwiftUI

struct SearchView: View {
    @Environment(\.gitHubService) private var gitHubService
    @State private var viewModel: SearchViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(for: viewModel)
                } else {
                    ProgressView()
                        .tint(GitFolioTheme.accent)
                }
            }
            .gitFolioBackground()
            .navigationTitle("GitFolio")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(
                text: Binding(
                    get: { viewModel?.query ?? "" },
                    set: { viewModel?.query = $0 }
                ),
                prompt: "Buscar usuários do GitHub"
            )
        }
        .task {
            if viewModel == nil {
                viewModel = SearchViewModel(service: gitHubService)
            }
        }
    }

    @ViewBuilder
    private func content(for viewModel: SearchViewModel) -> some View {
        switch viewModel.state {
        case .idle:
            unavailableView(
                title: "Busque um desenvolvedor",
                systemImage: "person.crop.circle.badge.questionmark",
                message: "Digite um nome de usuário do GitHub para começar."
            )
        case .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                    .tint(GitFolioTheme.accent)
                Text("Buscando...")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.86))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            unavailableView(
                title: "Nenhum resultado",
                systemImage: "magnifyingglass",
                message: "Tente outro nome de usuário."
            )
        case .failed(let message):
            unavailableView(
                title: "Algo deu errado",
                systemImage: "exclamationmark.triangle",
                message: message
            )
        case .loaded(let users):
            List(users) { user in
                NavigationLink(value: user) {
                    UserRowView(user: user)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationDestination(for: GitHubUser.self) { user in
                UserDetailView(login: user.login)
            }
        }
    }

    private func unavailableView(title: String, systemImage: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(GitFolioTheme.accent)
                .frame(width: 76, height: 76)
                .background {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                }

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text(message)
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
}

private struct UserRowView: View {
    let user: GitHubUser

    var body: some View {
        HStack(spacing: 14) {
            CachedAsyncImage(url: user.avatarURL)
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(GitFolioTheme.accent.opacity(0.65), lineWidth: 1.5)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(user.login)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Label("Perfil GitHub", systemImage: "terminal")
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
    SearchView()
}
