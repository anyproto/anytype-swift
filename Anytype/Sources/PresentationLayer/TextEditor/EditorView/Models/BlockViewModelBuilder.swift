import Foundation
import BlocksModels
import Combine

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let blockActionHandler: EditorActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let detailsLoader: DetailsLoader
    private let accessorySwitcher: AccessoryViewSwitcherProtocol

    init(
        document: BaseDocumentProtocol,
        blockActionHandler: EditorActionHandlerProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate,
        detailsLoader: DetailsLoader,
        accessorySwitcher: AccessoryViewSwitcherProtocol
    ) {
        self.document = document
        self.blockActionHandler = blockActionHandler
        self.router = router
        self.delegate = delegate
        self.contextualMenuHandler = DefaultContextualMenuHandler(
            handler: blockActionHandler,
            router: router
        )
        self.detailsLoader = detailsLoader
        self.accessorySwitcher = accessorySwitcher
    }

    func build(_ blocks: [BlockModelProtocol], details: DetailsData?) -> [BlockViewModelProtocol] {
        var previousBlock: BlockModelProtocol?
        return blocks.compactMap { block -> BlockViewModelProtocol? in
            let blockViewModel = build(block, details: details, previousBlock: previousBlock)
            previousBlock = block
            return blockViewModel
        }
    }

    func build(_ block: BlockModelProtocol, details: DetailsData?, previousBlock: BlockModelProtocol?) -> BlockViewModelProtocol? {
        switch block.information.content {
        case let .text(content):
            let anytypeText = AttributedTextConverter.asModel(
                text: content.text,
                marks: content.marks,
                style: content.contentType
            )
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(
                    block: block,
                    textData: anytypeText,
                    contextualMenuHandler: contextualMenuHandler,
                    becomeFirstResponder: { [weak self] model in
                        self?.delegate.becomeFirstResponder(for: model)
                    },
                    textDidChange: { block, textView in
                        self.blockActionHandler.handleAction(
                            .textView(action: .changeText(textView.attributedText), block: block),
                            blockId: block.information.id
                        )
                    },
                    showCodeSelection: { [weak self] block in
                        self?.router.showCodeLanguageView(languages: CodeLanguage.allCases) { language in
                            guard let contextId = block.container?.rootId else { return }
                            let fields = BlockFields(
                                blockId: block.information.id,
                                fields: [FieldName.codeLanguage: language.toMiddleware()]
                            )
                            self?.blockActionHandler.handleAction(
                                .setFields(contextID: contextId, fields: [fields]),
                                blockId: block.information.id
                            )
                        }
                    }
                )
            default:
                let isCheckable = content.contentType == .title ? details?.layout == .todo : false
                return TextBlockViewModel(
                    block: block,
                    text: anytypeText,
                    upperBlock: previousBlock,
                    content: content,
                    isCheckable: isCheckable,
                    contextualMenuHandler: contextualMenuHandler,
                    blockDelegate: delegate,
                    actionHandler: blockActionHandler,
                    accessorySwitcher: accessorySwitcher,
                    showPage: { [weak self] pageId in
                        self?.router.showPage(with: pageId)
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
                return BlockImageViewModel(
                    information: block.information,
                    fileData: content,
                    indentationLevel: block.indentationLevel,
                    contextualMenuHandler: contextualMenuHandler,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    }
                )
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
                        self?.showMediaPicker(type: .audio, blockId: blockId)
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
            let details = detailsLoader.loadDetailsForBlockLink(
                blockId: block.information.id,
                targetBlockId: content.targetBlockID
            )
            return BlockLinkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.information,
                content: content,
                details: details,
                contextualMenuHandler: contextualMenuHandler,
                openLink: { [weak self] blockId in
                    self?.router.showPage(with: blockId)
                }
            )
        case .smartblock, .layout: return nil
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
        let model = MediaPickerViewModel(type: type) { [weak self] resultInformation in
            guard let resultInformation = resultInformation else { return }

            self?.blockActionHandler.upload(
                blockId: .provided(blockId),
                filePath: resultInformation.filePath
            )
        }
        
        router.showImagePicker(model: model)
    }
    
    private func showFilePicker(blockId: BlockId) {
        let model = Picker.ViewModel()
        model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] result in
            self?.blockActionHandler.upload(
                blockId: .provided(blockId),
                filePath: result.filePath
            )
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
            
            self.blockActionHandler.handleAction(
                .fetch(url: url),
                blockId: info.id
            )
        }
    }
}
