import Foundation

/// Race `operation` against a sleep so a slow widget falls back to its own mount-time open
/// (header first, rows later) instead of stalling the whole pre-warm gate.
@MainActor
func withPrewarmTimeout<T: Sendable>(
    seconds: TimeInterval,
    operation: @escaping @MainActor () async -> T?
) async -> T? {
    await withTaskGroup(of: T?.self) { group in
        group.addTask { @MainActor in await operation() }
        group.addTask {
            try? await Task.sleep(for: .seconds(seconds))
            return nil
        }
        defer { group.cancelAll() }
        // `next()` returns Element? = T??; the `?? nil` flattens to T?.
        return await group.next() ?? nil
    }
}
