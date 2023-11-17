import Foundation
import UIKit
import AnytypeCore

@MainActor
protocol QuickActionShortcutBuilderProtocol {
    func buildShortcutItem(action: QuickAction) -> UIApplicationShortcutItem?
    func buildAction(shortcutItem: UIApplicationShortcutItem) -> QuickAction?
}

@MainActor
final class QuickActionShortcutBuilder: QuickActionShortcutBuilderProtocol {
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    nonisolated init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - QuickActionShortcutBuilderProtocol
    
    func buildShortcutItem(action: QuickAction) -> UIApplicationShortcutItem? {
        switch action {
        case .newObject:
            let spaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
            guard spaceId.isNotEmpty,
                    let type = try? objectTypeProvider.defaultObjectType(spaceId: spaceId) else { return nil }
            return UIApplicationShortcutItem(
                type: action.rawValue,
                localizedTitle: Loc.QuickAction.create(type.name),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(type: .add)
            )
        }
    }
    
    func buildAction(shortcutItem: UIApplicationShortcutItem) -> QuickAction? {
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            anytypeAssertionFailure("Not supported action", info: ["action": shortcutItem.type])
            return nil
        }
        return action
    }
}
