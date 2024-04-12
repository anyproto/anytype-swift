import Foundation
import Combine
import Services
import AnytypeCore
import UIKit
import DeepLinks

@MainActor
final class ObjectActionsViewModel: ObservableObject {
    var onLinkItselfToObjectHandler: RoutingAction<EditorScreenData>?
    
    @Published var objectActions: [ObjectAction] = []
    @Published var toastData = ToastBarData.empty
    @Published var dismiss = false
    
    var onLinkItselfAction: RoutingAction<(String) -> Void>?
    var onNewTemplateCreation: RoutingAction<String>?
    var onTemplateMakeDefault: RoutingAction<String>?
    
    let undoRedoAction: () -> ()
    let openPageAction: (_ screenData: EditorScreenData) -> ()
    let closeEditorAction: () -> ()
    
    private lazy var document: BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId)
    }()
    
    private let objectId: String
    
    @Injected(\.objectActionsService)
    private var service: ObjectActionsServiceProtocol
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    @Injected(\.templatesService)
    private var templatesService: TemplatesServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: DocumentsProviderProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: DeepLinkParserProtocol
    @Injected(\.documentService)
    private var openDocumentsProvider: OpenedDocumentsProviderProtocol
    
    init(
        objectId: String,
        undoRedoAction: @escaping () -> (),
        openPageAction: @escaping (_ screenData: EditorScreenData) -> (),
        closeEditorAction: @escaping () -> ()
    ) {
        self.objectId = objectId
        self.undoRedoAction = undoRedoAction
        self.openPageAction = openPageAction
        self.closeEditorAction = closeEditorAction
    }
    
    func startDocumentTask() async {
        for await _ in document.syncPublisher.values {
            guard let details = document.details else {
                objectActions = []
                return
            }

            objectActions = ObjectAction.allCasesWith(
                details: details,
                isLocked: document.isLocked,
                permissions: document.permissions
            )
        }
    }

    func changeArchiveState() async throws {
        guard let details = document.details else { return }
        
        let isArchived = !details.isArchived
        AnytypeAnalytics.instance().logMoveToBin(isArchived)
        try await service.setArchive(objectIds: [objectId], isArchived)
        if isArchived {
            dismiss.toggle()
            closeEditorAction()
        }
    }

    func changeFavoriteSate() async throws {
        guard let details = document.details else { return }
        AnytypeAnalytics.instance().logAddToFavorites(!details.isFavorite)
        try await service.setFavorite(objectIds: [objectId], !details.isFavorite)
    }

    func changeLockState() async throws {
        AnytypeAnalytics.instance().logLockPage(!document.isLocked)
        try await service.setLocked(!document.isLocked, objectId: objectId)
    }
    
    func duplicateAction() async throws {
        guard let details = document.details else { return }
        
        AnytypeAnalytics.instance().logDuplicateObject(count: 1, objectType: details.objectType.analyticsType)
        
        let duplicatedId = try await service.duplicate(objectId: objectId)
        
        let newDetails = ObjectDetails(id: duplicatedId, values: details.values)
        dismiss.toggle()
        openPageAction(newDetails.editorScreenData())
    }

    func linkItselfAction() {
        guard let currentObjectId = document.details?.id else { return }

        let onObjectSelection: (String) -> Void = { [weak self] objectId in
            self?.onObjectSelection(objectId: objectId, currentObjectId: currentObjectId)
        }

        onLinkItselfAction?(onObjectSelection)
    }
    
    func makeAsTempalte() async throws {
        guard let details = document.details else { return }
        
        let templateId = try await templatesService.createTemplateFromObject(objectId: details.id)
        onNewTemplateCreation?(templateId)
    }
    
    func makeTemplateAsDefault() {
        guard let details = document.details else { return }
        
        onTemplateMakeDefault?(details.id)
    }
    
    func deleteAction() async throws {
        guard let details = document.details else { return }
        
        AnytypeAnalytics.instance().logDeletion(count: 1, route: .bin)
        try await service.delete(objectIds: [details.id])
        dismiss.toggle()
        closeEditorAction()
    }
    
    func createWidget() async throws {
        guard let details = document.details else { return }
        
        let info = activeWorkpaceStorage.workspaceInfo
        
        guard info.accountSpaceId == details.spaceId else {
            anytypeAssertionFailure("Spaces are not equals")
            return
        }
        guard let layout = details.availableWidgetLayout.first else {
            anytypeAssertionFailure("Default layout not found")
            return
        }
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
        dismiss.toggle()
    }
    
    func copyLinkAction() {
        guard let details = document.details else { return }
        let link = deepLinkParser.createUrl(deepLink: .object(objectId: details.id, spaceId: details.spaceId), scheme: .main)
        UIPasteboard.general.string = link?.absoluteString
        toastData = ToastBarData(text: Loc.copied, showSnackBar: true)
        dismiss.toggle()
    }
    
    private func onObjectSelection(objectId: String, currentObjectId: String) {
        Task { @MainActor in
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
}
