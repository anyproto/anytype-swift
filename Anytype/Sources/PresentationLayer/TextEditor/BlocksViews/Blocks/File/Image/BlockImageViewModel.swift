import UIKit
import BlocksModels
import Combine

struct BlockImageViewModel: BlockViewModelProtocol {
    var diffable: AnyHashable {
        [
            blockId,
            fileData,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let isStruct = true
    
    let information: BlockInformation
    let fileData: BlockFile
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let indentationLevel: Int
    let showIconPicker: (BlockId) -> ()
    
    let imageLoader = ImageLoader()
    
    init?(
        information: BlockInformation,
        fileData: BlockFile,
        indentationLevel: Int,
        contextualMenuHandler: DefaultContextualMenuHandler,
        showIconPicker: @escaping (BlockId) -> ()
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
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }
    
    func handle(action: ContextualMenuAction) {
        switch action {
        case .replace:
            showIconPicker(blockId)
        case .download:
            guard let image = ImageProperty(imageId: fileData.metadata.hash).property else {
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func didSelectRowInTableView() {
        guard fileData.state != .uploading else {
            return
        }
        
        showIconPicker(blockId)
    }
    
    func updateView() { }
}
