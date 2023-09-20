import Foundation
import SwiftUI
import Combine
import os
import Services
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?

    let blocksStateManager: EditorPageBlocksStateManagerProtocol

    let document: BaseDocumentProtocol
    let modelsHolder: EditorMainItemModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    let actionHandler: BlockActionHandlerProtocol
    let objectActionsService: ObjectActionsServiceProtocol

    private let searchService: SearchServiceProtocol
    private let cursorManager: EditorCursorManager
    private let blockBuilder: BlockViewModelBuilder
    private let headerModel: ObjectHeaderViewModel
    private let editorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol
    private let accountManager: AccountManagerProtocol
    private let configuration: EditorPageViewModelConfiguration
    
    private lazy var subscriptions = [AnyCancellable]()

    private let blockActionsService: BlockActionsServiceSingleProtocol

    // MARK: - Initialization
    init(
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
        blockDelegate: BlockDelegate,
        router: EditorRouterProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        headerModel: ObjectHeaderViewModel,
        blockActionsService: BlockActionsServiceSingleProtocol,
        blocksStateManager: EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager,
        objectActionsService: ObjectActionsServiceProtocol,
        searchService: SearchServiceProtocol,
        editorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol,
        accountManager: AccountManagerProtocol,
        configuration: EditorPageViewModelConfiguration
    ) {
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.actionHandler = actionHandler
        self.blockDelegate = blockDelegate
        self.headerModel = headerModel
        self.blockActionsService = blockActionsService
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager
        self.objectActionsService = objectActionsService
        self.searchService = searchService
        self.editorPageTemplatesHandler = editorPageTemplatesHandler
        self.accountManager = accountManager
        self.configuration = configuration

        setupLoadingState()
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

    private func setupLoadingState() {
        let shimmeringBlockViewModel = blockBuilder.buildShimeringItem()

        viewInput?.update(
            changes: nil,
            allModels: [shimmeringBlockViewModel]
        )
    }
    
    private func handleUpdate(updateResult: DocumentUpdate) {
        switch updateResult {

        case .general:
            performGeneralUpdate()

        case let .details(id):
            guard id == document.objectId else {
                performGeneralUpdate()
                return
            }

            let allRelationsBlockViewModel = modelsHolder.items.allRelationViewModel
            let relationIds = allRelationsBlockViewModel.map(\.blockId)
            let diffrerence = difference(with: Set(relationIds))

            guard !diffrerence.isEmpty else { return }
            modelsHolder.applyDifference(difference: diffrerence)

            guard document.isOpened else { return }
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)
        case let .blocks(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            let diffrerence = difference(with: updatedIds)

            modelsHolder.applyDifference(difference: diffrerence)

            guard document.isOpened else { return }
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)

            updateCursorIfNeeded()
        case .syncStatus(let status):
            viewInput?.update(syncStatus: status)
        case .dataSourceUpdate:
            let models = document.children

            let items = blockBuilder.buildEditorItems(infos: models)
            modelsHolder.items = items
        case .header:
            break // supported in headerModel
        }

        if !configuration.isOpenedForPreview {
            blocksStateManager.checkDocumentLockField()
        }
    }
    
    private func performGeneralUpdate() {
        let models = document.children
        
        let blocksViewModels = blockBuilder.buildEditorItems(infos: models)
        
        handleGeneralUpdate(with: blocksViewModels)

        if !document.isLocked {
            cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
            handleTemplatesPopupShowing()
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

    private func handleGeneralUpdate(with models: [EditorItem]) {
        let difference = modelsHolder.difference(between: models)
        if difference.insertions.isNotEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.items = models
        }

        guard document.isOpened else { return }
        
        viewInput?.update(changes: difference, allModels: modelsHolder.items)

        updateCursorIfNeeded()
    }

    private func updateCursorIfNeeded() {
        cursorManager.applyCurrentFocus()
    }

    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(headerModel: ObjectHeader) {
        guard modelsHolder.header != headerModel else {
            return
        }

        viewInput?.update(header: headerModel, details: document.details)
        modelsHolder.header = headerModel
    }
    
    private func handleTemplatesPopupShowing() {
        guard configuration.shouldShowTemplateSelection,
              editorPageTemplatesHandler.needShowTemplates(for: document),
              let type = document.details?.objectType else {
            return
        }
        router.showTemplatesPopupWithTypeCheckIfNeeded(
            document: document,
            templatesTypeId: .dynamic(type.id),
            onShow: { [weak self] in
                self?.editorPageTemplatesHandler.onTemplatesShow()
            }
        )
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewDidLoad() {
        
        blocksStateManager.checkOpenedState()
    
        Task { @MainActor in
            do {
                if configuration.isOpenedForPreview {
                    try await document.openForPreview()
                } else {
                    try await document.open()
                    blocksStateManager.checkOpenedState()
                }
            } catch {
                router.closeEditor()
            }
            
            if let objectDetails = document.details {
                AnytypeAnalytics.instance().logShowObject(type: objectDetails.analyticsType, layout: objectDetails.layoutValue)
            }
        }
    }
    
    func viewWillAppear() { }

    func viewDidAppear() {
        cursorManager.didAppeared(with: modelsHolder.items, type: document.details?.type)
        editorPageTemplatesHandler.didAppeared(with: document.details?.type)
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
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at indexPath: IndexPath) {
        element(at: indexPath)?
            .didSelectRowInTableView(editorEditingState: blocksStateManager.editingState)
    }
    
    func didFinishEditing(blockId: BlockId) {
        if blockId == BundledRelationKey.description.rawValue {
            AnytypeAnalytics.instance().logSetObjectDescription()
        }
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

// Cursor
extension EditorPageViewModel {
    func cursorFocus(blockId: BlockId) {
        cursorManager.restoreLastFocus(at: blockId)
    }
}

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(Unmanaged.passUnretained(self).toOpaque()) -> \(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
