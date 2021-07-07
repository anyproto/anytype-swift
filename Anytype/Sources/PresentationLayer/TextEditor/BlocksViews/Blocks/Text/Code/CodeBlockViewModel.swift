import Combine
import UIKit
import BlocksModels

struct CodeBlockViewModel: BlockViewModelProtocol {
    let isStruct = true
    
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
    private var codeLanguage: String {
        information.fields[Constants.codeLanguageFieldName]?.stringValue ?? "Swift"
    }

    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let becomeFirstResponder: (BlockModelProtocol) -> ()
    let setCodeLanguage: (BlockFields, BlockId) -> ()
    let textDidChange: (BlockActiveRecordProtocol, UITextView) -> ()
    

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
            }
        )
    }
    
    func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(
            title: "",
            children: [
                .init(action: .addBlockBelow),
                .init(action: .turnIntoPage),
                .init(action: .delete),
                .init(action: .duplicate)
            ]
        )
    }
    
    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: information)
    }

    func setCodeLanguage(_ language: String) {
        guard let contextId = block.container?.rootId else { return }
        let blockFields = BlockFields(blockId: blockId, fields: [Constants.codeLanguageFieldName: language])
        setCodeLanguage(blockFields, contextId)
    }
    
    func didSelectRowInTableView() { }
    func updateView() {}
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)\ntext: \(textData.attributedText.string.prefix(10))...\ntype: \(textData.contentType)"
    }
}

extension CodeBlockViewModel {
    private enum Constants {
        static let codeLanguageFieldName = "lang"
    }
}
