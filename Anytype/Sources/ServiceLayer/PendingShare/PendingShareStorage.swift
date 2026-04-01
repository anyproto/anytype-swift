import Foundation
import Factory

protocol PendingShareStorageProtocol: AnyObject, Sendable {
    func pendingState(for spaceId: String) -> PendingShareState?
    func savePendingState(_ state: PendingShareState)
    func removePendingState(for spaceId: String)
}

final class PendingShareStorage: PendingShareStorageProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private let key = "PendingShareStates"

    func pendingState(for spaceId: String) -> PendingShareState? {
        lock.lock()
        defer { lock.unlock() }
        return loadAll().first { $0.spaceId == spaceId }
    }

    func savePendingState(_ state: PendingShareState) {
        lock.lock()
        defer { lock.unlock() }
        var all = loadAll()
        if let index = all.firstIndex(where: { $0.spaceId == state.spaceId }) {
            all[index] = state
        } else {
            all.append(state)
        }
        saveAll(all)
    }

    func removePendingState(for spaceId: String) {
        lock.lock()
        defer { lock.unlock() }
        var all = loadAll()
        all.removeAll { $0.spaceId == spaceId }
        saveAll(all)
    }

    // MARK: - Private

    private func loadAll() -> [PendingShareState] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([PendingShareState].self, from: data)) ?? []
    }

    private func saveAll(_ states: [PendingShareState]) {
        let data = try? JSONEncoder().encode(states)
        UserDefaults.standard.set(data, forKey: key)
    }
}
