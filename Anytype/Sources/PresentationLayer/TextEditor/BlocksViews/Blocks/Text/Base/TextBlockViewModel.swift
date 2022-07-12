import Combine
import UIKit
import BlocksModels

struct TextBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool

    private let focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    private let actionHandler: TextBlockActionHandler

    var hashable: AnyHashable {
        [info, isCheckable, toggled] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
        content: BlockText,
        isCheckable: Bool,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>,
        actionHandler: TextBlockActionHandler
    ) {
        self.content = content
        self.isCheckable = isCheckable

        self.toggled = info.isToggled
        self.info = info
        self.focusSubject = focusSubject
        self.actionHandler = actionHandler
    }

    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }

    func textBlockContentConfiguration() -> TextBlockContentConfiguration {
        return textBlockContentConfiguration(content: content)
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
    
    private func textBlockContentConfiguration(content: BlockText) -> TextBlockContentConfiguration {
        TextBlockContentConfiguration(
            blockId: info.id,
            content: content,
            alignment: info.alignment.asNSTextAlignment,
            isCheckable: isCheckable,
            isToggled: info.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: info.isToggled && info.childrenIds.isEmpty,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            resetPublisher: actionHandler.resetSubject
                .map { textBlockContentConfiguration(content: $0) }
                .eraseToAnyPublisher(),
            actions: TextBlockContentConfiguration.Actions(handler: actionHandler)
        )
    }
}
