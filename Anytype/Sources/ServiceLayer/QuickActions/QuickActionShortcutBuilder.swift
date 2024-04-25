import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
protocol QuickActionShortcutBuilderProtocol {
    func buildShortcutItems() -> [UIApplicationShortcutItem]
    func buildAction(shortcutItem: UIApplicationShortcutItem) -> QuickAction?
}

@MainActor
final class QuickActionShortcutBuilder: QuickActionShortcutBuilderProtocol {
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.typesService)
    private var typesService: TypesServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    nonisolated init() {}
    
    // MARK: - QuickActionShortcutBuilderProtocol
    
    func buildShortcutItems() -> [UIApplicationShortcutItem] {
        let spaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
        guard spaceId.isNotEmpty else { return [] } // Unauthorized user
        
        guard let types = try? typesService.getPinnedTypes(spaceId: spaceId), types.isNotEmpty else {
            return [buildCreateDefaultObjectShortcutItem()].compactMap { $0 }
        }
        
        return types.prefix(3)
            .compactMap {
                buildCreateObjectShortcutItem(typeId: $0.id)
            }
    }
    
    private func buildCreateDefaultObjectShortcutItem() -> UIApplicationShortcutItem? {
        guard let type = getDefaultObjectType() else { return nil }
        return buildCreateObjectShortcutItem(type: type)
    }
    
    private func buildCreateObjectShortcutItem(typeId: String) -> UIApplicationShortcutItem? {
        guard let type = try? objectTypeProvider.objectType(id: typeId) else { return nil }
        return buildCreateObjectShortcutItem(type: type)
    }
    
    private func buildCreateObjectShortcutItem(type: ObjectType) -> UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: Constants.newObject.rawValue,
            localizedTitle: Loc.QuickAction.create(type.name),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .add),
            userInfo: [Constants.typeId.rawValue: type.id as NSSecureCoding]
        )
    }
    
    func buildAction(shortcutItem: UIApplicationShortcutItem) -> QuickAction? {
        guard shortcutItem.type == Constants.newObject.rawValue else {
            anytypeAssertionFailure("Not supported action", info: ["action": shortcutItem.type])
            return nil
        }
        
        guard let typeId = shortcutItem.userInfo?[Constants.typeId.rawValue] as? String else {
            anytypeAssertionFailure(
                "No typeId for New Object action",
                info: [
                    "action": shortcutItem.type,
                    "userInfo": shortcutItem.userInfo?.description ?? ""
                ])
            
            // Migration fallback, legacy actions do not have type id
            guard let type = getDefaultObjectType() else { return nil }
            return .newObject(typeId: type.id)
        }
        return .newObject(typeId: typeId)
    }
    
    private func getDefaultObjectType() -> ObjectType? {
        let spaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
        guard spaceId.isNotEmpty else { return nil } // Unauthorized user
        let type = try? objectTypeProvider.defaultObjectType(spaceId: spaceId)
        
        return type
    }
}

fileprivate extension QuickActionShortcutBuilder {
    enum Constants: String {
        case newObject
        case typeId
    }
}
