import Combine
import UIKit
import Services

struct CodeBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { info.id }
    var info: BlockInformation { infoProvider.info }
    
    let infoProvider: BlockModelInfomationProvider
    let document: BaseDocumentProtocol
    
    let becomeFirstResponder: (BlockInformation) -> ()
    let handler: BlockActionHandlerProtocol
    let editorCollectionController: EditorBlockCollectionController
    let showCodeSelection: (BlockInformation, CodeLanguage) -> ()

    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        guard case let .text(content) = info.content else {
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
        }
        
        let anytypeText = content.anytypeText(document: document)
        let codeLanguage = CodeLanguage.create(
            middleware: info.fields[CodeBlockFields.FieldName.codeLanguage]?.stringValue
        )
        
        return CodeBlockContentConfiguration(
            content: content,
            anytypeText: anytypeText,
            backgroundColor: info.backgroundColor,
            codeLanguage: codeLanguage,
            actions: .init(
                becomeFirstResponder: { becomeFirstResponder(info) },
                textDidChange: { textView in
                    handler.changeText(textView.attributedText, blockId: info.id)
                    editorCollectionController.reconfigure(items: [.block(self)])
                },
                showCodeSelection: { showCodeSelection(info, codeLanguage) }
            )
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)"
    }
}
