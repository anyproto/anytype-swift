import Foundation
import BlocksModels
import Combine
import UniformTypeIdentifiers

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let handler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let pageService = PageService()
    private let modelsholder: BlockViewModelsHolder

    init(
        document: BaseDocumentProtocol,
        handler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate,
        modelsholder: BlockViewModelsHolder
    ) {
        self.document = document
        self.handler = handler
        self.router = router
        self.delegate = delegate
        self.modelsholder = modelsholder
    }

    func build(_ blocks: [BlockModelProtocol]) -> [BlockViewModelProtocol] {
        blocks.compactMap { block -> BlockViewModelProtocol? in
            let blockViewModel = build(block, previousBlock: nil)
            return blockViewModel
        }
    }

    func build(_ block: BlockModelProtocol, previousBlock: BlockModelProtocol?) -> BlockViewModelProtocol? {
        let viewModel: BlockViewModelProtocol?
        switch block.information.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                viewModel = CodeBlockViewModel(
                    block: block,
                    content: content,
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
                viewModel = TextBlockViewModel(
                    block: block,
                    upperBlock: nil,
                    content: content,
                    isCheckable: isCheckable,
                    blockDelegate: delegate,
                    actionHandler: handler,
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
                viewModel = BlockFileViewModel(
                    indentationLevel: block.indentationLevel,
                    information: block.information,
                    fileData: content,
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    downloadFile: { [weak self] fileId in
                        self?.saveFile(fileId: fileId, type: .file)
                    }
                )
            case .none:
                viewModel = UnknownLabelViewModel(information: block.information)
            case .image:
                viewModel = BlockImageViewModel(
                    information: block.information,
                    fileData: content,
                    indentationLevel: block.indentationLevel,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    },
                    onImageOpen: router.openImage
                )


            case .video:
                viewModel = VideoBlockViewModel(
                    indentationLevel: block.indentationLevel,
                    information: block.information,
                    fileData: content,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    },
                    downloadVideo: { [weak self] fileId in
                        self?.saveFile(fileId: fileId, type: .video)
                    }
                )
            case .audio:
                viewModel = AudioBlockViewModel(
                    indentationLevel: block.indentationLevel,
                    information: block.information,
                    fileData: content,
                    showAudioPicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId, types: [.audio])
                    },
                    downloadAudio: { [weak self] fileId in
                        self?.saveFile(fileId: fileId, type: .audio)
                    }
                )
            }
        case .divider(let content):
            viewModel = DividerBlockViewModel(
                content: content,
                information: block.information,
                indentationLevel: block.indentationLevel
            )
        case let .bookmark(data):
            viewModel = BlockBookmarkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.information,
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
            viewModel = BlockLinkViewModel(
                indentationLevel: block.indentationLevel,
                information: block.information,
                content: content,
                details: details,
                openLink: { [weak self] data in
                    self?.router.showPage(data: data)
                }
            )
        case .featuredRelations:
            guard let objectType = document.objectDetails?.objectType else { return nil }

            viewModel = FeaturedRelationsBlockViewModel(
                information: block.information,
                featuredRelation: document.parsedRelations.featuredRelationsForEditor(type: objectType, objectRestriction: document.objectRestrictions.objectRestriction),
                type: objectType.name
            ) { [weak self] relation in
                guard let self = self else { return }

                if relation.id == BundledRelationKey.type.rawValue {
                    self.router.showTypesSearch(
                        onSelect: { [weak self] id in
                            self?.handler.setObjectTypeUrl(id)
                        }
                    )
                } else {
                    self.router.showRelationValueEditingView(key: relation.id)
                }
            }
        case let .relation(content):
            let relation = document.parsedRelations.all.first {
                $0.id == content.key
            }

            guard let relation = relation else {
                return nil
            }

            viewModel = RelationBlockViewModel(
                information: block.information,
                indentationLevel: block.indentationLevel,
                relation: relation) { [weak self] relation in
                    self?.router.showRelationValueEditingView(key: relation.id)
                }

        case .smartblock, .layout, .dataView: return nil
        case .unsupported:
            guard block.parent?.information.content.type != .layout(.header) else {
                return nil
            }
            viewModel = UnsupportedBlockViewModel(information: block.information)
        }

        if let existingModel = modelsholder.modelsMapping[block.information.id],
            existingModel.hashable == viewModel?.hashable {
            return existingModel
        }

        return viewModel
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

    private func saveFile(fileId: FileId, type: FileContentType) {
        guard let url = UrlResolver.resolvedUrl(.file(id: fileId)) else { return }

        router.saveFile(fileURL: url, type: type)
    }

    private func showBookmarkBar(info: BlockInformation) {
        router.showBookmarkBar() { [weak self] url in
            guard let self = self else { return }

            self.handler.fetch(url: url, blockId: info.id)
        }
    }
}


