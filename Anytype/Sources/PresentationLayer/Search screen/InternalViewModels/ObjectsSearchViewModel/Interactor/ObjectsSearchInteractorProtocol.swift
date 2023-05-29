import Foundation
import BlocksModels

protocol ObjectsSearchInteractorProtocol {
    
    func search(text: String) -> [ObjectDetails]
    
}
