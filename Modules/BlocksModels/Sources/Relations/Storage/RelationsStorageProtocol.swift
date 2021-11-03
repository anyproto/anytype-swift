import Foundation

public protocol RelationsStorageProtocol {
    
    func get(key: String) -> Relation?
    func add(relations: Relation, key: String)
    func remove(key: String)
    
}
