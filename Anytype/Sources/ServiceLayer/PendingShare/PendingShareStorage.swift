import Foundation
import Factory

@MainActor
protocol PendingShareStorageProtocol: AnyObject {
    func pendingState(for spaceId: String) -> PendingShareState?
    func savePendingState(_ state: PendingShareState)
    func removePendingState(for spaceId: String)
    func updatePendingState(for spaceId: String, update: (inout PendingShareState) -> Void)
}

@MainActor
final class PendingShareStorage: PendingShareStorageProtocol {

    private let key = "PendingShareStates"

    func pendingState(for spaceId: String) -> PendingShareState? {
        loadAll().first { $0.spaceId == spaceId }
    }

    func savePendingState(_ state: PendingShareState) {
        var all = loadAll()
        if let index = all.firstIndex(where: { $0.spaceId == state.spaceId }) {
            all[index] = state
        } else {
            all.append(state)
        }
        saveAll(all)
    }

    func removePendingState(for spaceId: String) {
        var all = loadAll()
        all.removeAll { $0.spaceId == spaceId }
        saveAll(all)
    }

    func updatePendingState(for spaceId: String, update: (inout PendingShareState) -> Void) {
        var all = loadAll()
        if let index = all.firstIndex(where: { $0.spaceId == spaceId }) {
            update(&all[index])
            saveAll(all)
        }
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
