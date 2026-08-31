import UIKit

/// Actor-backed in-memory image cache.
///
/// Using an `actor` here (instead of a class + lock, or NSCache directly
/// accessed from multiple tasks) guarantees the internal dictionary can
/// never be mutated by two concurrent tasks at once — the compiler enforces
/// it. This is one of the clearest, smallest demonstrations of Swift's
/// data-race safety model in the project.
actor ImageCache {
    static let shared = ImageCache()

    private var storage: [URL: UIImage] = [:]
    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]

    private init() {}

    func image(for url: URL) async -> UIImage? {
        if let cached = storage[url] {
            return cached
        }

        // Coalesce duplicate requests for the same URL (e.g. the same
        // avatar shown in a list and a detail screen at the same time)
        // into a single network call.
        if let existingTask = inFlightTasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }
        inFlightTasks[url] = task

        let image = await task.value
        inFlightTasks[url] = nil
        if let image {
            storage[url] = image
        }
        return image
    }
}
