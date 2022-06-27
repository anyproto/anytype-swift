import Foundation
import BlocksModels
import Combine
import UniformTypeIdentifiers

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let pageService = PageService()
    private let subjectsHolder = FocusSubjectsHolder()
    private let markdownListener: MarkdownListener
    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        document: BaseDocumentProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate,
        markdownListener: MarkdownListener,
        relativePositionProvider: RelativePositionProvider?
    ) {
        self.document = document
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.router = router
        self.delegate = delegate
        self.markdownListener = markdownListener
        self.relativePositionProvider = relativePositionProvider
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

    private func build(_ infos: [BlockInformation]) -> [BlockViewModelProtocol] {
        infos.compactMap(build(info:))
    }

    func build(info: BlockInformation) -> BlockViewModelProtocol? {
        switch info.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(
                    info: info,
                    content: content,
                    codeLanguage: CodeLanguage.create(
                        middleware: info.fields[CodeBlockFields.FieldName.codeLanguage]?.stringValue
                    ),
                    becomeFirstResponder: { _ in },
                    textDidChange: { block, textView in
                        self.handler.changeText(textView.attributedText, info: info)
                    },
                    showCodeSelection: { [weak self] info in
                        self?.router.showCodeLanguageView(languages: CodeLanguage.allCases) { language in
                            let fields = CodeBlockFields(language: language)
                            self?.handler.setFields(fields, blockId: info.id)
                        }
                    }
                )
            default:
                let isCheckable = content.contentType == .title ? document.details?.layout == .todo : false

                let textBlockActionHandler = TextBlockActionHandler(
                    info: info,
                    showPage: { [weak self] data in
                        self?.router.showPage(data: data)
                    },
                    openURL: { [weak router] url in
                        router?.openUrl(url)
                    },
                    showTextIconPicker: { [unowned router, unowned document] in
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
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    downloadFile: { [weak router] fileMetadata in
                        guard let url = fileMetadata.contentUrl else { return }
                        router?.saveFile(fileURL: url, type: .file)
                    }
                )
            case .image:
                return BlockImageViewModel(
                    info: info,
                    fileData: content,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    },
                    onImageOpen: router.openImage
                )


            case .video:
                return VideoBlockViewModel(
                    info: info,
                    fileData: content,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    }
                )
            case .audio:
                return AudioBlockViewModel(
                    info: info,
                    fileData: content,
                    showAudioPicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId, types: [.audio])
                    }
                )
            }
        case .divider(let content):
            return DividerBlockViewModel(content: content, info: info)
        case let .bookmark(data):
            return BlockBookmarkViewModel(
                info: info,
                bookmarkData: data,
                showBookmarkBar: { [weak self] info in
                    self?.showBookmarkBar(info: info)
                },
                openUrl: { [weak self] url in
                    self?.router.openUrl(url)
                }
            )
        case let .link(content):            
            let details = ObjectDetailsStorage.shared.get(id: content.targetBlockID)
            return BlockLinkViewModel(
                info: info,
                content: content,
                details: details,
                openLink: { [weak self] data in
                    self?.router.showPage(data: data)
                }
            )
        case .featuredRelations:
            guard let objectType = document.details?.objectType else { return nil }
            
            let featuredRelation = document.featuredRelationsForEditor
            return FeaturedRelationsBlockViewModel(
                info: info,
                featuredRelation: featuredRelation,
                type: objectType.name,
                blockDelegate: delegate
            ) { [weak self] relation in
                guard let self = self else { return }

                if relation.id == BundledRelationKey.type.rawValue {
                    self.router.showTypesSearch(
                        onSelect: { [weak self] id in
                            self?.handler.setObjectTypeUrl(id)
                        }
                    )
                } else {
                    AnytypeAnalytics.instance().logChangeRelationValue(type: .block)
                    self.router.showRelationValueEditingView(key: relation.id, source: .object)
                }
            }
        case let .relation(content):
            let relation = document.parsedRelations.all.first {
                $0.id == content.key
            }

            guard let relation = relation else {
                return nil
            }

            return RelationBlockViewModel(
                info: info,
                relation: relation
            ) { [weak self] in
                AnytypeAnalytics.instance().logChangeRelationValue(type: .block)
                self?.router.showRelationValueEditingView(key: relation.id, source: .object)
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
        case .smartblock, .layout, .dataView: return nil
        case .unsupported:
            guard let parentId = info.configurationData.parentId,
                  let parent = document.infoContainer.get(id: parentId),
                  parent.content.type != .layout(.header)
            else {
                return nil
            }
            
            return  UnsupportedBlockViewModel(info: info)
        }
    }

    // MARK: - Actions

    private var subscriptions = [AnyCancellable]()

    private func showMediaPicker(type: MediaPickerContentType, blockId: BlockId) {
        router.showImagePicker(contentType: type) { [weak self] itemProvider in
            guard let itemProvider = itemProvider else { return }

            self?.handler.uploadMediaFile(
                itemProvider: itemProvider,
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
            guard let self = self else { return }

            self.handler.fetch(url: url, blockId: info.id)
        }
    }
}


