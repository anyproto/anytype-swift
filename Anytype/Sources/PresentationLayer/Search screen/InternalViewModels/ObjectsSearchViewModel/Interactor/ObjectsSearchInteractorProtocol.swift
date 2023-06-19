import Foundation
import Services

protocol ObjectsSearchInteractorProtocol {
    
    func search(text: String) -> [ObjectDetails]
    
}
