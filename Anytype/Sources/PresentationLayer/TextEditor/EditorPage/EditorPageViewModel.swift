import Foundation
import SwiftUI
@preconcurrency import Combine
import os
import Services
import AnytypeCore

@MainActor
final class EditorPageViewModel: EditorPageViewModelProtocol, EditorBottomNavigationManagerOutput, ObservableObject {
    weak private(set) var viewInput: (any EditorPageViewInput)?
    
    let blocksStateManager: any EditorPageBlocksStateManagerProtocol
    
    let document: any BaseDocumentProtocol
    let modelsHolder: EditorMainItemModelsHolder
    let router: any EditorRouterProtocol
    let actionHandler: any BlockActionHandlerProtocol
    
    @Injected(\.objectActionsService)
    var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.templatesSubscription)
    private var templatesSubscriptionService: any TemplatesSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    @Injected(\.participantsStorage)
    private var participantStorage: any ParticipantsStorageProtocol
    @Injected(\.publishedUrlBuilder)
    private var publishedUrlBuilder: any PublishedUrlBuilderProtocol
    
    
    private let cursorManager: EditorCursorManager
    private let blockBuilder: BlockViewModelBuilder
    private let headerModel: ObjectHeaderViewModel
    private let editorPageTemplatesHandler: any EditorPageTemplatesHandlerProtocol
    private let configuration: EditorPageViewModelConfiguration
    
    private weak var output: (any EditorPageModuleOutput)?
    lazy var subscriptions = [AnyCancellable]()
    private var didScrollToInitialBlock = false
    private var publishState: PublishState?
    private var trailingBlockPlaceholder: (session: VirtualTrailingBlockSession, item: EditorItem)?

    @Published var bottomPanelHidden: Bool = false
    @Published var bottomPanelHiddenAnimated: Bool = true
    @Published var dismiss = false
    @Published var showUpdateAlert = false
    @Published var showCommonOpenError = false
    
    // MARK: - Initialization
    init(
        document: some BaseDocumentProtocol,
        viewInput: some EditorPageViewInput,
        router: some EditorRouterProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        headerModel: ObjectHeaderViewModel,
        blocksStateManager: some EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager,
        editorPageTemplatesHandler: some EditorPageTemplatesHandlerProtocol,
        configuration: EditorPageViewModelConfiguration,
        output: (any EditorPageModuleOutput)?
    ) {
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.headerModel = headerModel
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager
        self.editorPageTemplatesHandler = editorPageTemplatesHandler
        self.configuration = configuration
        self.output = output
        self.actionHandler = actionHandler
        
        setupLoadingState()
    }
    
    func setupSubscriptions() {
        subscriptions = []
        
        document.syncStatusDataPublisher.receiveOnMain().sink { [weak self] data in
            self?.handleSyncStatus(data: data)
        }.store(in: &subscriptions)
        
        document.flattenBlockIds.receiveOnMain().sink { [weak self] ids in
            self?.handleUpdate(ids: ids)
        }.store(in: &subscriptions)
        
        document.detailsPublisher.receiveOnMain().sink { [weak self] _ in
            self?.handleTemplatesIfNeeded()
        }.store(in: &subscriptions)
        
        document.permissionsPublisher.receiveOnMain().sink { [weak self] permissions in
            self?.handleTemplatesIfNeeded()
            self?.viewInput?.update(permissions: permissions)
            self?.blocksStateManager.checkOpenedState()
        }.store(in: &subscriptions)

        blocksStateManager.editorEditingStatePublisher.receiveOnMain().sink { [weak self] state in
            guard let self, let trailingBlockPlaceholder else { return }
            if case .editing = state { return }
            // An in-flight creation must not grab focus once the editor left editing mode.
            trailingBlockPlaceholder.session.invalidate()
            deactivateTrailingBlockPlaceholder(waitForMaterializedBlock: false)
        }.store(in: &subscriptions)
        
        headerModel.$header.receiveOnMain().sink { [weak self] value in
            guard let headerModel = value else { return }
            self?.updateHeaderIfNeeded(headerModel: headerModel)
        }.store(in: &subscriptions)
        
        document.resetBlocksPublisher.receiveOnMain().sink { [weak self] blockIds in
            guard let self else { return }
            let filtered = Set(blockIds).intersection(modelsHolder.blocksMapping.keys)
            
            // ignoring cache when reloading blocks
            let items = blockBuilder.buildEditorItems(infos: Array(filtered), ignoreCache: true)
            modelsHolder.updateItems(items)
            viewInput?.reconfigure(items: items)
        }.store(in: &subscriptions)
        
        // TODO: Use subscription when ready
        Task {
            publishState = try await publishingService.getStatus(spaceId: document.spaceId, objectId: document.objectId)
            let isVisible = publishState.isNotNil
            
            headerModel.updatePublishingBannerVisibility(isVisible)
            viewInput?.update(webBannerVisible: isVisible)
        }
    }
    
    private func setupLoadingState() {
        let shimmeringBlockViewModel = blockBuilder.buildShimeringItem()
        
        viewInput?.update(
            changes: nil,
            allModels: [shimmeringBlockViewModel],
            isRealData: false,
            animated: false,
            completion: { }
        )
    }
    
    private func handleUpdate(ids: [String]) {
        // An identity swap (virtual placeholder → real block, empty-block fork) must not be
        // rendered as an animated delete+insert of the same visible content.
        let containsIdentitySwap = BlockIdentitySwapStorage.shared.consumeSwap(in: ids)
        var blocksViewModels = blockBuilder.buildEditorItems(infos: ids, ignoreCache: false)
        if let trailingBlockPlaceholder {
            if let materializedId = trailingBlockPlaceholder.session.materializedBlockId,
               ids.contains(materializedId),
               !trailingBlockPlaceholder.session.awaitingFocusHandoff {
                cleanupTrailingBlockPlaceholder()
            } else {
                // While a focus handoff is pending, the focused placeholder cell must survive
                // the apply that inserts the created block: deleting the first responder's
                // cell briefly dismisses the keyboard (the accessory bar slides down). The
                // placeholder is removed when its text view resigns.
                blocksViewModels.append(trailingBlockPlaceholder.item)
            }
        }

        let wasEmpty = modelsHolder.items.isEmpty
        let difference = modelsHolder.difference(between: blocksViewModels)
        if difference.insertions.isNotEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.items = blocksViewModels
        }

        guard document.isOpened else { return }

        // Skip re-applying a full-section snapshot when nothing structurally changed.
        // `flattenBlockIds` is id-deduped, but a no-op emission still pays a full
        // diff inside `apply`. Keep applying when the models were just populated
        // (initial render) or when the initial scroll is still pending.
        let initialScrollPending = !didScrollToInitialBlock && configuration.blockId != nil
        if difference.isEmpty, !wasEmpty, !initialScrollPending {
            return
        }

        viewInput?.update(changes: difference, allModels: modelsHolder.items, isRealData: true, animated: !containsIdentitySwap) { [weak self] in
            guard let self else { return }
            cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
            initialScrollToBlockIfNeeded()
        }
    }
    
    private func initialScrollToBlockIfNeeded() {
        guard
            !didScrollToInitialBlock,
            let blockId = configuration.blockId,
            let index = modelsHolder.items.firstIndex(blockId: blockId) else { return }
        
        let item = modelsHolder.items[index]
        viewInput?.scrollToItem(item)
        didScrollToInitialBlock = true
    }
    
    private func difference(
        with blockIds: Set<String>
    ) -> CollectionDifference<EditorItem> {
        var currentModels = modelsHolder.items
        
        for (offset, model) in modelsHolder.items.enumerated() {
            guard case let .block(blockViewModel) = model else { continue }
            for blockId in blockIds {
                
                if blockViewModel.blockId == blockId {
                    guard let newViewModel = blockBuilder.build(blockId: blockId, ignoreCache: false) else {
                        continue
                    }
                    
                    currentModels[offset] = .block(newViewModel)
                }
            }
        }
        
        return modelsHolder.difference(between: currentModels)
    }
    
    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(headerModel: ObjectHeader) {
        guard modelsHolder.header != headerModel else {
            return
        }

        viewInput?.update(header: headerModel)
        modelsHolder.header = headerModel
    }
    
    private func handleTemplatesIfNeeded() {
        Task { @MainActor in
            guard document.permissions.canApplyTemplates, let details = document.details, details.isSelectTemplate else {
                await templatesSubscriptionService.stopSubscription()
                viewInput?.update(details: document.details, templatesCount: 0)
                return
            }
            
            _ = await templatesSubscriptionService.startSubscription(
                objectType: details.type,
                spaceId: document.spaceId
            ) { [weak self] details in
                await self?.handleTemplateSubscription(details: details)
            }
        }
    }
    
    private func handleSyncStatus(data: DocumentSyncStatusData) {
        let data = SyncStatusData(
            status: data.syncStatus,
            networkId: accountManager.account.info.networkId,
            isHidden: data.layout == .participant
        )
        viewInput?.update(syncStatusData: data)
    }
    
    func tapOnEmptyPlace(isBelowContent: Bool) {
        guard FeatureFlags.virtualTrailingBlock else {
            actionHandler.createEmptyBlock(parentId: document.objectId)
            return
        }
        guard isBelowContent, document.permissions.canEditBlocks else { return }

        if let trailingBlockPlaceholder {
            cursorManager.focus(at: trailingBlockPlaceholder.session.virtualId, position: .beginning)
            return
        }

        // Focus-reuse only an empty trailing block created by this session. A foreign empty
        // last block would make concurrent cursors from different clients converge on the
        // same block id, which loses text on whole-value last-writer-wins sync.
        if let lastModel = lastBlockViewModel,
           lastModel.info.isTextAndEmpty,
           lastModel.info.textContent?.contentType == .text,
           SessionCreatedBlockIdsStorage.shared.contains(lastModel.info.id) {
            lastModel.set(focus: .beginning)
            return
        }

        activateTrailingBlockPlaceholder()
    }

    private var lastBlockViewModel: (any BlockViewModelProtocol)? {
        for item in modelsHolder.items.reversed() {
            if case let .block(model) = item { return model }
        }
        return nil
    }

    private func activateTrailingBlockPlaceholder() {
        let virtualId = TrailingBlockPlaceholderConstants.idPrefix + UUID().uuidString
        let info = BlockInformation(
            id: virtualId,
            content: .text(.empty(contentType: .text)),
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(parentId: document.objectId, backgroundColor: .default),
            fields: [:]
        )
        document.infoContainer.add(info)

        let session = VirtualTrailingBlockSession(
            virtualId: virtualId,
            document: document,
            cursorManager: cursorManager,
            modelsHolder: modelsHolder,
            collectionController: EditorBlockCollectionController(viewInput: viewInput),
            onFinish: { [weak self] in
                self?.deactivateTrailingBlockPlaceholder()
            }
        )

        guard let item = blockBuilder.buildVirtualTrailingItem(virtualId: virtualId, session: session) else {
            document.infoContainer.remove(id: virtualId)
            return
        }

        trailingBlockPlaceholder = (session, item)
        cursorManager.blockFocus = BlockFocus(id: virtualId, position: .beginning)
        refreshTrailingBlockPlaceholder()
    }

    private func deactivateTrailingBlockPlaceholder(waitForMaterializedBlock: Bool = true) {
        guard let trailingBlockPlaceholder else { return }
        if waitForMaterializedBlock {
            // While the placeholder's text view is still first responder, removing its cell
            // briefly dismisses the keyboard; completeFocusHandoff finishes the removal.
            if trailingBlockPlaceholder.session.awaitingFocusHandoff { return }
            if let materializedId = trailingBlockPlaceholder.session.materializedBlockId,
               modelsHolder.items.firstIndex(blockId: materializedId) == nil {
                // The create event hasn't produced the real item yet. handleUpdate swaps the
                // placeholder for it in one snapshot; removing it now would tear down the
                // focused text view before the real cell can take over.
                return
            }
        }
        cleanupTrailingBlockPlaceholder()
        refreshTrailingBlockPlaceholder()
    }

    private func cleanupTrailingBlockPlaceholder() {
        guard let trailingBlockPlaceholder else { return }
        self.trailingBlockPlaceholder = nil
        document.infoContainer.remove(id: trailingBlockPlaceholder.session.virtualId)
        if cursorManager.blockFocus?.id == trailingBlockPlaceholder.session.virtualId {
            cursorManager.blockFocus = nil
        }
    }

    private func refreshTrailingBlockPlaceholder() {
        var items = modelsHolder.items.filter {
            !$0.blockId.hasPrefix(TrailingBlockPlaceholderConstants.idPrefix)
        }
        if let trailingBlockPlaceholder {
            items.append(trailingBlockPlaceholder.item)
        }

        modelsHolder.items = items
        guard document.isOpened else { return }
        // The placeholder is a blank line; showing or removing it must be instant — animating
        // its removal after materialization would double-render the just-created block.
        viewInput?.update(changes: nil, allModels: items, isRealData: true, animated: false, completion: { })
    }
    
    private func handleTemplateSubscription(details: [ObjectDetails]) {
        viewInput?.update(details: document.details, templatesCount: details.count)
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewDidLoad() {
        
        blocksStateManager.checkOpenedState()
        
        Task { @MainActor in
            do {
                try await document.open()
                if document.mode.isHandling {
                    blocksStateManager.checkOpenedState()
                }
            } catch ObjectOpenError.anytypeNeedsUpgrade {
                showUpdateAlert = true
            } catch {
                showCommonOpenError = true
            }
            
            if let objectDetails = document.details {
                AnytypeAnalytics.instance().logScreenObject(type: objectDetails.analyticsType, layout: objectDetails.resolvedLayoutValue, spaceId: objectDetails.spaceId)
            }
        }
    }
    
    func viewWillAppear() { }
    
    func viewDidAppear() {
        // document. simulate general update
        
        cursorManager.didAppeared(with: modelsHolder.items, type: document.details?.type)
    }
    
    func viewWillDisappear() {}
    
    func viewDidDissapear() {}
    
    func shakeMotionDidAppear() {
        router.showAlert(
            alertModel: .undoAlertModel(
                undoAction: { [weak self] in
                    guard let self = self else { return }
                    Task {
                        try await self.objectActionsService.undo(objectId: self.document.objectId)
                    }
                }
            )
        )
    }
    
    func onPublishingBannerTap() {
        if let details = document.details {
            AnytypeAnalytics.instance().logClickShareObjectOpenPage(objectType: details.objectType.analyticsType, route: .notification)
        }
        
        guard let publishState else {
            anytypeAssertionFailure("Empty PublishState upon banner tap")
            return
        }
        
        guard let domain = participantStorage.participants.first?.publishingDomain else {
            anytypeAssertionFailure("No participants found for account")
            return
        }
        
        guard let url = publishedUrlBuilder.buildPublishedUrl(domain: domain, customPath: publishState.uri) else { return }
        
        output?.openUrl(url)
    }

    // MARK: - EditorBottomNavigationManagerOutput

    func setHomeBottomPanelHidden(_ hidden: Bool, animated: Bool) {
        bottomPanelHidden = hidden
        bottomPanelHiddenAnimated = animated
    }
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at indexPath: IndexPath) {
        element(at: indexPath)?
            .didSelectRowInTableView(editorEditingState: blocksStateManager.editingState)
    }
    
    func didFinishEditing(blockId: String) {
        if blockId == BundledPropertyKey.description.rawValue {
            AnytypeAnalytics.instance().logSetObjectDescription()
        }
    }
    
    func element(at: IndexPath) -> (any BlockViewModelProtocol)? {
        modelsHolder.blockViewModel(at: at.row)
    }
}

extension EditorPageViewModel {
    @MainActor
    func showTemplates() {
        router.showTemplatesPicker()
    }
    
    func showSyncStatusInfo() {
        output?.showSyncStatusInfo(spaceId: document.spaceId)
    }

    func showWidgets() {
        output?.onWidgetsSelected(spaceId: document.spaceId)
    }
}

// Cursor
extension EditorPageViewModel {
    func cursorFocus(blockId: String) {
        cursorManager.restoreLastFocus(at: blockId)
    }
}

private enum TrailingBlockPlaceholderConstants {
    static let idPrefix = "virtual-trailing-block-"
}

// MARK: - Debug

extension EditorPageViewModel: @preconcurrency CustomDebugStringConvertible {
    var debugDescription: String {
        "\(Unmanaged.passUnretained(self).toOpaque()) -> \(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
