import UIKit
import BlocksModels
import Combine

struct BlockImageViewModel: BlockViewModelProtocol {
    var diffable: AnyHashable {
        fileData
    }
    
    let isStruct = true
    
    let information: BlockInformation
    let fileData: BlockFile
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let indentationLevel: Int
    let showIconPicker: () -> ()
    
    init?(
        information: BlockInformation,
        fileData: BlockFile,
        indentationLevel: Int,
        contextualMenuHandler: DefaultContextualMenuHandler,
        showIconPicker: @escaping () -> ()
    ) {
        guard fileData.contentType == .image else {
            assertionFailure("Wrong content type of \(fileData), image expected")
            return nil
        }
        
        self.information = information
        self.fileData = fileData
        self.contextualMenuHandler = contextualMenuHandler
        self.indentationLevel = indentationLevel
        self.showIconPicker = showIconPicker
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockImageConfiguration(fileData)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        switch fileData.state {
        case .done:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
                .init(action: .download),
                .init(action: .replace)
            ])
        default:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
            ])
        }
    }
    
    func handle(action: ContextualMenuAction) {
        switch action {
        case .replace:
            showIconPicker()
        case .download:
            assertionFailure("Not implemented")
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func didSelectRowInTableView() {
        guard fileData.state != .uploading else {
            return
        }
        
        showIconPicker()
    }
    
    func updateView() { }
}
