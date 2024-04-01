import Services
import UIKit

struct CodeBlockContentConfiguration: BlockConfiguration {
    typealias View = CodeBlockView

    struct Actions {
        let becomeFirstResponder: () -> ()
        let textDidChange: (UITextView) -> ()
        let showCodeSelection: @MainActor () -> ()
        let textBlockSetNeedsLayout: () -> Void
    }

    let content: BlockText
    let anytypeText: UIKitAnytypeText
    let backgroundColor: MiddlewareColor?
    let codeLanguage: CodeLanguage
    @EquatableNoop private(set) var actions: Actions
}

extension CodeBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    }
}
