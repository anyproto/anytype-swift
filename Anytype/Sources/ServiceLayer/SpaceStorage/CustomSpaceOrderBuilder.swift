import Combine
import Foundation
import AnytypeCore

@MainActor
protocol CustomSpaceOrderBuilderProtocol {
    func updateSpacesList(spaces: [SpaceView]) -> [SpaceView]
    func move(space: SpaceView, after: SpaceView, allSpaces: [SpaceView]) -> [SpaceView]
}

@MainActor
final class CustomSpaceOrderBuilder: CustomSpaceOrderBuilderProtocol {
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol

    private var spacesOrder: [String] {
        get { userDefaults.getSpacesOrder(accountId: accountManager.account.id) }
        set { userDefaults.saveSpacesOrder(accountId: accountManager.account.id, spaces: newValue) }
    }

    nonisolated init() { }

    func updateSpacesList(spaces: [SpaceView]) -> [SpaceView] {
        let spaceIds = spaces.map { $0.id }

        spacesOrder = spacesOrder.filter { spaceIds.contains($0) }

        let newSpaces = spaceIds.filter { !spacesOrder.contains($0) }
        spacesOrder.insert(contentsOf: newSpaces, at: 0)

        return updateSpaceOrder(allSpaces: spaces)
    }

    func move(space: SpaceView, after: SpaceView, allSpaces: [SpaceView]) -> [SpaceView] {
        guard let fromIndex = spacesOrder.firstIndex(of: space.id) else {
            anytypeAssertionFailure(
                "Not found index for space",
                info: ["Space": String(describing: space), "All Spaces": String(describing: allSpaces) ]
            )
            return allSpaces
        }
        guard let toIndex = spacesOrder.firstIndex(of: after.id) else {
            anytypeAssertionFailure(
                "Not found index for space",
                info: ["Space": String(describing: after), "All Spaces": String(describing: allSpaces) ]
            )
            return allSpaces
        }
        guard fromIndex != toIndex else { return allSpaces }

        spacesOrder.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex)
        )

        return updateSpaceOrder(allSpaces: allSpaces)
    }

    private func updateSpaceOrder(allSpaces: [SpaceView]) -> [SpaceView] {
        return allSpaces.sorted {
            guard let firstIndex = spacesOrder.firstIndex(of: $0.id) else { return true }
            guard let secondIndex = spacesOrder.firstIndex(of: $1.id) else { return false }

            return firstIndex < secondIndex
        }
    }
}
