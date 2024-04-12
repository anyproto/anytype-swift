import Combine
import UIKit
import Services

final class BlockModelInfomationProvider {
    @Published private(set) var info: BlockInformation
    
    private let infoContainer: InfoContainerProtocol
    private var subscription: AnyCancellable?
    
    init(
        infoContainer: InfoContainerProtocol,
        info: BlockInformation
    ) {
        self.infoContainer = infoContainer
        self.info = info
        
        setupPublisher()
    }
    
    private func setupPublisher() {
        subscription = infoContainer
            .publisherFor(id: info.id)
            .sink { [weak self] in $0.map { self?.info = $0 } }
    }
}

final class TextBlockViewModel: BlockViewModelProtocol {
    enum Style {
        case none
        case todo
    }
    
    var info: BlockInformation { blockInformationProvider.info }
    private let blockInformationProvider: BlockModelInfomationProvider
    private var document: BaseDocumentProtocol
    private var style: Style = .none
    
    private var content: BlockText = .empty(contentType: .text)
    private var anytypeText: UIKitAnytypeText?
    
    private let actionHandler: TextBlockActionHandlerProtocol
    private var customBackgroundColor: UIColor?
    private var cursorManager: EditorCursorManager
    
    var hashable: AnyHashable { blockInformationProvider.info.id }
    
    private var cancellables = [AnyCancellable]()
    
    
    init(
        document: BaseDocumentProtocol,
        blockInformationProvider: BlockModelInfomationProvider,
        stylePublisher: AnyPublisher<Style, Never>,
        actionHandler: TextBlockActionHandlerProtocol,
        cursorManager: EditorCursorManager,
        customBackgroundColor: UIColor? = nil
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.document = document
        self.actionHandler = actionHandler
        self.cursorManager = cursorManager
        self.customBackgroundColor = customBackgroundColor
      
        stylePublisher.receiveOnMain().sink { [weak self] style in
            self?.style = style
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
            alignment: info.horizontalAlignment.asNSTextAlignment,
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
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
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
    
    func makeSpreadsheetConfiguration() -> UIContentConfiguration {
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
}
