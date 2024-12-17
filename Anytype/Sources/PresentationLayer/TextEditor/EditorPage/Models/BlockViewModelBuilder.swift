import Services
import Combine
import UniformTypeIdentifiers
import AnytypeCore

@MainActor
final class BlockViewModelBuilder {
    private let document: any BaseDocumentProtocol
    private let handler: any BlockActionHandlerProtocol
    private let router: any EditorRouterProtocol
    private let subjectsHolder: FocusSubjectsHolder
    private let markdownListener: any MarkdownListener
    private let simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder
    private let infoContainer: any InfoContainerProtocol
    private let modelsHolder: EditorMainItemModelsHolder
    private let blockCollectionController: EditorBlockCollectionController
    private let accessoryStateManager: any AccessoryViewStateManager
    private let cursorManager: EditorCursorManager
    private let keyboardActionHandler: any KeyboardActionHandlerProtocol
    private let editorPageBlocksStateManager: EditorPageBlocksStateManager
    private let markupChanger: any BlockMarkupChangerProtocol
    private let slashMenuActionHandler: SlashMenuActionHandler
    private weak var output: (any EditorPageModuleOutput)?
    
    @Injected(\.blockTableService)
    private var tableService: any BlockTableServiceProtocol
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @Injected(\.audioSessionService)
    private var audioSessionService: any AudioSessionServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.pasteboardBlockDocumentService)
    private var pasteboardService: any PasteboardBlockDocumentServiceProtocol
    
    
    init(
        document: some BaseDocumentProtocol,
        handler: some BlockActionHandlerProtocol,
        router: some EditorRouterProtocol,
        markdownListener: some MarkdownListener,
        simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder,
        subjectsHolder: FocusSubjectsHolder,
        infoContainer: some InfoContainerProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockCollectionController: EditorBlockCollectionController,
        accessoryStateManager: some AccessoryViewStateManager,
        cursorManager: EditorCursorManager,
        keyboardActionHandler: some KeyboardActionHandlerProtocol,
        markupChanger: some BlockMarkupChangerProtocol,
        slashMenuActionHandler: SlashMenuActionHandler,
        editorPageBlocksStateManager: EditorPageBlocksStateManager,
        output: (any EditorPageModuleOutput)?
    ) {
        self.document = document
        self.handler = handler
        self.router = router
        self.markdownListener = markdownListener
        self.simpleTableDependenciesBuilder = simpleTableDependenciesBuilder
        self.subjectsHolder = subjectsHolder
        self.infoContainer = infoContainer
        self.modelsHolder = modelsHolder
        self.blockCollectionController = blockCollectionController
        self.accessoryStateManager = accessoryStateManager
        self.cursorManager = cursorManager
        self.keyboardActionHandler = keyboardActionHandler
        self.markupChanger = markupChanger
        self.slashMenuActionHandler = slashMenuActionHandler
        self.editorPageBlocksStateManager = editorPageBlocksStateManager
        self.output = output
    }
    
    func buildEditorItems(infos: [String]) -> [EditorItem] {
        let viewModels = build(infos)
        return buildEditorItems(viewModels)
    }
    
    func buildEditorItems(_ viewModels: [any BlockViewModelProtocol]) -> [EditorItem] {
        var items = viewModels.map(EditorItem.block)
        
        items = removeBlockFileIfNeeded(items)
        let featureRelationsIndex = viewModels.firstIndex { $0.content == .featuredRelations }
        let openFileButton = createOpenFileButtonIfNeeded()
        let spacer = SpacerBlockViewModel(usage: .firstRowOffset)
        
        if let featureRelationsIndex, let openFileButton  {
            items.insert(openFileButton, at: featureRelationsIndex + 1)
            items.insert(.system(spacer), at: featureRelationsIndex + 2)
        } else if let featureRelationsIndex  {
            items.insert(.system(spacer), at: featureRelationsIndex + 1)
        } else if let openFileButton, items.count > 0 {
            items.insert(openFileButton, at: 1)
            items.insert(.system(spacer), at: 2)
        }
        
        return items
    }
    
    // temporary hack to display open button for files
    // remove after https://linear.app/anytype/issue/IOS-3806/%5Bepic%5D-release-x-or-ios-or-file-layout
    private func createOpenFileButtonIfNeeded() -> EditorItem? {
        guard let details = document.details else { return nil }
        guard details.layoutValue.isFileOrMedia else { return nil }
        
        let model = OpenFileBlockViewModel(
            info: .file(fileDetails: FileDetails(objectDetails: details)),
            handler: handler,
            documentId: document.objectId,
            spaceId: document.spaceId
        ) { [weak router] fileContext in
            router?.openImage(fileContext)
        }
        
        return EditorItem.block(model)
    }
    
    // temporary hack to hide block file for files
    // remove after https://linear.app/anytype/issue/IOS-3806/%5Bepic%5D-release-x-or-ios-or-file-layout
    private func removeBlockFileIfNeeded(_ items: [EditorItem]) -> [EditorItem] {
        guard let details = document.details else { return items }
        guard details.layoutValue.isFileOrMedia else { return items }
        
        let index = items.firstIndex { item in
            if case let .block(block) = item {
                return block.info.isFile
            }
            return false
        }
        
        guard let index else { return items }
        
        var items = items
        items.remove(at: index)
        return items
    }
    
    func buildShimeringItem() -> EditorItem {
        let shimmeringViewModel = ShimmeringBlockViewModel()
        
        return .system(shimmeringViewModel)
    }
    
    private func build(_ ids: [String]) -> [any BlockViewModelProtocol] {
        ids.compactMap {
            let block = build(blockId: $0)
            return block
        }
    }
    
    func build(blockId: String) -> (any BlockViewModelProtocol)? {
        if let model = modelsHolder.blocksMapping[blockId] {
            return model
        }
        
        guard let info = infoContainer.get(id: blockId) else {
            return nil
        }
        
        let documentId = document.objectId
        let spaceId = document.spaceId
        let blockInformationProvider = BlockModelInfomationProvider(document: document, info: info)
        
        switch info.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(
                    infoProvider: blockInformationProvider,
                    document: document,
                    becomeFirstResponder: { _ in },
                    handler: handler,
                    editorCollectionController: blockCollectionController,
                    showCodeSelection: { [weak self] info in
                        self?.output?.onSelectCodeLanguage(objectId: documentId, spaceId: spaceId, blockId: blockId)
                    }
                )
            default:
                let textBlockActionHandler = TextBlockActionHandler(
                    document: document,
                    info: info,
                    focusSubject: subjectsHolder.focusSubject(for: info.id),
                    showObject: { [weak self] objectId in
                        self?.router.showObject(objectId: objectId)
                    },
                    openURL: { [weak output] url in
                        output?.openUrl(url)
                    },
                    onShowStyleMenu: { [weak self] blockInformation in
                        Task { @MainActor [weak self] in
                            self?.editorPageBlocksStateManager.didSelectStyleSelection(infos: [blockInformation])
                        }
                    },
                    onEnterSelectionMode: { [weak self] blockInformation in
                        Task { @MainActor [weak self] in
                            self?.editorPageBlocksStateManager.didSelectEditingState(info: blockInformation)
                        }
                        
                    },
                    showTextIconPicker: { [weak router, weak document] in
                        guard let router, let document else { return }
                        router.showTextIconPicker(
                            contextId: document.objectId,
                            objectId: info.id
                        )
                    },
                    showWaitingView: { [weak router] text in
                        router?.showWaitingView(text: text)
                    },
                    hideWaitingView: {  [weak router] in
                        router?.hideWaitingView()
                    },
                    showURLBookmarkPopup: { [weak router] parameters in
                        router?.showLinkContextualMenu(inputParameters: parameters)
                    },
                    actionHandler: handler,
                    pasteboardService: pasteboardService,
                    markdownListener: markdownListener,
                    collectionController: blockCollectionController,
                    cursorManager: cursorManager,
                    accessoryViewStateManager: accessoryStateManager,
                    keyboardHandler: keyboardActionHandler,
                    markupChanger: markupChanger,
                    slashMenuActionHandler: slashMenuActionHandler,
                    openLinkToObject: { [weak self] data in
                        self?.output?.showLinkToObject(data: data)
                    }
                )
                let viewModel = TextBlockViewModel(
                    document: document,
                    blockInformationProvider: blockInformationProvider,
                    actionHandler: textBlockActionHandler,
                    cursorManager: cursorManager,
                    collectionController: blockCollectionController
                )
                
                textBlockActionHandler.viewModel = viewModel
                
                return viewModel
            }
        case let .file(content):
            switch content.contentType {
            case .file, .none:
                return BlockFileViewModel(
                    informationProvider: blockInformationProvider,
                    handler: handler,
                    documentId: documentId,
                    spaceId: spaceId,
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    onFileOpen: { [weak router] fileContext in
                        switch fileContext.previewItem.fileDetails.fileContentType {
                        case .video, .image:
                            router?.openImage(fileContext)
                        case .audio, .file:
                            router?.showObject(objectId: fileContext.previewItem.fileDetails.id)
                        case .none:
                            return
                        }
                    }
                )
            case .image:
                return BlockImageViewModel(
                    documentId: documentId,
                    spaceId: spaceId,
                    blockInformationProvider: blockInformationProvider,
                    handler: handler,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    },
                    onImageOpen: router.openImage
                )
            case .video:
                return VideoBlockViewModel(
                    informantionProvider: blockInformationProvider,
                    audioSessionService: audioSessionService,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    }
                )
            case .audio:
                return AudioBlockViewModel(
                    documentId: documentId,
                    spaceId: spaceId,
                    informationProvider: blockInformationProvider,
                    audioSessionService: audioSessionService,
                    showAudioPicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId, types: [.audio])
                    }
                )
            }
        case .divider:
            return DividerBlockViewModel(blockInformationProvider: blockInformationProvider)
        case let .bookmark(data):
            
            let details = document.detailsStorage.get(id: data.targetObjectID)
            
            if details?.isDeleted ?? false {
                return NonExistentBlockViewModel(info: info)
            }
            
            return BlockBookmarkViewModel(
                editorCollectionController: blockCollectionController,
                infoProvider: blockInformationProvider,
                document: document,
                showBookmarkBar: { [weak self] info in
                    self?.showBookmarkBar(info: info)
                },
                openUrl: { [weak self] url in
                    AnytypeAnalytics.instance().logBlockBookmarkOpenUrl()
                    self?.output?.openUrl(url.url)
                }
            )
        case .link:
            return BlockLinkViewModel(
                informationProvider: blockInformationProvider,
                document: document,
                blocksController: blockCollectionController,
                detailsService: detailsService,
                openLink: { [weak self] data in
                    self?.router.showEditorScreen(data: data)
                }
            )
        case .featuredRelations:
            return FeaturedRelationsBlockViewModel(
                infoProvider: blockInformationProvider,
                document: document,
                collectionController: blockCollectionController
            ) { [weak self] relation in
                guard let self = self else { return }
                
                if relation.key == BundledRelationKey.type.rawValue && document.permissions.canChangeType {
                    self.router.showTypes(
                        selectedObjectId: self.document.details?.type,
                        onSelect: { [weak self] type in
                            self?.typeSelected(type, route: .featuredRelations)
                        }
                    )
                } else {
                    self.router.showRelationValueEditingView(key: relation.key)
                }
            }
        case let .relation(content):
            let relation = document.parsedRelations.all.first {
                $0.key == content.key
            }
            
            guard let relation = relation else {
                return nil
            }
            
            return RelationBlockViewModel(
                blockInformationProvider: blockInformationProvider,
                relationProvider: RelationProvider(
                    relation: relation,
                    relationPublisher: document.parsedRelationsPublisher
                ),
                collectionController: blockCollectionController
            ) { [weak self] in
                self?.router.showRelationValueEditingView(key: relation.key)
            }
        case .tableOfContents:
            return TableOfContentsViewModel(
                info: info,
                document: document,
                onTap: { [weak self] blockId in
                    self?.blockCollectionController.scrollToTopBlock(blockId: blockId)
                },
                editorCollectionController: blockCollectionController
            )
        case .smartblock, .layout, .tableRow, .tableColumn, .widget,. chat: return nil
        case .table:
            return SimpleTableBlockViewModel(
                info: info,
                simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
                infoContainer: infoContainer,
                tableService: tableService,
                document: document,
                editorCollectionController: blockCollectionController,
                focusSubject: subjectsHolder.focusSubject(for: info.id)
            )
        case .dataView:
            return DataViewBlockViewModel(
                blockInformationProvider: BlockModelInfomationProvider(
                    document: document,
                    info: info
                ),
                document: document,
                reloadable: blockCollectionController,
                showFailureToast: { [weak self] message in
                    self?.output?.showFailureToast(message: message)
                },
                openSet: { [weak self] data in
                    self?.router.showEditorScreen(data: data)
                }
            )
        case .unsupported:
            guard let parentId = info.configurationData.parentId,
                  let parent = document.infoContainer.get(id: parentId),
                  parent.content.type != .layout(.header)
            else {
                return nil
            }
            
            return UnsupportedBlockViewModel(info: info)
        }
    }
    
    private func typeSelected(_ type: ObjectType, route: ChangeObjectTypeRoute? = nil) {
        Task { [weak self] in
            guard let self else { return }
            try await handler.setObjectType(type: type)
            AnytypeAnalytics.instance().logChangeObjectType(type.analyticsType, spaceId: document.spaceId, route: route)
            
            guard let isSelectTemplate = document.details?.isSelectTemplate, isSelectTemplate else { return }
            try await handler.applyTemplate(objectId: document.objectId, templateId: type.defaultTemplateId)
        }
    }
    // MARK: - Actions
    
    private var subscriptions = [AnyCancellable]()
    
    private func showMediaPicker(type: MediaPickerContentType, blockId: String) {
        router.showImagePicker(contentType: type) { [weak self] itemProvider in
            guard let itemProvider = itemProvider else { return }
            
            self?.handler.uploadMediaFile(
                uploadingSource: .itemProvider(itemProvider),
                type: type,
                blockId: blockId
            )
        }
    }
    
    private func showFilePicker(blockId: String, types: [UTType] = [.item]) {
        let model = AnytypePicker.ViewModel(types: types)
        model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] result in
            self?.handler.uploadFileAt(localPath: result.filePath, blockId: blockId)
        }.store(in: &subscriptions)
        
        router.showFilePicker(model: model)
    }
    
    private func showBookmarkBar(info: BlockInformation) {
        router.showBookmarkBar() { [weak self] url in
            Task { [weak self] in
                try await self?.handler.fetch(url: url, blockId: info.id)
            }
        }
    }
}
