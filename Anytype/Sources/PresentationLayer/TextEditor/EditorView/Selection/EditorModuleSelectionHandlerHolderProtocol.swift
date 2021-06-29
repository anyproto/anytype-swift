import Foundation
import Combine
import BlocksModels

protocol EditorModuleSelectionHandlerHolderProtocol {
    var selectionHandler: EditorModuleSelectionHandlerProtocol {get}
    
    func selectAll()
}
