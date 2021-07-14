import Combine
import BlocksModels
import UIKit

struct TextBlockContentConfiguration: UIContentConfiguration {
    
    let blockDelegate: BlockDelegate
    let block: BlockActiveRecordProtocol
    let mentionsConfigurator: MentionsTextViewConfigurator
    let shouldDisplayPlaceholder: Bool
    let actionHandler: EditorActionHandlerProtocol
    let focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    let editorRouter: EditorRouterProtocol
    let pressingEnterTimeChecker = TimeChecker()
    let information: BlockInformation
    private(set) var isSelected: Bool = false
    
    init(blockDelegate: BlockDelegate,
         block: BlockActiveRecordProtocol,
         mentionsConfigurator: MentionsTextViewConfigurator,
         actionHandler: EditorActionHandlerProtocol,
         focusPublisher: AnyPublisher<BlockFocusPosition, Never>,
         editorRouter: EditorRouterProtocol) {
        self.blockDelegate = blockDelegate
        self.block = block
        self.mentionsConfigurator = mentionsConfigurator
        self.actionHandler = actionHandler
        self.focusPublisher = focusPublisher
        self.editorRouter = editorRouter
        self.information = block.blockModel.information
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
