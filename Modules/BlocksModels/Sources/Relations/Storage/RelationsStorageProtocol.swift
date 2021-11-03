import Foundation

public protocol RelationsStorageProtocol {
    
    func set(relations: [Relation])
    func amend(relations: [Relation])
    func remove(relationKeys: [String])
    
}
