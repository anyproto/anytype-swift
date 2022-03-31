import Combine
import UIKit
import BlocksModels

struct CodeBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable {
        [
            info,
            codeLanguage
        ] as [AnyHashable]
    }
    
    let info: BlockInformation
    let content: BlockText
    let codeLanguage: CodeLanguage

    let becomeFirstResponder: (BlockInformation) -> ()
    let textDidChange: (BlockInformation, UITextView) -> ()
    let showCodeSelection: (BlockInformation) -> ()

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return CodeBlockContentConfiguration(
            content: content,
            backgroundColor: info.backgroundColor,
            codeLanguage: codeLanguage,
            actions: .init(
                becomeFirstResponder: { becomeFirstResponder(info) },
                textDidChange: { textView in textDidChange(info, textView) },
                showCodeSelection: { showCodeSelection(info) }
            )
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.metadata),
            dragConfiguration: .init(id: info.id)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)\ntext: \(content.anytypeText.attrString.string.prefix(10))...\ntype: \(info.content.type.style.description)"
    }
}
