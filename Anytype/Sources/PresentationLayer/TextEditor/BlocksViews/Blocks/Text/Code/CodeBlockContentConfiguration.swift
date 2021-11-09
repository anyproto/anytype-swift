import BlocksModels
import UIKit

struct CodeBlockContentConfiguration {
    let content: BlockText
    let backgroundColor: MiddlewareColor?
    let codeLanguage: CodeLanguage
    let detailsStorage: ObjectDetailsStorageProtocol
    let becomeFirstResponder: () -> ()
    let textDidChange: (UITextView) -> ()
    let showCodeSelection: () -> ()
    private(set) var currentConfigurationState: UICellConfigurationState?
}

extension CodeBlockContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        return CodeBlockView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
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
