import Combine
import UIKit
import BlocksModels

struct TextBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool

    private let focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    private let actionHandler: TextBlockActionHandlerProtocol
    private let customBackgroundColor: UIColor?

    var hashable: AnyHashable {
        [info, isCheckable, toggled] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
        content: BlockText,
        isCheckable: Bool,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>,
        actionHandler: TextBlockActionHandlerProtocol,
        customBackgroundColor: UIColor? = nil
    ) {
        self.content = content
        self.isCheckable = isCheckable

        self.toggled = info.isToggled
        self.info = info
        self.focusSubject = focusSubject
        self.actionHandler = actionHandler
        self.customBackgroundColor = customBackgroundColor
    }

    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func textBlockContentConfiguration() -> TextBlockContentConfiguration {
        TextBlockContentConfiguration(
            blockId: info.id,
            content: content,
            alignment: info.horizontalAlignment.asNSTextAlignment,
            isCheckable: isCheckable,
            isToggled: info.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: info.isToggled && info.childrenIds.isEmpty,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            resetPublisher: actionHandler.resetSubject
                .map { _ in textBlockContentConfiguration() }
                .eraseToAnyPublisher(),
            actions: actionHandler.textBlockActions()
        )
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let contentConfiguration = textBlockContentConfiguration()

        let isDragConfigurationAvailable =
            content.contentType != .description && content.contentType != .title

        return contentConfiguration.cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration:
                isDragConfigurationAvailable ? .init(id: info.id) : nil
        )
    }

    func makeSpreadsheetConfiguration() -> UIContentConfiguration {
        let color: UIColor = info.configurationData.backgroundColor.map { UIColor.Background.uiColor(from: $0) }
            ?? customBackgroundColor
            ?? .backgroundPrimary

        return textBlockContentConfiguration()
            .spreadsheetConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: color)
            )
    }
}
