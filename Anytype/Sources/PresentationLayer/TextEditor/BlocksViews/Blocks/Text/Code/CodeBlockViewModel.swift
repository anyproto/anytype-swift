import Combine
import UIKit
import BlocksModels

struct CodeBlockViewModel: BlockViewModelProtocol {    
    var diffable: AnyHashable {
        [
            textData,
            indentationLevel,
            blockId
        ] as [AnyHashable]
    }
    
    let block: BlockActiveRecordProtocol
    let textData: BlockText
    var information: BlockInformation {
        block.blockModel.information
    }
    var indentationLevel: Int {
        block.indentationLevel
    }
    private var codeLanguage: CodeLanguage {
        CodeLanguage.create(middleware: information.fields[FieldName.codeLanguage]?.stringValue)
    }

    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let becomeFirstResponder: (BlockModelProtocol) -> ()
    let textDidChange: (BlockActiveRecordProtocol, UITextView) -> ()
    let showCodeSelection: (BlockActiveRecordProtocol) -> ()

    func makeContentConfiguration() -> UIContentConfiguration {
        return CodeBlockContentConfiguration(
            content: textData,
            backgroundColor: information.backgroundColor,
            codeLanguage: codeLanguage,
            becomeFirstResponder: {
                self.becomeFirstResponder(self.block.blockModel)
            },
            textDidChange: { textView in
                self.textDidChange(self.block, textView)
            },
            showCodeSelection: {
                self.showCodeSelection(self.block)
            }
        )
    }
    
    func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(
            title: "",
            children: [
                .init(action: .addBlockBelow),
                .init(action: .turnIntoPage),
                .init(action: .duplicate),
                .init(action: .delete)
            ]
        )
    }
    
    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func didSelectRowInTableView() { }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)\ntext: \(textData.attributedText.string.prefix(10))...\ntype: \(textData.contentType)"
    }
}
