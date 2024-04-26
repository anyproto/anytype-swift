import Foundation
import Services
import Combine
import UniformTypeIdentifiers
import AnytypeCore

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let subjectsHolder: FocusSubjectsHolder
    private let markdownListener: MarkdownListener
    private let simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder
    private let detailsService: DetailsServiceProtocol
    private let audioSessionService: AudioSessionServiceProtocol
    private let infoContainer: InfoContainerProtocol
    private let tableService: BlockTableServiceProtocol

    init(
        document: BaseDocumentProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate,
        markdownListener: MarkdownListener,
        simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder,
        subjectsHolder: FocusSubjectsHolder,
        detailsService: DetailsServiceProtocol,
        audioSessionService: AudioSessionServiceProtocol,
        infoContainer: InfoContainerProtocol,
        tableService: BlockTableServiceProtocol
    ) {
        self.document = document
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.router = router
        self.delegate = delegate
        self.markdownListener = markdownListener
        self.simpleTableDependenciesBuilder = simpleTableDependenciesBuilder
        self.subjectsHolder = subjectsHolder
        self.detailsService = detailsService
        self.audioSessionService = audioSessionService
        self.infoContainer = infoContainer
        self.tableService = tableService
    }

    func buildEditorItems(infos: [BlockInformation]) -> [EditorItem] {
        let blockViewModels = build(infos)
        var editorItems = blockViewModels.map (EditorItem.block)

        let featureRelationsIndex = blockViewModels.firstIndex { $0.content == .featuredRelations }

        if let featureRelationsIndex = featureRelationsIndex {
            let spacer = SpacerBlockViewModel(usage: .firstRowOffset)
            editorItems.insert(.system(spacer), at: featureRelationsIndex + 1)
        }

        return editorItems
    }

    func buildShimeringItem() -> EditorItem {
        let shimmeringViewModel = ShimmeringBlockViewModel()

        return .system(shimmeringViewModel)
    }

    private func build(_ infos: [BlockInformation]) -> [BlockViewModelProtocol] {
        infos.compactMap(build(info:))
    }

    func build(info: BlockInformation) -> BlockViewModelProtocol? {
        switch info.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                let codeLanguage = CodeLanguage.create(
                    middleware: info.fields[CodeBlockFields.FieldName.codeLanguage]?.stringValue
                )
                return CodeBlockViewModel(
                    info: info,
                    content: content,
                    anytypeText: content.anytypeText(document: document),
                    codeLanguage: codeLanguage,
                    becomeFirstResponder: { _ in },
                    textDidChange: { [weak self] block, textView in
                        self?.handler.changeText(textView.attributedText, info: info)
                        self?.delegate.textBlockSetNeedsLayout()
                    },
                    showCodeSelection: { [weak self] info in
                        self?.router.showCodeLanguage(blockId: info.id, selectedLanguage: codeLanguage)
                    }
                )
            default:
                let isCheckable = content.contentType == .title ? document.details?.layoutValue == .todo : false
                let anytypeText = content.anytypeText(document: document)
                
                let textBlockActionHandler = TextBlockActionHandler(
                    info: info,
                    showPage: { [weak self] objectId in
                        self?.router.showPage(objectId: objectId)
                    },
                    openURL: { [weak router] url in
                        router?.openUrl(url)
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
                    content: content,
                    anytypeText: anytypeText,
                    showURLBookmarkPopup: { [weak router] parameters in
                        router?.showLinkContextualMenu(inputParameters: parameters)
                    },
                    actionHandler: handler,
                    pasteboardService: pasteboardService,
                    markdownListener: markdownListener,
                    blockDelegate: delegate
                )

                return TextBlockViewModel(
                    info: info,
                    content: content,
                    anytypeText: anytypeText,
                    isCheckable: isCheckable,
                    focusSubject: subjectsHolder.focusSubject(for: info.id),
                    actionHandler: textBlockActionHandler
                )
            }
        case let .file(content):
            switch content.contentType {
            case .file, .none:
                return BlockFileViewModel(
                    info: info,
                    fileData: content,
                    handler: handler,
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    onFileOpen: { [weak router] fileContext in
                        router?.openImage(fileContext)
                    }
                )
            case .image:
                return BlockImageViewModel(
                    info: info,
                    fileData: content,
                    handler: handler,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    },
                    onImageOpen: router.openImage
                )


            case .video:
                return VideoBlockViewModel(
                    info: info,
                    fileData: content,
                    audioSessionService: audioSessionService,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    }
                )
            case .audio:
                return AudioBlockViewModel(
                    info: info,
                    fileData: content,
                    audioSessionService: audioSessionService,
                    showAudioPicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId, types: [.audio])
                    }
                )
            }
        case .divider(let content):
            return DividerBlockViewModel(content: content, info: info)
        case let .bookmark(data):
            
            let details = document.detailsStorage.get(id: data.targetObjectID)
            
            if details?.isDeleted ?? false {
                return NonExistentBlockViewModel(info: info)
            }
            
            return BlockBookmarkViewModel(
                info: info,
                bookmarkData: data,
                objectDetails: details,
                showBookmarkBar: { [weak self] info in
                    self?.showBookmarkBar(info: info)
                },
                openUrl: { [weak self] url in
                    AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockBookmarkOpenUrl)
                    self?.router.openUrl(url.url)
                }
            )
        case let .link(content):
            guard let details = document.detailsStorage.get(id: content.targetBlockID) else {
                anytypeAssertionFailure(
                    "Couldn't find details for block link", info: ["targetBlockID": content.targetBlockID]
                )
                return nil
            }

            return BlockLinkViewModel(
                info: info,
                content: content,
                details: details,
                detailsService: detailsService,
                openLink: { [weak self] data in
                    self?.router.showPage(data: data)
                }
            )
        case .featuredRelations:
            guard let objectType = document.details?.objectType else { return nil }
            
            let featuredRelationValues = document.featuredRelationsForEditor
            return FeaturedRelationsBlockViewModel(
                info: info,
                featuredRelationValues: featuredRelationValues,
                type: objectType.name,
                blockDelegate: delegate
            ) { [weak self] relation in
                guard let self = self else { return }

                let allowTypeChange = !self.document.objectRestrictions.objectRestriction.contains(.typechange)
                
                if relation.key == BundledRelationKey.type.rawValue && 
                    !self.document.isLocked && allowTypeChange {
                    self.router.showTypes(
                        selectedObjectId: self.document.details?.type,
                        onSelect: { [weak self] type in
                            self?.typeSelected(type)
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
                info: info,
                relation: relation
            ) { [weak self] in
                self?.router.showRelationValueEditingView(key: relation.key)
            }
        case .tableOfContents:
            return TableOfContentsViewModel(
                info: info,
                document: document,
                onTap: { [weak self] blockId in
                    self?.delegate.scrollToBlock(blockId: blockId)
                },
                blockSetNeedsLayout: { [weak self] in
                    self?.delegate.textBlockSetNeedsLayout()
                }
            )
        case .smartblock, .layout, .tableRow, .tableColumn, .widget: return nil
        case .table:
            return SimpleTableBlockViewModel(
                info: info,
                simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
                infoContainer: infoContainer,
                tableService: tableService,
                document: document,
                focusSubject: subjectsHolder.focusSubject(for: info.id)
            )
        case let .dataView(data):
            let details = document.detailsStorage.get(id: data.targetObjectID)
            
            if details?.isDeleted ?? false {
                return NonExistentBlockViewModel(info: info)
            }
            return DataViewBlockViewModel(
                info: info,
                objectDetails: details,
                isCollection: data.isCollection,
                showFailureToast: { [weak self] message in
                    self?.router.showFailureToast(message: message)
                },
                openSet: { [weak self] data in
                    self?.router.showPage(data: data)
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
    
    private func typeSelected(_ type: ObjectType) {
        Task { [weak self] in
            guard let self else { return }
            try await handler.setObjectType(type: type)
            AnytypeAnalytics.instance().logObjectTypeChange(type.analyticsType)
            
            guard let isSelectTemplate = document.details?.isSelectTemplate, isSelectTemplate else { return }
            try await handler.applyTemplate(objectId: document.objectId, templateId: type.defaultTemplateId)
        }
    }

    // MARK: - Actions

    private var subscriptions = [AnyCancellable]()

    private func showMediaPicker(type: MediaPickerContentType, blockId: BlockId) {
        router.showImagePicker(contentType: type) { [weak self] itemProvider in
            guard let itemProvider = itemProvider else { return }

            self?.handler.uploadMediaFile(
                uploadingSource: .itemProvider(itemProvider),
                type: type,
                blockId: blockId
            )
        }
    }

    private func showFilePicker(blockId: BlockId, types: [UTType] = [.item]) {
        let model = Picker.ViewModel(types: types)
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
