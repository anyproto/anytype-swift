import Combine
import BlocksModels
import UIKit

struct TextBlockContentConfiguration: BlockConfiguration {
    typealias View = TextBlockContentView

    let attributedText: NSAttributedString

    let block: BlockModelProtocol
    let information: BlockInformation
    let content: BlockText
    let text: UIKitAnytypeText
    let isFirstResponder: Bool
    

    let shouldDisplayPlaceholder: Bool
    let isCheckable: Bool
    
    let focusPublisher: AnyPublisher<BlockFocusPosition, Never>

    let alignment: NSTextAlignment

    struct Actions {
        let createEmptyBlock: () -> Void
        let showPage: (EditorScreenData) -> Void
        let openURL: (URL) -> Void
        let changeText: (NSAttributedString) -> Void
        let changeTextStyle: (MarkupType, NSRange) -> Void
        let handleKeyboardAction: (CustomTextView.KeyboardAction, NSAttributedString) -> Void
        let becomeFirstResponder: () -> Void
        let resignFirstResponder: () -> Void

        let textBlockSetNeedsLayout: () -> Void

        let textViewWillBeginEditing: (UITextView) -> Void
        let textViewDidBeginEditing: (UITextView) -> Void
        let textViewDidEndEditing: (UITextView) -> Void
    }

 
    let pressingEnterTimeChecker = TimeChecker()

    init(
        blockDelegate: BlockDelegate,
        block: BlockModelProtocol,
        content: BlockText,
        upperBlock: BlockModelProtocol?,
        isCheckable: Bool,
        actionHandler: BlockActionHandlerProtocol,
        showPage: @escaping (EditorScreenData) -> Void,
        openURL: @escaping (URL) -> Void,
        focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    ) {
        self.blockDelegate = blockDelegate
        self.block = block
        self.content = content
        self.focusPublisher = focusPublisher
        self.information = block.information
        self.isCheckable = isCheckable
        
        self.text = content.anytypeText.attrString
        self.isFirstResponder = block.isFirstResponder
        shouldDisplayPlaceholder = block.isToggled && block.information.childrenIds.isEmpty
    }
}

extension TextBlockContentConfiguration: Hashable {
    
    static func == (lhs: TextBlockContentConfiguration, rhs: TextBlockContentConfiguration) -> Bool {
        lhs.information == rhs.information &&
        lhs.shouldDisplayPlaceholder == rhs.shouldDisplayPlaceholder &&
        lhs.isCheckable == rhs.isCheckable &&
        lhs.isFirstResponder == rhs.isFirstResponder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information.id)
        hasher.combine(information.alignment)
        hasher.combine(information.backgroundColor)
        hasher.combine(information.content)
        hasher.combine(shouldDisplayPlaceholder)
        hasher.combine(isCheckable)
        hasher.combine(isFirstResponder)
    }
}
