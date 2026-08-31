import SwiftUI

struct RepositoryRowView: View {
    let repository: GitHubRepository

    var body: some View {
        Link(destination: repository.htmlURL) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.headline)
                        .foregroundStyle(GitFolioTheme.accent)

                    Text(repository.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(GitFolioTheme.secondaryAccent)
                }

                if let description = repository.repositoryDescription {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    if let language = repository.language {
                        MetricChip(title: language, systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    MetricChip(title: "\(repository.stargazersCount)", systemImage: "star.fill")
                }
            }
            .gitFolioCard()
        }
        .buttonStyle(.plain)
    }
}
