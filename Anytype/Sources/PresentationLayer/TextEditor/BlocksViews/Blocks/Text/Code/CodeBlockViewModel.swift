import Combine
import UIKit
import BlocksModels

struct CodeBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable {
        [
            information,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let block: BlockModelProtocol
    var information: BlockInformation { block.information }
    var indentationLevel: Int { block.indentationLevel }
    let textData: UIKitAnytypeText
    private var codeLanguage: CodeLanguage {
        CodeLanguage.create(
            middleware: block.information.fields[FieldName.codeLanguage]?.stringValue
        )
    }

    let contextualMenuHandler: DefaultContextualMenuHandler
    let becomeFirstResponder: (BlockModelProtocol) -> ()
    let textDidChange: (BlockModelProtocol, UITextView) -> ()
    let showCodeSelection: (BlockModelProtocol) -> ()

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return CodeBlockContentConfiguration(
            content: textData,
            backgroundColor: block.information.backgroundColor,
            codeLanguage: codeLanguage,
            becomeFirstResponder: {
                self.becomeFirstResponder(self.block)
            },
            textDidChange: { textView in
                self.textDidChange(self.block, textView)
            },
            showCodeSelection: {
                self.showCodeSelection(self.block)
            }
        )
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        [ .addBlockBelow, .turnIntoPage, .duplicate, .delete ]
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: block.information)
    }
    
    func didSelectRowInTableView() { }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)\ntext: \(textData.attrString.string.prefix(10))...\ntype: \(block.information.content.type.style.description)"
    }
}
