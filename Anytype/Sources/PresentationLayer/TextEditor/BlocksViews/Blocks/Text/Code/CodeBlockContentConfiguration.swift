import BlocksModels
import UIKit

struct CodeBlockContentConfiguration {
    let content: BlockText
    let backgroundColor: MiddlewareColor?
    let codeLanguage: CodeLanguage
    
    let becomeFirstResponder: () -> ()
    let textDidChange: (UITextView) -> ()
    let showCodeSelection: () -> ()
}

extension CodeBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        return CodeBlockView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> CodeBlockContentConfiguration {
        return self
    }
}

extension CodeBlockContentConfiguration: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content && lhs.backgroundColor == rhs.backgroundColor && lhs.codeLanguage == rhs.codeLanguage
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
        hasher.combine(backgroundColor)
        hasher.combine(codeLanguage)
    }
}
