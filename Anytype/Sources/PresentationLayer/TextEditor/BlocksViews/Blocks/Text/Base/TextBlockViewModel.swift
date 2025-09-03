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
}

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
    
    private var cancellables = [AnyCancellable]()
    
    
    init(
        document: some BaseDocumentProtocol,
        blockInformationProvider: BlockModelInfomationProvider,
        actionHandler: some TextBlockActionHandlerProtocol,
        cursorManager: EditorCursorManager,
        customBackgroundColor: UIColor? = nil,
        collectionController: EditorBlockCollectionController? = nil
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.document = document
        self.actionHandler = actionHandler
        self.cursorManager = cursorManager
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
