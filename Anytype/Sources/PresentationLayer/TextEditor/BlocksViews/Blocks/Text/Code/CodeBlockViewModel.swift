import Combine
import UIKit
import Services

struct CodeBlockViewModel: BlockViewModelProtocol {    
    let className = "CodeBlockViewModel"
    nonisolated var info: BlockInformation { infoProvider.info }
    
    let infoProvider: BlockModelInfomationProvider
    let document: any BaseDocumentProtocol
    
    let becomeFirstResponder: (BlockInformation) -> ()
    let handler: any BlockActionHandlerProtocol
    let editorCollectionController: EditorBlockCollectionController
    let showCodeSelection: @MainActor (BlockInformation) -> ()

    func makeContentConfiguration(maxWidth width: CGFloat) -> any UIContentConfiguration {
        guard case let .text(content) = info.content else {
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
        }
        
        let anytypeText = content.anytypeText(document: document)
        let codeLanguage = info.fields.codeLanguage
        
        return CodeBlockContentConfiguration(
            content: content,
            anytypeText: anytypeText,
            backgroundColor: info.backgroundColor,
            codeLanguage: codeLanguage,
            actions: CodeBlockContentConfiguration.Actions(
                becomeFirstResponder: { becomeFirstResponder(info) },
                textDidChange: { textView in
                    Task {
                        try await handler.changeText(textView.attributedText.sendable(), blockId: info.id)
                    }
                },
                showCodeSelection: { showCodeSelection(info) }, 
                textBlockSetNeedsLayout: { editorCollectionController.itemDidChangeFrame(item: .block(self)) }
            )
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    nonisolated var debugDescription: String {
        return "id: \(blockId)"
    }
}
