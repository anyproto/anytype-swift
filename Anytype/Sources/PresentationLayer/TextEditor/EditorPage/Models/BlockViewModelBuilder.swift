import Foundation
import BlocksModels
import Combine
import UniformTypeIdentifiers

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let handler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let pageService = PageService()

    init(
        document: BaseDocumentProtocol,
        handler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate
    ) {
        self.document = document
        self.handler = handler
        self.router = router
        self.delegate = delegate
        self.contextualMenuHandler = DefaultContextualMenuHandler(
            handler: handler,
            router: router
        )
    }

    func build(_ blocks: [BlockModelProtocol]) -> [BlockViewModelProtocol] {
        var previousBlock: BlockModelProtocol?
        return blocks.compactMap { block -> BlockViewModelProtocol? in
            let blockViewModel = build(block, previousBlock: previousBlock)
            previousBlock = block
            return blockViewModel
        }
    }

    func build(_ block: BlockModelProtocol, previousBlock: BlockModelProtocol?) -> BlockViewModelProtocol? {
        switch block.information.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(
                    block: block,
                    content: content,
                    detailsStorage: document.detailsStorage,
                    contextualMenuHandler: contextualMenuHandler,
                    becomeFirstResponder: { [weak self] model in
                        self?.delegate.becomeFirstResponder(blockId: model.information.id)
                    },
                    textDidChange: { block, textView in
                        self.handler.changeText(textView.attributedText, info: block.information)
                    },
                    showCodeSelection: { [weak self] block in
                        self?.router.showCodeLanguageView(languages: CodeLanguage.allCases) { language in
                            let fields = BlockFields(
                                blockId: block.information.id,
                                fields: [FieldName.codeLanguage: language.toMiddleware()]
                            )
                            self?.handler.setFields([fields], blockId: block.information.id)
                        }
                    }
                )
            default:
                let isCheckable = content.contentType == .title ? document.objectDetails?.layout == .todo : false
                return TextBlockViewModel(
                    block: block,
                    upperBlock: previousBlock,
                    content: content,
                    isCheckable: isCheckable,
                    contextualMenuHandler: contextualMenuHandler,
                    blockDelegate: delegate,
                    actionHandler: handler,
                    detailsStorage: document.detailsStorage,
                    showPage: { [weak self] data in
                        self?.router.showPage(data: data)
                    },
                    openURL: { [weak self] url in
                        self?.router.openUrl(url)
                    }
                )
            }
        case let .file(content):
            switch content.contentType {
            case .file:
                return BlockFileViewModel(
                    indentationLevel: block.indentationLevel,
                    information: block.information,
                    fileData: content,
                    contextualMenuHandler: contextualMenuHandler,
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    downloadFile: { [weak self] fileId in
                        self?.saveFile(fileId: fileId)
                    }
                )
            case .none:
                return UnknownLabelViewModel(information: block.information)
            case .image:
                let viewModel = BlockImageViewModel(
                    information: block.information,
                    fileData: content,
                    indentationLevel: block.indentationLevel,
                    contextualMenuHandler: contextualMenuHandler,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    }
                )

                viewModel?.onImageOpen = router.openImage

                return viewModel
            case .video:
                return VideoBlockViewModel(
                    indentationLevel: block.indentationLevel,
                    information: block.information,
                    fileData: content,
                    contextualMenuHandler: contextualMenuHandler,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    },
                    downloadVideo: { [weak self] fileId in
                        self?.saveFile(fileId: fileId)
                    }
                )
            case .audio:
                return AudioBlockViewModel(
                    indentationLevel: block.indentationLevel,
                    information: block.information,
                    fileData: content,
                    contextualMenuHandler: contextualMenuHandler,
                    showAudioPicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId, types: [.audio])
                    },
                    downloadAudio: { [weak self] fileId in
                        self?.saveFile(fileId: fileId)
                    }
                )
            }
        case .divider(let content):
            return DividerBlockViewModel(
                content: content,
                information: block.information,
                indentationLevel: block.indentationLevel,
                handler: contextualMenuHandler
            )
        case let .bookmark(data):
            return BlockBookmarkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.information,
                bookmarkData: data,
                handleContextualMenu: { [weak self] action, info in
                    self?.contextualMenuHandler.handle(action: action, info: info)
                },
                showBookmarkBar: { [weak self] info in
                    self?.showBookmarkBar(info: info)
                },
                openUrl: { [weak self] url in
                    self?.router.openUrl(url)
                }
            )
        case let .link(content):
            let details = document.detailsStorage.get(id: content.targetBlockID)
            return BlockLinkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.information,
                content: content,
                details: details,
                contextualMenuHandler: contextualMenuHandler,
                openLink: { [weak self] data in
                    self?.router.showPage(data: data)
                }
            )
        case .featuredRelations:
            guard let objectType = document.objectDetails?.objectType else { return nil }
            
            return FeaturedRelationsBlockViewModel(
                information: block.information,
                featuredRelation: document.parsedRelations.featuredRelations,
                type: objectType.name
            ) { [weak self] _ in
                guard let self = self else { return }
                
                guard
                    !self.document.objectRestrictions.objectRestriction.contains(.typechange)
                else {
                    return
                }
                
                self.router.showTypesSearch(
                    onSelect: { [weak self] id in
                        self?.handler.setObjectTypeUrl(id)
                    }
                )
            }
            
        case .smartblock, .layout, .dataView: return nil
        case .unsupported:
            guard block.parent?.information.content.type != .layout(.header) else {
                return nil
            }
            return UnsupportedBlockViewModel(information: block.information)
        }
    }
    
    // MARK: - Actions
    
    private var subscriptions = [AnyCancellable]()
    
    private func showMediaPicker(type: MediaPickerContentType, blockId: BlockId) {
        let model = MediaPickerViewModel(type: type) { [weak self] itemProvider in
            guard let itemProvider = itemProvider else { return }

            self?.handler.uploadMediaFile(
                itemProvider: itemProvider,
                type: type,
                blockId: blockId
            )
        }
        
        router.showImagePicker(model: model)
    }
    
    private func showFilePicker(blockId: BlockId, types: [UTType] = [.item]) {
        let model = Picker.ViewModel(types: types)
        model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] result in
            self?.handler.uploadFileAt(localPath: result.filePath, blockId: blockId)
        }.store(in: &subscriptions)
            
        router.showFilePicker(model: model)
    }
    
    private func saveFile(fileId: FileId) {
        guard let url = UrlResolver.resolvedUrl(.file(id: fileId)) else { return }
        
        router.saveFile(fileURL: url)
    }
    
    private func showBookmarkBar(info: BlockInformation) {
        router.showBookmarkBar() { [weak self] url in
            guard let self = self else { return }
            
            self.handler.fetch(url: url, blockId: info.id)
        }
    }
}
