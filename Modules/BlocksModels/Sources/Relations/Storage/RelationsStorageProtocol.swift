import Foundation

public protocol RelationsStorageProtocol {
    
    func get(id: String) -> Relation?
    func add(details: Relation, id: String)
    
}
