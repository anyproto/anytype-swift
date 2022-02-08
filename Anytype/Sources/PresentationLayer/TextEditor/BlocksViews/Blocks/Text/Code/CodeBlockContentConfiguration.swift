import BlocksModels
import UIKit

struct CodeBlockContentConfiguration: BlockConfigurationProtocol {
    let content: BlockText
    let backgroundColor: MiddlewareColor?
    let codeLanguage: CodeLanguage
    let becomeFirstResponder: () -> ()
    let textDidChange: (UITextView) -> ()
    let showCodeSelection: () -> ()
    var currentConfigurationState: UICellConfigurationState?
}

extension CodeBlockContentConfiguration: UIContentConfiguration {
    func makeContentView() -> UIView & UIContentView {
        return CodeBlockView(configuration: self)
    }
}

extension CodeBlockContentConfiguration: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.codeLanguage == rhs.codeLanguage &&
        lhs.currentConfigurationState == rhs.currentConfigurationState
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
        hasher.combine(backgroundColor)
        hasher.combine(codeLanguage)
        hasher.combine(currentConfigurationState)
    }
}
