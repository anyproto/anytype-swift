import Foundation
import BlocksModels

protocol ObjectsSearchInteractorProtocol {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ())
    
}
