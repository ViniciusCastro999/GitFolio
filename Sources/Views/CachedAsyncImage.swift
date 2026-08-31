import SwiftUI

/// Small wrapper around the actor-based `ImageCache`. Unlike SwiftUI's
/// built-in `AsyncImage`, repeated appearances of the same URL (e.g.
/// scrolling a list back into view) hit the in-memory cache instead of
/// re-downloading, and concurrent requests for the same URL are coalesced.
struct CachedAsyncImage: View {
    let url: URL?

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                GitFolioTheme.accent.opacity(0.28),
                                GitFolioTheme.secondaryAccent.opacity(0.20),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.72))
                    }
            }
        }
        .task(id: url) {
            guard let url else { return }
            image = await ImageCache.shared.image(for: url)
        }
    }
}
