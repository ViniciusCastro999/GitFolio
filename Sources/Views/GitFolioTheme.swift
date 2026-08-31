import SwiftUI

enum GitFolioTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.06, blue: 0.10),
            Color(red: 0.07, green: 0.10, blue: 0.16),
            Color(red: 0.02, green: 0.12, blue: 0.14)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(red: 0.24, green: 0.88, blue: 0.78)
    static let secondaryAccent = Color(red: 0.62, green: 0.74, blue: 1.00)
    static let cardStroke = Color.white.opacity(0.12)
}

struct GitFolioCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.075))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(GitFolioTheme.cardStroke, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.24), radius: 16, x: 0, y: 10)
    }
}

extension View {
    func gitFolioCard() -> some View {
        modifier(GitFolioCardModifier())
    }

    func gitFolioBackground() -> some View {
        background {
            GitFolioTheme.background
                .ignoresSafeArea()
        }
    }
}

struct MetricChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.88))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(Color.white.opacity(0.08))
            }
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            }
    }
}
