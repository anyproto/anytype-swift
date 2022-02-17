import BlocksModels
import UIKit

struct CodeBlockContentConfiguration: BlockConfiguration {
    typealias View = CodeBlockView

    struct Actions {
        let becomeFirstResponder: () -> ()
        let textDidChange: (UITextView) -> ()
        let showCodeSelection: () -> ()
    }

    let content: BlockText
    let backgroundColor: MiddlewareColor?
    let codeLanguage: CodeLanguage
    @EquatableNoop private(set) var actions: Actions
}
