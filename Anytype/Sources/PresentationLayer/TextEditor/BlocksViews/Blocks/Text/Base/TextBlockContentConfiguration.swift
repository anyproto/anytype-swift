import Combine
import BlocksModels
import UIKit

struct TextBlockContentConfiguration: UIContentConfiguration {
    
    let blockDelegate: BlockDelegate
    let block: BlockActiveRecordProtocol
    let shouldDisplayPlaceholder: Bool
    let focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    let actionHandler: EditorActionHandlerProtocol
    let configureMentions: (UITextView) -> Void
    let showStyleMenu: (BlockInformation) -> Void
    let pressingEnterTimeChecker = TimeChecker()
    let information: BlockInformation
    let isCheckable: Bool
    private(set) var isSelected: Bool = false
    
    init(blockDelegate: BlockDelegate,
         block: BlockActiveRecordProtocol,
         isCheckable: Bool,
         actionHandler: EditorActionHandlerProtocol,
         configureMentions: @escaping (UITextView) -> Void,
         showStyleMenu: @escaping (BlockInformation) -> Void,
         focusPublisher: AnyPublisher<BlockFocusPosition, Never>) {
        self.blockDelegate = blockDelegate
        self.block = block
        self.configureMentions = configureMentions
        self.actionHandler = actionHandler
        self.showStyleMenu = showStyleMenu
        self.focusPublisher = focusPublisher
        self.information = block.blockModel.information
        self.isCheckable = isCheckable
        shouldDisplayPlaceholder = block.isToggled && block.blockModel.information.childrenIds.isEmpty
    }
    
    func makeContentView() -> UIView & UIContentView {
        TextBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> TextBlockContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self
        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}

extension TextBlockContentConfiguration: Hashable {
    
    static func == (lhs: TextBlockContentConfiguration, rhs: TextBlockContentConfiguration) -> Bool {
        lhs.information.id == rhs.information.id &&
        lhs.information.alignment == rhs.information.alignment &&
        lhs.information.backgroundColor == rhs.information.backgroundColor &&
        lhs.information.content == rhs.information.content &&
        lhs.isSelected == rhs.isSelected &&
        lhs.shouldDisplayPlaceholder == rhs.shouldDisplayPlaceholder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information.id)
        hasher.combine(information.alignment)
        hasher.combine(information.backgroundColor)
        hasher.combine(information.content)
        hasher.combine(isSelected)
        hasher.combine(shouldDisplayPlaceholder)
    }
}
