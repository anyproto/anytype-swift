import Foundation
import Combine
import Services
import AnytypeCore
import UIKit

@MainActor
final class ObjectActionsViewModel: ObservableObject {
    var onLinkItselfToObjectHandler: RoutingAction<EditorScreenData>?
    
    var objectActions: [ObjectAction] {
        guard let details = details else { return [] }

        return ObjectAction.allCasesWith(
            details: details,
            objectRestrictions: objectRestrictions,
            isLocked: isLocked,
            isArchived: isArchived
        )
    }
    
    @Published var details: ObjectDetails?
    @Published var objectRestrictions: ObjectRestrictions = ObjectRestrictions()
    @Published var isLocked: Bool = false
    @Published var isArchived: Bool = false
    @Published var toastData = ToastBarData.empty
    
    var onLinkItselfAction: RoutingAction<(BlockId) -> Void>?
    var onNewTemplateCreation: RoutingAction<BlockId>?
    var onTemplateMakeDefault: RoutingAction<BlockId>?
    var dismissSheet: () -> () = {}

    let undoRedoAction: () -> ()
    let openPageAction: (_ screenData: EditorScreenData) -> ()
    let closeEditorAction: () -> ()
    
    private let objectId: BlockId
    private let service: ObjectActionsServiceProtocol
    private let blockService: BlockServiceProtocol
    private let templatesService: TemplatesServiceProtocol
    private let documentsProvider: DocumentsProviderProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    
    init(
        objectId: BlockId,
        service: ObjectActionsServiceProtocol,
        blockService: BlockServiceProtocol,
        templatesService: TemplatesServiceProtocol,
        documentsProvider: DocumentsProviderProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol,
        
        undoRedoAction: @escaping () -> (),
        openPageAction: @escaping (_ screenData: EditorScreenData) -> (),
        closeEditorAction: @escaping () -> ()
    ) {
        self.objectId = objectId
        self.service = service
        self.blockService = blockService
        self.templatesService = templatesService
        self.documentsProvider = documentsProvider
        self.blockWidgetService = blockWidgetService
        self.activeWorkpaceStorage = activeWorkpaceStorage
        self.undoRedoAction = undoRedoAction
        self.openPageAction = openPageAction
        self.closeEditorAction = closeEditorAction
    }

    func changeArchiveState() {
        guard let details = details else { return }
        
        let isArchived = !details.isArchived
        Task { @MainActor in
            AnytypeAnalytics.instance().logMoveToBin(isArchived)
            try await service.setArchive(objectIds: [objectId], isArchived)
            if isArchived {
                dismissSheet()
                closeEditorAction()
            }
        }
    }

    func changeFavoriteSate() {
        guard let details = details else { return }
        Task {
            AnytypeAnalytics.instance().logAddToFavorites(!details.isFavorite)
            try await service.setFavorite(objectIds: [objectId], !details.isFavorite)
        }
    }

    func changeLockState() {
        Task {
            AnytypeAnalytics.instance().logLockPage(!isLocked)
            try await service.setLocked(!isLocked, objectId: objectId)
        }
    }
    
    func duplicateAction() {
        Task { @MainActor [weak self] in
            guard let details = self?.details, let objectId = self?.objectId else { return }
            
            AnytypeAnalytics.instance().logDuplicateObject(count: 1, objectType: details.objectType.analyticsType)
            
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
                let targetDocument = documentsProvider.document(objectId: objectId, forPreview: true)
                try? await targetDocument.openForPreview()
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
                    AnytypeAnalytics.instance().logCreateBlock(type: info.content.type)
                    let _ = try await self.blockService.add(
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
    
    func makeAsTempalte() {
        guard let details = details else { return }
        
        Task {
            let templateId = try await templatesService.createTemplateFromObject(objectId: details.id)
            onNewTemplateCreation?(templateId)
        }
    }
    
    func makeTemplateAsDefault() {
        guard let details = details else { return }
        
        onTemplateMakeDefault?(details.id)
    }
    
    func deleteAction() {
        guard let details = details else { return }
        Task { @MainActor in
            AnytypeAnalytics.instance().logDeletion(count: 1, route: .bin)
            try await service.delete(objectIds: [details.id])
            dismissSheet()
            closeEditorAction()
        }
    }
    
    func createWidget() {
        guard let details else { return }
        
        let info = activeWorkpaceStorage.workspaceInfo
        
        guard info.accountSpaceId == details.spaceId else {
            anytypeAssertionFailure("Spaces are not equals")
            return
        }
        guard let layout = details.availableWidgetLayout.first else {
            anytypeAssertionFailure("Default layout not found")
            return
        }
        Task {
            let widgetObject = documentsProvider.document(objectId: info.widgetsId, forPreview: true)
            try await widgetObject.openForPreview()
            guard let first = widgetObject.children.first else {
                anytypeAssertionFailure("First children not found")
                return
            }
            try await blockWidgetService.createWidgetBlock(
                contextId: info.widgetsId,
                sourceId: details.id,
                layout: layout,
                limit: layout.limits.first ?? 0,
                position: .above(widgetId: first.id)
            )
            toastData = ToastBarData(text: Loc.Actions.CreateWidget.success, showSnackBar: true, messageType: .success)
            dismissSheet()
        }
    }
}
