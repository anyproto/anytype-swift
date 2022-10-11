import Foundation
import Combine
import BlocksModels
import AnytypeCore

final class ObjectActionsViewModel: ObservableObject {
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

    var onLinkItselfAction: RoutingAction<(BlockId, String) -> Void>?
    var dismissSheet: () -> () = {}

    let popScreenAction: () -> ()
    let undoRedoAction: () -> ()
    let openPageAction: (_ screenData: EditorScreenData) -> ()
    
    private let objectId: BlockId
    private let service = ServiceLocator.shared.objectActionsService()
    
    init(
        objectId: BlockId,
        popScreenAction: @escaping () -> (),
        undoRedoAction: @escaping () -> (),
        openPageAction: @escaping (_ screenData: EditorScreenData) -> ()
    ) {
        self.objectId = objectId
        self.popScreenAction = popScreenAction
        self.undoRedoAction = undoRedoAction
        self.openPageAction = openPageAction
    }

    func changeArchiveState() {
        guard let details = details else { return }
        
        let isArchived = !details.isArchived
        service.setArchive(objectId: objectId, isArchived)
        if isArchived {
            popScreenAction()
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

        let onObjectSelection: (BlockId, String) -> Void = { objectId, typeUrl in
            Task {
                let targetDocument = BaseDocument(objectId: objectId)
                try? await targetDocument.open()
                guard let id = targetDocument.children.last?.id else { return }

                let targetObjectService = BlockActionsServiceSingle(contextId: objectId)

                let _ = targetObjectService.add(targetId: id, info: .emptyLink(targetId: currentObjectId), position: .bottom)
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

}
