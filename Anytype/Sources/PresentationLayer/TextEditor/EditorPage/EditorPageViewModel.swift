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
    @Injected(\.keyboardInsertedBlocksStorage)
    private var keyboardInsertedBlocksStorage: any KeyboardInsertedBlocksStorageProtocol


    private let cursorManager: EditorCursorManager
    private let blockBuilder: BlockViewModelBuilder
    // Rebinds rows whose forked id was undone; the fork itself is applied synchronously at
    // the keystroke by the text block handlers (see BlockForkRebinder).
    private let forkRebinder: BlockForkRebinder
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
        forkRebinder: BlockForkRebinder,
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
        self.forkRebinder = forkRebinder
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
            // A pending placeholder focus must not fire once the editor left editing mode.
            // An unmaterialized placeholder disappears; a materializing or materialized one
            // is (about to be) a real block, so its row stays.
            trailingBlockPlaceholder.session.invalidate()
            if !trailingBlockPlaceholder.session.isMaterialized, !trailingBlockPlaceholder.session.isMaterializing {
                removeTrailingBlockPlaceholder()
            }
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
        let idsSet = Set(ids)
        // Rows whose forked id was undone rebind back to the restored block before the build
        // below consults the fork chain.
        forkRebinder.rebindUndoneForks(presentIds: idsSet)
        // An Enter-created row keeps UIKit's native animated insert and caret move except at
        // the bottom edge, where the insert competes with the caret-visibility scroll and
        // renders as a jump — only there the unanimated one-commit pipeline takes over.
        let keyboardInsertedIds = keyboardInsertedBlocksStorage.consume(in: ids)
        let needsBottomHandling = !keyboardInsertedIds.isEmpty && viewInput?.isFirstResponderNearBottom() == true
        // The synchronous focus handoff pairs with the unanimated apply: only at the bottom
        // edge. Elsewhere the row's deferred initial focus moves the caret, and grabbing
        // first responder mid animated apply would fight the insert animation.
        let enterFocusHandoffs = needsBottomHandling ? enterRowFocusHandoffs(for: keyboardInsertedIds) : []
        var blocksViewModels = blockBuilder.buildEditorItems(infos: ids, ignoreCache: false)
        if let trailingBlockPlaceholder {
            if idsSet.contains(trailingBlockPlaceholder.session.blockId) {
                // The created block reached the document under the same id the placeholder
                // row already carries: the build above reused the placeholder's model, so
                // the row — and its focused cell — continue seamlessly. Only the session
                // bookkeeping goes; the block's info is real now and stays.
                self.trailingBlockPlaceholder = nil
            } else {
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

        viewInput?.update(changes: difference, allModels: modelsHolder.items, isRealData: true, animated: !needsBottomHandling) { [weak self] in
            guard let self else { return }
            cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
            initialScrollToBlockIfNeeded()
        }
        finishEnterRowFocusHandoffs(enterFocusHandoffs)
    }

    /// A pending focus for a just-arrived keyboard-inserted id means the caret is about to
    /// move into the created row.
    private func enterRowFocusHandoffs(for arrivedIds: [String]) -> [(blockId: String, position: BlockFocusPosition)] {
        guard let blockFocus = cursorManager.blockFocus else { return [] }
        return arrivedIds.filter { $0 == blockFocus.id }.map { ($0, blockFocus.position) }
    }

    /// Runs right after the snapshot apply that inserted the Enter-created cells — the apply
    /// is synchronous on the main queue, so the new cells are already on screen but nothing
    /// has been committed to the render server yet. Moving first responder into the new cell
    /// (with its caret scrolled visible) here keeps the arrival inside one render commit: no
    /// keyboard dip and no separate insert-then-scroll step.
    private func finishEnterRowFocusHandoffs(_ handoffs: [(blockId: String, position: BlockFocusPosition)]) {
        guard !handoffs.isEmpty, let viewInput else { return }
        for handoff in handoffs {
            // Cell not on screen: the deferred initial focus covers it.
            guard viewInput.takeFocus(blockId: handoff.blockId, position: handoff.position) else { continue }
            viewInput.revealBlock(blockId: handoff.blockId)
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
            cursorManager.focus(at: trailingBlockPlaceholder.session.blockId, position: .beginning)
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
        // The placeholder is born with the block's final id: materialization sends this id
        // in the BlockCreate request, so becoming real never changes the row's identity —
        // the focused cell and its keyboard input session continue untouched.
        let blockId = BlockIdGenerator.mint()
        let info = BlockInformation(
            id: blockId,
            content: .text(.empty(contentType: .text)),
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(parentId: document.objectId, backgroundColor: .default),
            fields: [:]
        )
        document.infoContainer.add(info)

        let session = VirtualTrailingBlockSession(
            blockId: blockId,
            document: document,
            cursorManager: cursorManager,
            onDismiss: { [weak self] in
                self?.removeTrailingBlockPlaceholder()
            },
            onDismissAndFocusPreviousBlock: { [weak self] in
                self?.removeTrailingBlockPlaceholderFocusingPreviousBlock()
            },
            onMaterializationFailed: { [weak self] in
                self?.trailingBlockPlaceholderMaterializationDidFail()
            }
        )

        guard let item = blockBuilder.buildVirtualTrailingItem(blockId: blockId, session: session) else {
            document.infoContainer.remove(id: blockId)
            return
        }

        trailingBlockPlaceholder = (session, item)
        cursorManager.blockFocus = BlockFocus(id: blockId, position: .beginning)
        appendTrailingBlockPlaceholderItem()
    }

    /// A BlockCreate attempt failed and the session is active again. While the editor is
    /// still editing the row stays — the next input retries the create, and removing it
    /// would throw away the typed text. Once editing ended nothing can retry, so the
    /// placeholder must not linger as a ghost row over a block that was never created.
    private func trailingBlockPlaceholderMaterializationDidFail() {
        guard trailingBlockPlaceholder != nil else { return }
        if case .editing = blocksStateManager.editingState { return }
        removeTrailingBlockPlaceholder()
    }

    /// Removes a never-materialized placeholder: its fabricated info, its pending focus and
    /// its row.
    private func removeTrailingBlockPlaceholder() {
        guard let trailingBlockPlaceholder else { return }
        self.trailingBlockPlaceholder = nil
        let blockId = trailingBlockPlaceholder.session.blockId
        document.infoContainer.remove(id: blockId)
        if cursorManager.blockFocus?.id == blockId {
            cursorManager.blockFocus = nil
        }
        let items = modelsHolder.items.filter { $0.blockId != blockId }
        guard items.count != modelsHolder.items.count else { return }
        modelsHolder.items = items
        guard document.isOpened else { return }
        // The placeholder is a blank line; removing it must be instant.
        viewInput?.update(changes: nil, allModels: items, isRealData: true, animated: false, completion: { })
    }

    /// Backspace dismissal: the previous text block takes first responder *before* the
    /// placeholder row leaves the snapshot — removing the focused cell first briefly
    /// dismisses the keyboard (the invariant from IOS-6594: no row holding first responder
    /// is removed unless a replacement has already taken it).
    private func removeTrailingBlockPlaceholderFocusingPreviousBlock() {
        guard let trailingBlockPlaceholder else { return }
        let previousModel = modelsHolder.findModel(
            beforeBlockId: trailingBlockPlaceholder.session.blockId,
            acceptingTypes: BlockContentType.allTextTypes
        )
        let focusTaken = previousModel.map { viewInput?.takeFocus(blockId: $0.blockId, position: .end) == true } ?? false
        removeTrailingBlockPlaceholder()
        if let previousModel, !focusTaken {
            // Cell not on screen: fall back to the deferred focus path; the keyboard blips,
            // but the caret still lands in the right block.
            previousModel.set(focus: .end)
        }
    }

    private func appendTrailingBlockPlaceholderItem() {
        guard let trailingBlockPlaceholder else { return }
        let items = modelsHolder.items + [trailingBlockPlaceholder.item]
        modelsHolder.items = items
        guard document.isOpened else { return }
        // Showing the placeholder must be instant — it renders as the caret landing on a
        // blank line, not as a row animating in.
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

// MARK: - Debug

extension EditorPageViewModel: @preconcurrency CustomDebugStringConvertible {
    var debugDescription: String {
        "\(Unmanaged.passUnretained(self).toOpaque()) -> \(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
