import Foundation

public protocol RelationsStorageProtocol {
    
    var relations: [Relation] { get }
    
    func set(relations: [Relation])
    func amend(relations: [Relation])
    func remove(relationKeys: [String])
    
}
