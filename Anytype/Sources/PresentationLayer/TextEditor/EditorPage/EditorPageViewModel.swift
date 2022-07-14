import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?

    let blocksStateManager: EditorPageBlocksStateManagerProtocol

    let document: BaseDocumentProtocol
    let modelsHolder: EditorMainItemModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    let actionHandler: BlockActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    let objectActionsService: ObjectActionsServiceProtocol

    private let searchService: SearchServiceProtocol
    private let cursorManager: EditorCursorManager
    private let blockBuilder: BlockViewModelBuilder
    private let headerModel: ObjectHeaderViewModel
    private let isOpenedForPreview: Bool

    private lazy var subscriptions = [AnyCancellable]()

    private let blockActionsService: BlockActionsServiceSingleProtocol

    deinit {
        Task.detached(priority: .userInitiated) { [document, blockActionsService] in
            try await blockActionsService.close()
            EventsBunch(
                contextId: AccountManager.shared.account.info.homeObjectID,
                localEvents: [.documentClosed(blockId: document.objectId)]
            ).send()
        }
    }

    // MARK: - Initialization
    init(
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
        blockDelegate: BlockDelegate,
        router: EditorRouterProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        wholeBlockMarkupViewModel: MarkupViewModel,
        headerModel: ObjectHeaderViewModel,
        blockActionsService: BlockActionsServiceSingleProtocol,
        blocksStateManager: EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager,
        objectActionsService: ObjectActionsServiceProtocol,
        searchService: SearchServiceProtocol,
        isOpenedForPreview: Bool
    ) {
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.actionHandler = actionHandler
        self.blockDelegate = blockDelegate
        self.wholeBlockMarkupViewModel = wholeBlockMarkupViewModel
        self.headerModel = headerModel
        self.blockActionsService = blockActionsService
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager
        self.objectActionsService = objectActionsService
        self.searchService = searchService
        self.isOpenedForPreview = isOpenedForPreview
    }

    func setupSubscriptions() {
        subscriptions = []
        
        document.updatePublisher.sink { [weak self] in
            self?.handleUpdate(updateResult: $0)
        }.store(in: &subscriptions)
        
        headerModel.$header.sink { [weak self] value in
            guard let headerModel = value else { return }
            self?.updateHeaderIfNeeded(headerModel: headerModel)
        }.store(in: &subscriptions)
    }
    
    private func handleUpdate(updateResult: DocumentUpdate) {
        switch updateResult {

        case .general:
            performGeneralUpdate()

        case let .details(id):
            guard id == document.objectId else {
                #warning("call blocks update with new details to update mentions/links")
                performGeneralUpdate()
                return
            }
            
            #warning("also we should check if blocks in current object contains mantions/link to current object if YES we must update blocks with updated details")

            let allRelationsBlockViewModel = modelsHolder.items.allRelationViewModel
            let relationIds = allRelationsBlockViewModel.map(\.blockId)
            let diffrerence = difference(with: Set(relationIds))

            guard !diffrerence.isEmpty else { return }
            modelsHolder.applyDifference(difference: diffrerence)
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)
        case let .blocks(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            let diffrerence = difference(with: updatedIds)
            updateMarkupViewModel(updatedIds)

            modelsHolder.applyDifference(difference: diffrerence)
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)

            updateCursorIfNeeded()
        case .syncStatus(let status):
            viewInput?.update(syncStatus: status)
        case .dataSourceUpdate:
            let models = document.children

            let blocksViewModels = blockBuilder.buildEditorItems(infos: models)
            modelsHolder.items = blocksViewModels
        case .header, .changeType:
            break // supported in headerModel
        }

        if !isOpenedForPreview {
            blocksStateManager.checkDocumentLockField()
        }
    }
    
    private func performGeneralUpdate() {
        handleDeletionState()
        
        let models = document.children
        
        let blocksViewModels = blockBuilder.buildEditorItems(infos: models)
        
        handleGeneralUpdate(with: blocksViewModels)
        
        updateMarkupViewModel(newBlockViewModels: blocksViewModels.onlyBlockViewModels)

        if !document.isLocked {
            cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
        }
    }
    
    private func handleDeletionState() {
        guard let details = document.details else {
            anytypeAssertionFailure("No detais for general update", domain: .editorPage)
            return
        }
        
        viewInput?.showDeletedScreen(details.isDeleted)
        if details.isArchived {
            router.goBack()
        }
    }


    private func difference(
        with blockIds: Set<BlockId>
    ) -> CollectionDifference<EditorItem> {
        var currentModels = modelsHolder.items
        
        for (offset, model) in modelsHolder.items.enumerated() {
            guard case let .block(blockViewModel) = model else { continue }
            for blockId in blockIds {
                if blockViewModel.blockId == blockId {
                    guard let model = document.infoContainer.get(id: blockId),
                          let newViewModel = blockBuilder.build(info: model) else {
                              continue
                          }


                    currentModels[offset] = .block(newViewModel)
                }
            }
        }

        return modelsHolder.difference(between: currentModels)
    }
    
    private func updateMarkupViewModel(_ updatedBlockIds: Set<BlockId>) {
        guard let blockIdWithMarkupMenu = wholeBlockMarkupViewModel.blockInformation?.id,
              updatedBlockIds.contains(blockIdWithMarkupMenu) else {
            return
        }
        updateMarkupViewModelWith(informationBy: blockIdWithMarkupMenu)
    }
    
    private func updateMarkupViewModel(newBlockViewModels: [BlockViewModelProtocol]) {
        guard let blockIdWithMarkupMenu = wholeBlockMarkupViewModel.blockInformation?.id else {
            return
        }
        let blockIds = Set(newBlockViewModels.map { $0.blockId })
        guard blockIds.contains(blockIdWithMarkupMenu) else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        updateMarkupViewModelWith(informationBy: blockIdWithMarkupMenu)
    }
    
    private func updateMarkupViewModelWith(informationBy blockId: BlockId) {
        guard let currentInformation = document.infoContainer.get(id: blockId) else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            AnytypeLogger(category: "Editor page view model").debug("Could not find object with id: \(blockId)")
            return
        }
        guard case .text = currentInformation.content else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        wholeBlockMarkupViewModel.blockInformation = currentInformation
    }

    private func handleGeneralUpdate(with models: [EditorItem]) {
        let difference = modelsHolder.difference(between: models)
        if difference.insertions.isNotEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.items = models
        }
        
        viewInput?.update(changes: difference, allModels: modelsHolder.items)

        updateCursorIfNeeded()
    }

    private func updateCursorIfNeeded() {
        if let blockFocus = cursorManager.blockFocus,
           let block = modelsHolder.contentProvider(for: blockFocus.id) {

            block.set(focus: blockFocus.position)
            cursorManager.blockFocus = nil
        }
    }

    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(headerModel: ObjectHeader) {
        guard modelsHolder.header != headerModel else {
            return
        }

        viewInput?.update(header: headerModel, details: document.details)
        modelsHolder.header = headerModel
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewDidLoad() {
        if let objectDetails = document.details {
            AnytypeAnalytics.instance().logShowObject(type: objectDetails.type, layout: objectDetails.layout)
        }
        
        blocksStateManager.checkOpenedState()
    
        Task { @MainActor in
            do {
                if isOpenedForPreview {
                    try await document.openForPreview()
                } else {
                    try await document.open()
                }
                blocksStateManager.checkOpenedState()
            } catch {
                router.goBack()
            }
        }
    }
    
    func viewWillAppear() { }

    func viewDidAppear() {
        cursorManager.didAppeared(with: modelsHolder.items, type: document.details?.type)
    }

    func viewWillDisappear() {}

    func viewDidDissapear() {}


    func shakeMotionDidAppear() {
        router.showAlert(
            alertModel: .undoAlertModel(
                undoAction: { [weak self] in
                    guard let self = self else { return }
                    try? self.objectActionsService.undo(objectId: self.document.objectId)
                }
            )
        )
    }
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at indexPath: IndexPath) {
        element(at: indexPath)?
            .didSelectRowInTableView(editorEditingState: blocksStateManager.editingState)
    }

    func element(at: IndexPath) -> BlockViewModelProtocol? {
        modelsHolder.blockViewModel(at: at.row)
    }
}

extension EditorPageViewModel {
    
    func showSettings() {
        router.showSettings()
    }
    
    func showIconPicker() {
        router.showIconPicker()
    }
    
    func showCoverPicker() {
        router.showCoverPicker()
    }
}

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
