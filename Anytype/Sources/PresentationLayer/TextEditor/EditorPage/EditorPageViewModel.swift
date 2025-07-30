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
    @Injected(\.accountParticipantsStorage)
    private var participantStorage: any AccountParticipantsStorageProtocol
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
            completion: { }
        )
    }
    
    private func handleUpdate(ids: [String]) {
        let blocksViewModels = blockBuilder.buildEditorItems(infos: ids, ignoreCache: false)
        
        let difference = modelsHolder.difference(between: blocksViewModels)
        if difference.insertions.isNotEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.items = blocksViewModels
        }
        
        guard document.isOpened else { return }
        
        viewInput?.update(changes: difference, allModels: modelsHolder.items, isRealData: true) { [weak self] in
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
    
    func tapOnEmptyPlace() {
        actionHandler.createEmptyBlock(parentId: document.objectId)
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
            
            output?.setModuleInput(input: EditorPageModuleInputContainer(model: self), objectId: document.objectId)
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
    func showSettings() {
        router.showSettings()
    }
    
    func showSettings(output: any ObjectSettingsCoordinatorOutput) {
        router.showSettings(output: output)
    }
    
    @MainActor
    func showTemplates() {
        router.showTemplatesPicker()
    }
    
    func showSyncStatusInfo() {
        output?.showSyncStatusInfo(spaceId: document.spaceId)
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
