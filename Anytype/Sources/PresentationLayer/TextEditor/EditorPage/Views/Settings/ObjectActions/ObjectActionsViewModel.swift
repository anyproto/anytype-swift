import Foundation
import Combine
import BlocksModels
import AnytypeCore
import UIKit

final class ObjectActionsViewModel: ObservableObject {
    var onLinkCompletion: RoutingAction<NSAttributedString>?
    
    var objectActions: [ObjectAction] {
        guard let details = details else { return [] }

        return ObjectAction.allCasesWith(
            details: details,
            objectRestrictions: objectRestrictions,
            isLocked: isLocked
        )
    }
    
    @Published var details: ObjectDetails?
    @Published var objectRestrictions: ObjectRestrictions = ObjectRestrictions()
    @Published var isLocked: Bool = false

    var onLinkItselfAction: RoutingAction<(BlockId) -> Void>?
    var dismissSheet: () -> () = {}

    let undoRedoAction: () -> ()
    let openPageAction: (_ screenData: EditorScreenData) -> ()
    
    private let objectId: BlockId
    private let service = ServiceLocator.shared.objectActionsService()
    
    init(
        objectId: BlockId,
        undoRedoAction: @escaping () -> (),
        openPageAction: @escaping (_ screenData: EditorScreenData) -> ()
    ) {
        self.objectId = objectId
        self.undoRedoAction = undoRedoAction
        self.openPageAction = openPageAction
    }

    func changeArchiveState() {
        guard let details = details else { return }
        
        let isArchived = !details.isArchived
        service.setArchive(objectId: objectId, isArchived)
        if isArchived {
            dismissSheet()
        }
    }

    func changeFavoriteSate() {
        guard let details = details else { return }

        service.setFavorite(objectId: objectId, !details.isFavorite)
    }

    func changeLockState() {
        service.setLocked(!isLocked, objectId: objectId)
    }
    
    func duplicateAction() {
        guard let details = details,
              let duplicatedId = service.duplicate(objectId: objectId)
            else { return }
        
        let screenData = EditorScreenData(pageId: duplicatedId, type: details.editorViewType)
        dismissSheet()
        openPageAction(screenData)
    }

    func linkItselfAction() {
        guard let currentObjectId = details?.id else { return }


        let onObjectSelection: (BlockId) -> Void = { objectId in
            Task { [weak self] in
                guard let self = self else { return }

                let targetDocument = BaseDocument(objectId: objectId)
                try? await targetDocument.open()
                guard let id = targetDocument.children.last?.id else { return }

                let targetObjectService = BlockActionsServiceSingle(contextId: objectId)


                let _ = targetObjectService.add(targetId: id, info: .emptyLink(targetId: currentObjectId), position: .bottom)
                
                guard let details = targetDocument.details else {
                    return
                }
                
                let attributedString = await self.createAttributedString(from: details)
                
                self.onLinkCompletion?(attributedString)
            }
        }

        onLinkItselfAction?(onObjectSelection)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }
    
    func createAttributedString(from objectDetails: ObjectDetails) async -> NSAttributedString {
        guard let icon = objectDetails.icon else {
            return .init(string: objectDetails.name)
        }
        
        let loader = AnytypeIconDownloader()
        
        guard let image = await loader.image(
            with: icon,
            imageGuideline: .init(size: .init(width: 16, height: 16))
        ) else {
            return .init(string: objectDetails.name)
        }
        
        return NSAttributedString.imageFirstComposite(
            image: image,
            text: objectDetails.name,
            attributes: [.foregroundColor: UIColor.textPrimary]
        )
    }
}
