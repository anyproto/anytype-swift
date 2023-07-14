import Foundation
import Combine
import Services
import AnytypeCore
import UIKit

final class ObjectActionsViewModel: ObservableObject {
    var onLinkItselfToObjectHandler: RoutingAction<EditorScreenData>?
    
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
    private let service: ObjectActionsServiceProtocol
    private let blockActionsService: BlockActionsServiceSingleProtocol
    
    init(
        objectId: BlockId,
        service: ObjectActionsServiceProtocol,
        blockActionsService: BlockActionsServiceSingleProtocol,
        undoRedoAction: @escaping () -> (),
        openPageAction: @escaping (_ screenData: EditorScreenData) -> ()
    ) {
        self.objectId = objectId
        self.service = service
        self.blockActionsService = blockActionsService
        self.undoRedoAction = undoRedoAction
        self.openPageAction = openPageAction
    }

    func changeArchiveState() {
        guard let details = details else { return }
        
        let isArchived = !details.isArchived
        Task { @MainActor in
            try await service.setArchive(objectIds: [objectId], isArchived)
            if isArchived {
                dismissSheet()
            }
        }
    }

    func changeFavoriteSate() {
        guard let details = details else { return }
        Task {
            try await service.setFavorite(objectIds: [objectId], !details.isFavorite)
        }
    }

    func changeLockState() {
        Task {
            try await service.setLocked(!isLocked, objectId: objectId)
        }
    }
    
    func duplicateAction() {
        Task { @MainActor [weak self] in
            guard let details = self?.details, let objectId = self?.objectId else { return }
            
            guard let duplicatedId = try await self?.service.duplicate(objectId: objectId) else { return }
            let newDetails = ObjectDetails(id: duplicatedId, values: details.values)
            self?.dismissSheet()
            self?.openPageAction(newDetails.editorScreenData())
        }
    }

    func linkItselfAction() {
        guard let currentObjectId = details?.id else { return }


        let onObjectSelection: (BlockId) -> Void = { objectId in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let targetDocument = BaseDocument(objectId: objectId)
                try? await targetDocument.open()
                guard let id = targetDocument.children.last?.id,
                      let details = targetDocument.details else { return }

                if details.isCollection {
                    try await self.service.addObjectsToCollection(
                        contextId: objectId,
                        objectIds: [currentObjectId]
                    )
                    self.onLinkItselfToObjectHandler?(details.editorScreenData())
                    AnytypeAnalytics.instance().logLinkToObject(type: .collection)
                } else {
                    let info = BlockInformation.emptyLink(targetId: currentObjectId)
                    AnytypeAnalytics.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)
                    let _ = try await self.blockActionsService.add(
                        contextId: objectId,
                        targetId: id,
                        info: info,
                        position: .bottom
                    )
                    self.onLinkItselfToObjectHandler?(details.editorScreenData())
                    AnytypeAnalytics.instance().logLinkToObject(type: .object)
                }
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
