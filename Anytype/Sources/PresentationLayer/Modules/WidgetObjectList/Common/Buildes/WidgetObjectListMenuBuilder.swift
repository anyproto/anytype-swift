import Foundation
import Services

protocol WidgetObjectListMenuBuilderProtocol: AnyObject {
    func buildOptionsMenu(
        details: [ObjectDetails],
        allowOptions: [WidgetObjectListMenuItem],
        participant: Participant?,
        output: some WidgetObjectListMenuOutput
    ) -> [SelectionOptionsItemViewModel]
    
    func buildMenuItems(
        details: ObjectDetails,
        allowOptions: [WidgetObjectListMenuItem],
        participant: Participant?,
        output: some WidgetObjectListMenuOutput
    ) -> [WidgetObjectListMenuItemModel]
}

final class WidgetObjectListMenuBuilder: WidgetObjectListMenuBuilderProtocol {
    
    private struct Action {
        let optionTitle: String
        let optionImage: ImageAsset
        let menuTitle: String
        let negative: Bool
        let action: @MainActor () -> Void
    }
    
    // MARK: - WidgetObjectListMenuBuilderProtocol
    
    func buildOptionsMenu(
        details: [ObjectDetails],
        allowOptions: [WidgetObjectListMenuItem],
        participant: Participant?,
        output: some WidgetObjectListMenuOutput
    ) -> [SelectionOptionsItemViewModel] {
        
        let actions = build(details: details, allowOptions: allowOptions, participant: participant, output: output)
        
        return actions.map { action in
            SelectionOptionsItemViewModel(id: UUID().uuidString, title: action.optionTitle, imageAsset: action.optionImage, action: action.action)
        }
    }
    
    func buildMenuItems(
        details: ObjectDetails,
        allowOptions: [WidgetObjectListMenuItem],
        participant: Participant?,
        output: some WidgetObjectListMenuOutput
    ) -> [WidgetObjectListMenuItemModel] {
        
        let actions = build(details: [details], allowOptions: allowOptions, participant: participant, output: output)
        
        return actions.map { action in
            WidgetObjectListMenuItemModel(id: UUID().uuidString, title: action.menuTitle, negative: action.negative, onTap: action.action)
        }
    }
    
    // MARK: - Private
    
    private func build(
        details: [ObjectDetails],
        allowOptions: [WidgetObjectListMenuItem],
        participant: Participant?,
        output: some WidgetObjectListMenuOutput
    ) -> [Action] {
        
        let permissions = details.map { $0.permissions(participant: participant) }
        
        let isFavoriteIds = details.enumerated().filter { $1.isFavorite && permissions[$0].canFavorite }.map { $1.id }
        let isUndavoriteIds = details.enumerated().filter { !$1.isFavorite && permissions[$0].canFavorite }.map { $1.id }
        let notArchivedIds = details.enumerated().filter { !$1.isArchived && permissions[$0].canArchive }.map { $1.id }
        let isArchivedIds = details.enumerated().filter { $1.isArchived && permissions[$0].canArchive }.map { $1.id }
        let allIds = details.map(\.id)
        
        return .builder {
            
            if allowOptions.contains(.pin), isUndavoriteIds.isNotEmpty {
                Action(optionTitle: Loc.pin, optionImage: .X32.Favorite.favorite, menuTitle: Loc.addToFavorite, negative: false, action: { [weak output] in
                    output?.setPin(objectIds: isUndavoriteIds, true)
                })
            }
            
            if allowOptions.contains(.unpin), isFavoriteIds.isNotEmpty {
                Action(optionTitle: Loc.unpin, optionImage: .X32.Favorite.unfavorite, menuTitle: Loc.removeFromFavorite, negative: false, action: { [weak output] in
                    output?.setPin(objectIds: isFavoriteIds, false)
                })
            }
            
            if allowOptions.contains(.moveToBin), notArchivedIds.isNotEmpty {
                Action(optionTitle: Loc.moveToBin, optionImage: .X32.delete, menuTitle: Loc.moveToBin, negative: true, action: { [weak output] in
                    output?.setArchive(objectIds: notArchivedIds, true)
                })
            }
            
            if allowOptions.contains(.delete), isArchivedIds.isNotEmpty {
                Action(optionTitle: Loc.delete, optionImage: .X32.delete, menuTitle: Loc.delete, negative: true, action: { [weak output] in
                    output?.delete(objectIds: isArchivedIds)
                })
            }
            
            if allowOptions.contains(.restore), isArchivedIds.isNotEmpty {
                Action(optionTitle: Loc.restore, optionImage: .X32.restore, menuTitle: Loc.restore, negative: false, action: { [weak output] in
                    output?.setArchive(objectIds: isArchivedIds, false)
                })
            }
            
            if allowOptions.contains(.forceDelete) {
                Action(optionTitle: Loc.delete, optionImage: .X32.delete, menuTitle: Loc.delete, negative: true, action: { [weak output] in
                    output?.forceDelete(objectIds: allIds)
                })
            }
        }
    }
}
