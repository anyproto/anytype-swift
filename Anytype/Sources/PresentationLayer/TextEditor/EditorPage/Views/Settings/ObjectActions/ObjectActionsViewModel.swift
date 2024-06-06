import Foundation
import Combine
import Services
import AnytypeCore
import UIKit
import DeepLinks

@MainActor
final class ObjectActionsViewModel: ObservableObject {

    private let objectId: String
    private weak var output: ObjectActionsOutput?
    
    private lazy var document: BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId)
    }()
    
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
    
    @Published var objectActions: [ObjectAction] = []
    @Published var toastData = ToastBarData.empty
    @Published var dismiss = false
    
    init(objectId: String, output: ObjectActionsOutput?) {
        self.objectId = objectId
        self.output = output
    }
    
    func startDocumentTask() async {
        for await _ in document.syncPublisher.receiveOnMain().values {
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
            output?.closeEditorAction()
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
        
        AnytypeAnalytics.instance().logDuplicateObject(count: 1, objectType: details.objectType.analyticsType, spaceId: details.spaceId)
        
        let duplicatedId = try await service.duplicate(objectId: objectId)
        
        let newDetails = ObjectDetails(id: duplicatedId, values: details.values)
        dismiss.toggle()
        output?.openPageAction(screenData: newDetails.editorScreenData())
    }

    func linkItselfAction() {
        guard let currentObjectId = document.details?.id else { return }

        let onObjectSelection: (String) -> Void = { [weak self] objectId in
            self?.onObjectSelection(objectId: objectId, currentObjectId: currentObjectId)
        }

        output?.onLinkItselfAction(onSelect: onObjectSelection)
    }
    
    func makeAsTempalte() async throws {
        guard let details = document.details else { return }
        
        let templateId = try await templatesService.createTemplateFromObject(objectId: details.id)
        output?.onNewTemplateCreation(templateId: templateId)
    }
    
    func makeTemplateAsDefault() {
        guard let details = document.details else { return }
        
        output?.onTemplateMakeDefault(templateId: details.id)
    }
    
    func deleteAction() async throws {
        guard let details = document.details else { return }
        
        AnytypeAnalytics.instance().logDeletion(count: 1, route: .bin)
        try await service.delete(objectIds: [details.id])
        dismiss.toggle()
        output?.closeEditorAction()
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
    
    func undoRedoAction() {
        output?.undoRedoAction()
    }
    
    // MARK: - Private
    
    private func onObjectSelection(objectId: String, currentObjectId: String) {
        Task { @MainActor in
            let targetDocument = documentsProvider.document(objectId: objectId, forPreview: true)
            try? await targetDocument.openForPreview()
            guard let id = targetDocument.children.last?.id,
                  let details = targetDocument.details else { return }
            
            if details.isCollection {
                try await service.addObjectsToCollection(
                    contextId: objectId,
                    objectIds: [currentObjectId]
                )
                output?.onLinkItselfToObjectHandler(data: details.editorScreenData())
                AnytypeAnalytics.instance().logLinkToObject(type: .collection, spaceId: details.spaceId)
            } else {
                let info = BlockInformation.emptyLink(targetId: currentObjectId)
                AnytypeAnalytics.instance().logCreateBlock(type: info.content.type, spaceId: details.spaceId)
                let _ = try await blockService.add(
                    contextId: objectId,
                    targetId: id,
                    info: info,
                    position: .bottom
                )
                output?.onLinkItselfToObjectHandler(data: details.editorScreenData())
                AnytypeAnalytics.instance().logLinkToObject(type: .object, spaceId: details.spaceId)
            }
        }
    }
}
