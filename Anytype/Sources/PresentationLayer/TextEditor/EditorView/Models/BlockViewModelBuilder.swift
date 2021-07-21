import Foundation
import BlocksModels
import Combine

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let blockActionHandler: EditorActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let mentionsConfigurator: MentionsTextViewConfigurator

    init(
        document: BaseDocumentProtocol,
        blockActionHandler: EditorActionHandlerProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate,
        mentionsConfigurator: MentionsTextViewConfigurator
    ) {
        self.document = document
        self.blockActionHandler = blockActionHandler
        self.router = router
        self.delegate = delegate
        self.contextualMenuHandler = DefaultContextualMenuHandler(
            handler: blockActionHandler,
            router: router
        )
        self.mentionsConfigurator = mentionsConfigurator
    }

    func build(_ blocks: [BlockActiveRecordProtocol], details: DetailsData?) -> [BlockViewModelProtocol] {
        blocks.compactMap { build($0, details: details) }
    }

    func build(_ block: BlockActiveRecordProtocol, details: DetailsData?) -> BlockViewModelProtocol? {
        switch block.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(
                    block: block,
                    textData: content,
                    contextualMenuHandler: contextualMenuHandler,
                    becomeFirstResponder: { [weak self] model in
                        self?.delegate.becomeFirstResponder(for: model)
                    },
                    textDidChange: { block, textView in
                        self.blockActionHandler.handleAction(
                            .textView(action: .changeTextForStruct(textView.attributedText), activeRecord: block),
                            info: block.blockModel.information
                        )
                    },
                    showCodeSelection: { [weak self] block in
                        self?.router.showCodeLanguageView(languages: CodeLanguage.allCases) { language in
                            guard let contextId = block.container?.rootId else { return }
                            let fields = BlockFields(
                                blockId: block.blockId,
                                fields: [FieldName.codeLanguage: language.toMiddleware()]
                            )
                            self?.blockActionHandler.handleAction(
                                .setFields(contextID: contextId, fields: [fields]), info: block.blockModel.information
                            )
                        }
                    }
                )
            case .title:
                return TextBlockViewModel(
                    block: block,
                    isCheckable: details?.layout == .todo,
                    contextualMenuHandler: contextualMenuHandler,
                    blockDelegate: delegate,
                    actionHandler: blockActionHandler
                ) { [weak self] textView in
                    self?.mentionsConfigurator.configure(textView: textView)
                } showStyleMenu: { [weak self] information in
                    self?.router.showStyleMenu(information: information)
                }
            default:
                return TextBlockViewModel(
                    block: block,
                    isCheckable: false,
                    contextualMenuHandler: contextualMenuHandler,
                    blockDelegate: delegate,
                    actionHandler: blockActionHandler
                ) { [weak self] textView in
                    self?.mentionsConfigurator.configure(textView: textView)
                } showStyleMenu: { [weak self] information in
                    self?.router.showStyleMenu(information: information)
                }
            }
        case let .file(content):
            switch content.contentType {
            case .file:
                return BlockFileViewModel(
                    information: block.blockModel.information,
                    fileData: content,
                    indentationLevel: block.indentationLevel,
                    contextualMenuHandler: contextualMenuHandler,
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    downloadFile: { [weak self] fileId in
                        self?.saveFile(fileId: fileId)
                    }
                )
            case .none:
                return UnknownLabelViewModel(information: block.blockModel.information)
            case .image:
                return BlockImageViewModel(
                    information: block.blockModel.information,
                    fileData: content,
                    indentationLevel: block.indentationLevel,
                    contextualMenuHandler: contextualMenuHandler,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    }
                )
            case .video:
                return VideoBlockViewModel(
                    information: block.blockModel.information,
                    fileData: content,
                    indentationLevel: block.indentationLevel,
                    contextualMenuHandler: contextualMenuHandler,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    },
                    downloadVideo: { [weak self] fileId in
                        self?.saveFile(fileId: fileId)
                    }
                )
            }
        case .divider(let content):
            return DividerBlockViewModel(
                content: content,
                information: block.blockModel.information,
                indentationLevel: block.indentationLevel,
                handler: contextualMenuHandler
            )
        case let .bookmark(data):
            return BlockBookmarkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.blockModel.information,
                bookmarkData: data,
                contextualMenuHandler: contextualMenuHandler,
                showBookmarkBar: { [weak self] info in
                    self?.showBookmarkBar(info: info)
                },
                openUrl: { [weak self] url in
                    self?.router.openUrl(url)
                }
            )
        case let .link(content):
            let details = document.getDetails(by: content.targetBlockID)?.currentDetails
            // TODO: - use DetailsActiveModel()
            return BlockPageLinkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.blockModel.information,
                content: content,
                details: details,
                contextualMenuHandler: contextualMenuHandler,
                openLink: { [weak self] blockId in
                    self?.router.showPage(with: blockId)
                }
            )
        case .smartblock, .layout: return nil
        }
    }
    
    // MARK: - Actions
    
    private var subscriptions = [AnyCancellable]()
    
    private func showMediaPicker(type: MediaPickerContentType, blockId: BlockId) {
        let model = MediaPickerViewModel(type: type) { [weak self] resultInformation in
            guard let resultInformation = resultInformation else { return }

            self?.blockActionHandler.upload(blockId: blockId, filePath: resultInformation.filePath)
        }
        
        router.showImagePicker(model: model)
    }
    
    private func showFilePicker(blockId: BlockId) {
        let model = CommonViews.Pickers.File.Picker.ViewModel()
        model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] result in
            self?.blockActionHandler.upload(blockId: blockId, filePath: result.filePath)
        }.store(in: &subscriptions)
            
        router.showFilePicker(model: model)
    }
    
    private func saveFile(fileId: FileId) {
        guard let url = NewUrlResolver.resolvedUrl(.file(id: fileId)) else { return }
        
        router.saveFile(fileURL: url)
    }
    
    private func showBookmarkBar(info: BlockInformation) {
        router.showBookmarkBar() { [weak self] url in
            guard let self = self else { return }
            
            self.blockActionHandler.handleAction(
                .fetch(url: url), info: info
            )
        }
    }
}
