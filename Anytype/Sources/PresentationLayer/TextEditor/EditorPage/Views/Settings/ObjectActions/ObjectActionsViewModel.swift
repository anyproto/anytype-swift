import Foundation
import Combine
import Services
import AnytypeCore
import UIKit
import DeepLinks

@MainActor
final class ObjectActionsViewModel: ObservableObject {

    private let objectId: String
    private let spaceId: String
    private weak var output: (any ObjectActionsOutput)?
    
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()
    
    @Injected(\.objectActionsService)
    private var service: any ObjectActionsServiceProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.templatesService)
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: any DeepLinkParserProtocol
    @Injected(\.documentService)
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    @Published var objectActions: [ObjectAction] = []
    @Published var toastData = ToastBarData.empty
    @Published var dismiss = false
    
    init(objectId: String, spaceId: String, output: (any ObjectActionsOutput)?) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
    }
    
    func startDocumentTask() async {
        for await _ in document.syncPublisher.receiveOnMain().values {
            guard let details = document.details else {
                objectActions = []
                return
            }

            objectActions = ObjectAction.buildActions(
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
        output?.openPageAction(screenData: newDetails.screenData())
    }

    func linkItselfAction() {
        guard let currentObjectId = document.details?.id else { return }
        let spaceId = document.spaceId
        let onObjectSelection: (String) -> Void = { [weak self] objectId in
            self?.onObjectSelection(objectId: objectId, spaceId: spaceId, currentObjectId: currentObjectId)
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
        AnytypeAnalytics.instance().logClickAddWidget(context: .object)
        guard let details = document.details else { return }
        
        guard let info = workspaceStorage.workspaceInfo(spaceId: details.spaceId) else {
            anytypeAssertionFailure("Info not found")
            return
        }
        
        guard info.accountSpaceId == details.spaceId else {
            anytypeAssertionFailure("Spaces are not equals")
            return
        }
        guard let layout = details.availableWidgetLayout.first else {
            anytypeAssertionFailure("Default layout not found")
            return
        }
        let widgetObject = documentsProvider.document(objectId: info.widgetsId, spaceId: spaceId, mode: .preview)
        try await widgetObject.open()
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
        AnytypeAnalytics.instance().logAddWidget(context: .object)
        toastData = ToastBarData(text: Loc.Actions.CreateWidget.success, showSnackBar: true, messageType: .success)
        dismiss.toggle()
    }
    
    func copyLinkAction() async throws {
        guard let details = document.details else { return }
        let invite = try? await workspaceService.getCurrentInvite(spaceId: details.spaceId)
        let link = deepLinkParser.createUrl(deepLink: .object(objectId: details.id, spaceId: details.spaceId, cid: invite?.cid, key: invite?.fileKey), scheme: .main)
        
        UIPasteboard.general.string = link?.absoluteString
        toastData = ToastBarData(text: Loc.copied, showSnackBar: true)
        dismiss.toggle()
    }
    
    func undoRedoAction() {
        output?.undoRedoAction()
    }
    
    // MARK: - Private
    
    private func onObjectSelection(objectId: String, spaceId: String, currentObjectId: String) {
        Task { @MainActor in
            let targetDocument = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
            try? await targetDocument.open()
            guard let id = targetDocument.children.last?.id,
                  let details = targetDocument.details else { return }
            
            if details.isCollection {
                try await service.addObjectsToCollection(
                    contextId: objectId,
                    objectIds: [currentObjectId]
                )
                output?.onLinkItselfToObjectHandler(data: details.screenData())
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
                output?.onLinkItselfToObjectHandler(data: details.screenData())
                AnytypeAnalytics.instance().logLinkToObject(type: .object, spaceId: details.spaceId)
            }
        }
    }
}
