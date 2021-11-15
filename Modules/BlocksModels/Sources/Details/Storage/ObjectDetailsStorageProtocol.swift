import Foundation

public protocol ObjectDetailsStorageProtocol {
    
    func get(id: BlockId) -> ObjectDetails?
    func add(details: ObjectDetails, id: BlockId)
    
}
