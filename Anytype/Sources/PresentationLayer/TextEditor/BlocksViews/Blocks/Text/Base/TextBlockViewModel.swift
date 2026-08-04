import Combine
import UIKit
import Services

// TODO: Delete it. Use document subscription in blocks
final class BlockModelInfomationProvider: @unchecked Sendable {
    @Published private(set) var info: BlockInformation
    
    private let document: any BaseDocumentProtocol
    private var subscription: AnyCancellable?
    
    init(
        document: some BaseDocumentProtocol,
        info: BlockInformation
    ) {
        self.document = document
        self.info = info
        
        setupPublisher()
    }
    
    private func setupPublisher() {
        subscription = document.subscribeForBlockInfo(blockId: info.id)
            .sinkOnMain { [weak self] in self?.info = $0 }
    }

    /// Points this provider at the block that replaced `info.id` in place (empty-block
    /// identity fork, placeholder materialization). The old subscription targets a deleted
    /// id and would never fire again.
    func rebind(to info: BlockInformation) {
        self.info = info
        setupPublisher()
    }
}

@MainActor
final class TextBlockViewModel: BlockViewModelProtocol {
    enum Style {
        case none
        case todo
    }
    
    nonisolated var info: BlockInformation { blockInformationProvider.info }
    private let blockInformationProvider: BlockModelInfomationProvider
    private var document: any BaseDocumentProtocol
    private var style: Style = .none
    
    private var content: BlockText = .empty(contentType: .text)
    private var anytypeText: UIKitAnytypeText?
    
    private let actionHandler: any TextBlockActionHandlerProtocol
    private var customBackgroundColor: UIColor?
    private var cursorManager: EditorCursorManager
    
    let className = "TextBlockViewModel"
    // The row this model renders into, fixed for the model's lifetime: the block id it was
    // built for, resolved through fork/materialization aliases (BlockRowIdentityMap). Kept
    // stable across rebind(to:) so the diffable identifier — and with it the live cell and
    // its keyboard input session — survives the in-place id swap.
    nonisolated let rowIdentity: String

    nonisolated var hashable: AnyHashable { className + rowIdentity }

    private var cancellables = [AnyCancellable]()


    init(
        document: some BaseDocumentProtocol,
        blockInformationProvider: BlockModelInfomationProvider,
        actionHandler: some TextBlockActionHandlerProtocol,
        cursorManager: EditorCursorManager,
        rowIdentity: String,
        customBackgroundColor: UIColor? = nil,
        collectionController: EditorBlockCollectionController? = nil
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.document = document
        self.actionHandler = actionHandler
        self.cursorManager = cursorManager
        self.rowIdentity = rowIdentity
        self.customBackgroundColor = customBackgroundColor
        
        document.detailsPublisher.receiveOnMain().sink { [weak self] objectDetails in
            guard let self, let collectionController else { return }
            let newStyle = styleFromDetails(objectDetails: objectDetails)
            if style != newStyle {
                style = newStyle
                collectionController.reconfigure(items: [.block(self)])
            }
        }.store(in: &cancellables)
    }
        
    func set(focus: BlockFocusPosition) {
        actionHandler.focusSubject.send(focus)
    }

    /// Rebinds this row to the block that replaced its current one in place. The instance —
    /// and with it the diffable identifier (`rowIdentity`) and the live cell wired to its
    /// action handler — stays; only the backing block changes. The handler rebinds its own
    /// `info` when its fork/materialization task completes.
    func rebind(to info: BlockInformation) {
        blockInformationProvider.rebind(to: info)
    }

    /// Inverse of `rebind(to:)` for undo: the replaced block was restored and this row must
    /// carry it again. The handler's completed fork points at the now-deleted id and is reset
    /// so a later first fill forks fresh instead of rebinding edits to that id.
    func rebindAfterIdentityUndo(to info: BlockInformation) {
        blockInformationProvider.rebind(to: info)
        actionHandler.resetEmptyBlockFork()
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
    
    func textBlockContentConfiguration(
        attributedString: NSAttributedString? = nil
    ) -> TextBlockContentConfiguration {
        guard let info = document.infoContainer.get(id: blockInformationProvider.info.id),
              case let .text(content) = info.content else {
            return .empty
        }
        
        actionHandler.info = info

        
        let isCheckable = content.contentType == .title ? style == .todo : false
        let anytypeText = content.anytypeText(document: document)
        self.anytypeText = anytypeText
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: anytypeText.anytypeFont.uiKitFont,
            .foregroundColor: UIColor.Text.tertiary,
        ]
        
        var position: BlockFocusPosition?
        if cursorManager.blockFocus?.id == info.id {
            position = cursorManager.blockFocus?.position
            cursorManager.blockFocus = nil
        }
        
        let contentConfiguration = TextBlockContentConfiguration(
            blockId: info.id,
            content: content,
            attributedString: (attributedString ?? anytypeText.attrString),
            placeholderAttributes: attributes,
            typingAttributes: { [weak self] cursorPosition in
                self?.anytypeText?.typingAttributes(for: cursorPosition) ?? [:]
            },
            textContainerInsets: .init(
                top: anytypeText.verticalSpacing,
                left: 0,
                bottom: anytypeText.verticalSpacing,
                right: 0
            ),
            alignment: blockAlignment(blockText: content, info: info).asNSTextAlignment,
            isCheckable: isCheckable,
            isToggled: info.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: info.isToggled && info.childrenIds.isEmpty, 
            initialBlockFocusPosition: position,
            focusPublisher: actionHandler.focusSubject.eraseToAnyPublisher(),
            resetPublisher: actionHandler.resetSubject
                .map { [weak self] attributedString in
                    self?.textBlockContentConfiguration(attributedString: attributedString)
                }
                .eraseToAnyPublisher(),
            actions: actionHandler.textBlockActions()
        )

        return contentConfiguration
    }
    
    private func blockAlignment(blockText: BlockText, info: BlockInformation) -> LayoutAlignment {
        if blockText.contentType == .title, let details = document.details {
            return details.objectAlignValue // we use alignment from type for title
        } else {
            return info.horizontalAlignment
        }
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> any UIContentConfiguration {
        let contentConfiguration = textBlockContentConfiguration()
        
        let isDragConfigurationAvailable =
        content.contentType != .description && content.contentType != .title
        
        let backgroundColor = info.backgroundColor?.backgroundColor.color
                                ?? contentConfiguration.content.defaultBackgroundColor
        
        let info = blockInformationProvider.info
        return contentConfiguration.cellBlockConfiguration(
            dragConfiguration: isDragConfigurationAvailable ? .init(id: info.id) : nil,
            styleConfiguration: CellStyleConfiguration(backgroundColor: backgroundColor)
        )
    }
    
    func makeSpreadsheetConfiguration() -> any UIContentConfiguration {
        let info = blockInformationProvider.info
        
        let color: UIColor = info.configurationData.backgroundColor.map { UIColor.VeryLight.uiColor(from: $0) }
        ?? customBackgroundColor
        ?? .Background.primary
        
        return textBlockContentConfiguration()
            .spreadsheetConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: color)
            )
    }
    
    private func styleFromDetails(objectDetails: ObjectDetails?) -> Style {
        guard let objectDetails else { return .none }
        return objectDetails.resolvedLayoutValue == .todo ? .todo : .none
    }
}
