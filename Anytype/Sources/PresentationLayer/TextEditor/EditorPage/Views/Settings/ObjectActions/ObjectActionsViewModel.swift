import Foundation
import Services
import AnytypeCore
import UIKit
import DeepLinks

@MainActor
@Observable
final class ObjectActionsViewModel {

    @ObservationIgnored
    private let objectId: String
    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private weak var output: (any ObjectActionsOutput)?

    @ObservationIgnored
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()

    @ObservationIgnored
    private lazy var widgetObject: (any BaseDocumentProtocol)? = {
        guard let info = workspaceStorage.spaceInfo(spaceId: spaceId) else {
            anytypeAssertionFailure("info not found")
            return nil
        }
        return openDocumentsProvider.document(objectId: info.widgetsId, spaceId: spaceId)
    }()

    @Injected(\.objectActionsService) @ObservationIgnored
    private var service: any ObjectActionsServiceProtocol
    @Injected(\.blockService) @ObservationIgnored
    private var blockService: any BlockServiceProtocol
    @Injected(\.templatesService) @ObservationIgnored
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.deepLinkParser) @ObservationIgnored
    private var deepLinkParser: any DeepLinkParserProtocol
    @Injected(\.universalLinkParser) @ObservationIgnored
    private var universalLinkParser: any UniversalLinkParserProtocol
    @Injected(\.openedDocumentProvider) @ObservationIgnored
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    @Injected(\.workspaceService) @ObservationIgnored
    private var workspaceService: any WorkspaceServiceProtocol

    var objectActions: [ObjectAction] = []
    var toastData: ToastBarData?
    var dismiss = false
    
    init(objectId: String, spaceId: String, output: (any ObjectActionsOutput)?) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
    }
    
    func startSubscriptions() async {
        async let documentSub: () = startDocumentSubscription()
        async let widgetSub: () = startWidgetObjectSubscription()
        
        _ = await (documentSub, widgetSub)
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

    func changePinState(_ pinned: Bool) async throws {
        guard let widgetObject else {
            anytypeAssertionFailure("Widget object not found")
            return
        }
        
        guard let details = document.details else {
            anytypeAssertionFailure("Details object not found")
            return
        }
        
        if pinned {
            
            guard let widgetBlockId = widgetObject.widgetBlockIdFor(targetObjectId: details.id) else {
                anytypeAssertionFailure("Block not found")
                return
            }
            
            try await blockWidgetService.removeWidgetBlock(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId)
            
        } else {
            guard let layout = details.availableWidgetLayout.first else {
                anytypeAssertionFailure("Default layout not found")
                return
            }
            
            let first = widgetObject.children.first
            
            try await blockWidgetService.createWidgetBlock(
                contextId: widgetObject.objectId,
                sourceId: details.id,
                layout: layout,
                limit: layout.limits.first ?? 0,
                position: first.map { .above(widgetId: $0.id) } ?? .end
            )
        }
        toastData = ToastBarData(pinned ? Loc.unpinned : Loc.pinned)
        dismiss.toggle()
    }

    func changeLockState() async throws {
        let isCurrentlyLocked = document.isLocked
        AnytypeAnalytics.instance().logLockPage(!isCurrentlyLocked)
        try await service.setLocked(!isCurrentlyLocked, objectId: objectId)
        toastData = ToastBarData(isCurrentlyLocked ? Loc.unlocked : Loc.locked)
        dismiss.toggle()
    }
    
    func duplicateAction() async throws {
        guard let details = document.details else { return }
        
        AnytypeAnalytics.instance().logDuplicateObject(count: 1, objectType: details.objectType.analyticsType)
        
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
    
    func makeAsTemplate() async throws {
        guard let details = document.details else { return }
        
        let templateId = try await templatesService.createTemplateFromObject(objectId: details.id)
        output?.onNewTemplateCreation(templateId: templateId)
    }
    
    func templateToggleDefaultState() async throws {
        guard let details = document.details,
        let targetObjectType = details.targetObjectTypeValue else { return }

        let isCurrentlyDefault = targetObjectType.defaultTemplateId == details.id
        let newTemplateId = isCurrentlyDefault ? "" : details.id
        
        output?.onTemplateMakeDefault(templateId: newTemplateId)
    }
    
    func deleteAction() async throws {
        guard let details = document.details else { return }
        
        AnytypeAnalytics.instance().logDeletion(count: 1, route: .bin)
        try await service.delete(objectIds: [details.id])
        dismiss.toggle()
        output?.closeEditorAction()
    }
    
    func copyLinkAction() async throws {
        guard let details = document.details else { return }
        
        let invite = try? await workspaceService.getCurrentInvite(spaceId: details.spaceId)
        let link = universalLinkParser.createUrl(link: .object(objectId: details.id, spaceId: details.spaceId, cid: invite?.cid, key: invite?.fileKey))
        
        UIPasteboard.general.string = link?.absoluteString
        toastData = ToastBarData(Loc.copied)
        dismiss.toggle()
    }
    
    func undoRedoAction() {
        output?.undoRedoAction()
    }
    
    // MARK: - Private
    
    private func startDocumentSubscription() async {
        for await _ in document.syncPublisher.values {
            updateActions()
        }
    }
    
    private func startWidgetObjectSubscription() async {
        guard let widgetObject else { return }
        for await _ in widgetObject.syncPublisher.values {
            updateActions()
        }
    }
    
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
                AnytypeAnalytics.instance().logLinkToObject(type: .collection)
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
                AnytypeAnalytics.instance().logLinkToObject(type: .object)
            }
        }
    }
    
    private func updateActions() {
        guard let details = document.details else {
            objectActions = []
            return
        }
        
        objectActions = ObjectAction.buildActions(
            details: details,
            isLocked: document.isLocked,
            isPinnedToWidgets: widgetObject?.widgetBlockIdFor(targetObjectId: objectId).isNotNil ?? false,
            permissions: document.permissions
        )
    }
}
