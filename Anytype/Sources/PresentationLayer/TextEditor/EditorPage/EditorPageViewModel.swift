import Foundation
import SwiftUI
import UIKit
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
    @Injected(\.blockIdentitySwapStorage)
    private var blockIdentitySwapStorage: any BlockIdentitySwapStorageProtocol
    // Latched at page open: the pipeline choice must stay consistent for the page's lifetime —
    // models rebound under one identity scheme must not meet the other's swap handling. This
    // is the only production read of the flag; every refusal path degrades to the fallback
    // handoff pipeline, which keeps the keyboard alive on its own.
    private let stableRowIdentityOnFork = FeatureFlags.stableRowIdentityOnFork
    
    
    private let cursorManager: EditorCursorManager
    private let blockBuilder: BlockViewModelBuilder
    private let rowIdentityMap: BlockRowIdentityMap
    private let headerModel: ObjectHeaderViewModel
    private let editorPageTemplatesHandler: any EditorPageTemplatesHandlerProtocol
    private let configuration: EditorPageViewModelConfiguration
    
    private weak var output: (any EditorPageModuleOutput)?
    lazy var subscriptions = [AnyCancellable]()
    private var didScrollToInitialBlock = false
    private var publishState: PublishState?
    private var trailingBlockPlaceholder: (session: VirtualTrailingBlockSession, item: EditorItem)?
    // Focus handoffs for just-consumed arrivals (empty-block identity forks, Enter-created
    // rows), completed synchronously right after the apply; fork entries additionally keep
    // their old row in the snapshot meanwhile. See finishArrivalFocusHandoffs.
    private var pendingFocusHandoffs = [ArrivalFocusHandoff]()

    private struct ArrivalFocusHandoff {
        let swap: BlockIdentitySwap
        let focusPosition: BlockFocusPosition
    }

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
        rowIdentityMap: BlockRowIdentityMap,
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
        self.rowIdentityMap = rowIdentityMap
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
        // Consumed identity swaps (virtual placeholder → real block, empty-block fork) are
        // normally rebound in place and render as nothing — see rebindIdentitySwaps. When a
        // rebind declines, the swap must still not render as an animated delete+insert of the
        // same visible content, so it stays in activeSwaps and forces an unanimated apply. An
        // Enter-created row keeps UIKit's native animated insert and caret move except at the
        // bottom edge, where the insert competes with the caret-visibility scroll and renders
        // as a jump — only there the unanimated one-commit pipeline takes over.
        let identitySwaps = blockIdentitySwapStorage.consumeSwaps(in: ids)
        let idsSet = Set(ids)
        rebindUndoneIdentitySwaps(ids: idsSet)
        let reboundOldIds = rebindIdentitySwaps(identitySwaps, ids: idsSet)
        let needsBottomHandling = identitySwaps.contains(where: \.isKeyboardInsert) && viewInput?.isFirstResponderNearBottom() == true
        let activeSwaps = identitySwaps.compactMap { swap -> BlockIdentitySwap? in
            if let oldId = swap.oldBlockId, reboundOldIds.contains(oldId) { return nil }
            if swap.isKeyboardInsert, !needsBottomHandling { return nil }
            // A placeholder swap the rebind refused takes the session-managed path the
            // fallback pipeline expects (oldBlockId nil): its old row is not a document
            // block, and retaining it would duplicate the appended placeholder item.
            if let oldId = swap.oldBlockId, oldId.hasPrefix(TrailingBlockPlaceholderConstants.idPrefix) {
                return BlockIdentitySwap(newBlockId: swap.newBlockId, oldBlockId: nil, isKeyboardInsert: swap.isKeyboardInsert)
            }
            return swap
        }
        var blocksViewModels = blockBuilder.buildEditorItems(infos: ids, ignoreCache: false)
        retainStaleForkRows(newSwaps: activeSwaps, in: &blocksViewModels)
        if let trailingBlockPlaceholder {
            if reboundOldIds.contains(trailingBlockPlaceholder.session.virtualId) {
                // The placeholder's model was just rebound to the created block: the cell —
                // still first responder — continues as the real block's cell. Tell the session
                // its handoff is complete (a later applyFocus must not re-apply a stale caret),
                // then the bookkeeping can go without touching the cell.
                trailingBlockPlaceholder.session.focusHandoffCompletedByRebind()
                cleanupTrailingBlockPlaceholder()
            } else if let materializedId = trailingBlockPlaceholder.session.materializedBlockId,
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

        viewInput?.update(changes: difference, allModels: modelsHolder.items, isRealData: true, animated: activeSwaps.isEmpty) { [weak self] in
            guard let self else { return }
            cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
            initialScrollToBlockIfNeeded()
            removeStaleForkRowsAfterFocusHandoff()
        }
        finishArrivalFocusHandoffs()
    }

    /// Consumed identity swaps whose replaced row is live in this editor are applied in place:
    /// the row's existing view model rebinds to the new block id while its `rowIdentity` keeps
    /// the diffable identifier constant. The swap then diffs as an empty change — no
    /// delete+insert, no responder move — so the keyboard input session (autocorrect's
    /// per-word buffer) survives the first character typed into an empty block. Swaps this
    /// cannot take (flag off, model not in the holder — e.g. simple-table cells — or
    /// Enter-created rows) fall through to the arrival-handoff pipeline below.
    /// Returns the old ids that were rebound.
    private func rebindIdentitySwaps(_ swaps: [BlockIdentitySwap], ids: Set<String>) -> Set<String> {
        guard stableRowIdentityOnFork else { return [] }
        var reboundOldIds = Set<String>()
        var reboundItems = [EditorItem]()
        for swap in swaps {
            guard !swap.isKeyboardInsert, let oldId = swap.oldBlockId else { continue }
            // Two swaps against one old id would resolve the same model twice and collide a
            // later rebuild of the intermediate id on its row identity.
            guard !reboundOldIds.contains(oldId) else { continue }
            // While the old block is still present the swap event has not fully applied; a
            // snapshot holding both ids under one row identity would contain duplicate
            // identifiers, so leave such a swap to the fallback pipeline.
            guard !ids.contains(oldId) else { continue }
            // Same when a row for the new id already exists — its event batch outran the swap
            // registration; aliasing it now would collide two rows under one identity.
            guard modelsHolder.blocksMapping[swap.newBlockId] == nil else { continue }
            guard let model = modelsHolder.blocksMapping[oldId] as? TextBlockViewModel,
                  let newInfo = document.infoContainer.get(id: swap.newBlockId) else { continue }
            // Alias before buildEditorItems runs, so a model built for the new id in this very
            // pass — or by a later ignoreCache reset — lands on the replaced row's identity.
            // A declined registration means the new id already belongs to another row: rebind
            // nothing, fall back.
            guard rowIdentityMap.alias(newBlockId: swap.newBlockId, toRowOf: oldId) else { continue }
            model.rebind(to: newInfo)
            cursorManager.aliasFocusSubject(oldId: oldId, newId: swap.newBlockId)
            // The fork-time pending focus has no consumer on this path — the cell keeps first
            // responder throughout — and left in place it would poison a later reconfigure
            // with a stale caret write.
            if cursorManager.blockFocus?.id == swap.newBlockId {
                cursorManager.blockFocus = nil
            }
            reboundOldIds.insert(oldId)
            reboundItems.append(.block(model))
        }
        if reboundOldIds.isNotEmpty {
            // Re-key blocksMapping to the new ids before buildEditorItems consults its cache.
            modelsHolder.updateMappings()
            // Refresh the live cell from the rebound model: the empty diff will never
            // reconfigure it, and its configuration still carries the replaced id (drag id,
            // leading-view key). applyNewConfiguration skips the text-storage write while the
            // text is identical, so the keyboard input session survives this refresh.
            // Unanimated: this targets the focused cell mid-swap — a height change animating
            // around the caret is exactly what the swap pipeline exists to prevent.
            UIView.performWithoutAnimation {
                viewInput?.reconfigure(items: reboundItems)
            }
        }
        return reboundOldIds
    }

    /// Undo can restore a block an in-place rebind replaced: the live row then carries a
    /// deleted id while its predecessor reappears in `ids`. Rebind the row back and drop the
    /// alias so the restored block renders through its own identity again — without this the
    /// empty diff keeps the stale row on screen and routes edits to the deleted id. Runs
    /// regardless of the flag latch: aliases recorded earlier must stay reversible.
    private func rebindUndoneIdentitySwaps(ids: Set<String>) {
        let undone = rowIdentityMap.undoneAliases(presentIds: ids)
        guard undone.isNotEmpty else { return }
        var reboundItems = [EditorItem]()
        for alias in undone {
            guard let model = modelsHolder.blocksMapping[alias.newBlockId] as? TextBlockViewModel else {
                // No live row carries the forked id — nothing to rebind back; drop the alias
                // so the scan stops matching it.
                rowIdentityMap.removeAlias(newBlockId: alias.newBlockId)
                continue
            }
            guard modelsHolder.blocksMapping[alias.replacedBlockId] == nil,
                  let restoredInfo = document.infoContainer.get(id: alias.replacedBlockId) else {
                // Keep the alias: consuming it on a failed rebind would leave the live row
                // stranded on the deleted id with no way back. The scan retries next pass.
                continue
            }
            rowIdentityMap.removeAlias(newBlockId: alias.newBlockId)
            model.rebindAfterIdentityUndo(to: restoredInfo)
            cursorManager.removeFocusSubjectAlias(oldId: alias.replacedBlockId, newId: alias.newBlockId)
            if cursorManager.blockFocus?.id == alias.newBlockId {
                cursorManager.blockFocus = nil
            }
            reboundItems.append(.block(model))
        }
        guard reboundItems.isNotEmpty else { return }
        modelsHolder.updateMappings()
        // The restored text differs from the typed one, so this reconfigure intentionally
        // rewrites the text storage — undo is expected to reset the typing session. The row
        // itself never leaves the snapshot: the same cell keeps first responder throughout.
        UIView.performWithoutAnimation {
            viewInput?.reconfigure(items: reboundItems)
        }
    }

    /// Fallback pipeline: under stableRowIdentityOnFork consumed fork swaps are normally
    /// rebound in place (rebindIdentitySwaps) and never reach this path; it still serves
    /// Enter-created rows, refused rebinds and the flag-off configuration.
    ///
    /// The empty-block identity fork replaces the focused block's row with a fresh id. Deleting
    /// the first responder's cell in that apply briefly dismisses the keyboard, so while a focus
    /// handoff to the forked id is pending, the old row stays in the snapshot — the trailing
    /// placeholder's awaitingFocusHandoff trick. finishArrivalFocusHandoffs completes the swap
    /// right after the apply, within the same render commit.
    private func retainStaleForkRows(newSwaps: [BlockIdentitySwap], in items: inout [EditorItem]) {
        // A pending focus for the new id means the arrival wants the keyboard: the old block's
        // cell holds it (fork), or the caret is about to move into the created row (Enter).
        if let blockFocus = cursorManager.blockFocus {
            pendingFocusHandoffs += newSwaps
                .filter { blockFocus.id == $0.newBlockId }
                .map { ArrivalFocusHandoff(swap: $0, focusPosition: blockFocus.position) }
        }
        guard pendingFocusHandoffs.isNotEmpty else { return }
        pendingFocusHandoffs.removeAll { handoff in
            // Only fork rows have an old row to keep alive; Enter-created rows just wait for
            // their synchronous focus in finishArrivalFocusHandoffs.
            guard let oldBlockId = handoff.swap.oldBlockId else { return false }
            guard let oldModel = modelsHolder.blocksMapping[oldBlockId],
                  items.firstIndex(blockId: oldBlockId) == nil,
                  let newIndex = items.firstIndex(blockId: handoff.swap.newBlockId) else { return true }
            // The old row keeps its position; the new block's row slides into it on removal.
            items.insert(.block(oldModel), at: newIndex)
            return false
        }
    }

    /// Runs right after the unanimated snapshot apply that inserted the arrived cells — the
    /// apply is synchronous on the main queue, so the new cells are already on screen but
    /// nothing has been committed to the render server yet. Moving first responder into the new
    /// cell (with its caret scrolled visible) and dropping a fork's stale row here keeps the
    /// whole arrival inside one render commit: no transient two-row layout, no keyboard dip,
    /// and no separate insert-then-scroll step.
    private func finishArrivalFocusHandoffs() {
        guard pendingFocusHandoffs.isNotEmpty, let viewInput else { return }
        var removedIds = Set<String>()
        var focusedIds = [String]()
        pendingFocusHandoffs.removeAll { handoff in
            guard viewInput.takeFocus(blockId: handoff.swap.newBlockId, position: handoff.focusPosition) else {
                // Cell not on screen: the deferred initial focus covers Enter rows; fork rows
                // stay pending for removeStaleForkRowsAfterFocusHandoff.
                return handoff.swap.oldBlockId == nil
            }
            handoff.swap.oldBlockId.map { removedIds.insert($0) }
            focusedIds.append(handoff.swap.newBlockId)
            return true
        }
        if removedIds.isNotEmpty {
            let items = modelsHolder.items.filter { !removedIds.contains($0.blockId) }
            if items.count != modelsHolder.items.count, document.isOpened {
                modelsHolder.items = items
                viewInput.update(changes: nil, allModels: items, isRealData: true, animated: false, completion: {})
            }
        }
        // Reveal only after the stale fork rows are gone: measuring the focused cell against a
        // layout still inflated by a retained duplicate row scrolls one row too far.
        focusedIds.forEach { viewInput.revealBlock(blockId: $0) }
    }

    /// Fallback for fork handoffs finishArrivalFocusHandoffs could not complete synchronously
    /// (the new cell was not on screen). Runs in the apply's completion: the new cell's deferred
    /// initial focus was enqueued on the main queue during that apply, so after one more hop the
    /// old text view has already handed first responder over and its row can be deleted without
    /// touching the keyboard.
    private func removeStaleForkRowsAfterFocusHandoff() {
        guard pendingFocusHandoffs.isNotEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, pendingFocusHandoffs.isNotEmpty else { return }
            let staleIds = Set(pendingFocusHandoffs.compactMap(\.swap.oldBlockId))
            pendingFocusHandoffs.removeAll()
            let items = modelsHolder.items.filter { !staleIds.contains($0.blockId) }
            guard items.count != modelsHolder.items.count else { return }
            modelsHolder.items = items
            guard document.isOpened else { return }
            viewInput?.update(changes: nil, allModels: items, isRealData: true, animated: false, completion: {})
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
