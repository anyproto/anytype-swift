import Foundation

#warning("Delete it")
public protocol RelationsMetadataStorageProtocol {
    
    var relations: [RelationMetadata] { get }
    
    func set(relations: [RelationMetadata])
    func amend(relations: [RelationMetadata])
    func remove(relationKeys: [String])
    
}
