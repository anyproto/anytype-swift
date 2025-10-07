import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
protocol QuickActionShortcutBuilderProtocol {
    func buildShortcutItems(spaceId: String) async -> [UIApplicationShortcutItem]
    func buildAction(shortcutItem: UIApplicationShortcutItem) -> QuickAction?
}

@MainActor
final class QuickActionShortcutBuilder: QuickActionShortcutBuilderProtocol {
    
    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    nonisolated init() {}
    
    // MARK: - QuickActionShortcutBuilderProtocol
    
    func buildShortcutItems(spaceId: String) async -> [UIApplicationShortcutItem] {
        guard spaceId.isNotEmpty else { return [] } // Unauthorized user
        
        await objectTypeProvider.prepareData(spaceId: spaceId)
        
        guard let types = try? typesService.getPinnedTypes(spaceId: spaceId), types.isNotEmpty else {
            return [buildCreateDefaultObjectShortcutItem(spaceId: spaceId)].compactMap { $0 }
        }
        
        return types.prefix(3)
            .compactMap {
                buildCreateObjectShortcutItem(typeId: $0.id)
            }
    }
    
    private func buildCreateDefaultObjectShortcutItem(spaceId: String) -> UIApplicationShortcutItem? {
        guard let type = getDefaultObjectType(spaceId: spaceId) else { return nil }
        return buildCreateObjectShortcutItem(type: type)
    }
    
    private func buildCreateObjectShortcutItem(typeId: String) -> UIApplicationShortcutItem? {
        guard let type = try? objectTypeProvider.objectType(id: typeId) else { return nil }
        return buildCreateObjectShortcutItem(type: type)
    }
    
    private func buildCreateObjectShortcutItem(type: ObjectType) -> UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: Constants.newObject.rawValue,
            localizedTitle: Loc.QuickAction.create(type.displayName),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .add),
            userInfo: [Constants.typeId.rawValue: type.id as any NSSecureCoding]
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
            
            return nil
        }
        return .newObject(typeId: typeId)
    }
    
    private func getDefaultObjectType(spaceId: String) -> ObjectType? {
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
