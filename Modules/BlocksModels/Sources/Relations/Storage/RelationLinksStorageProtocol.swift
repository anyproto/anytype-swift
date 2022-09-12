import Foundation

public protocol RelationLinksStorageProtocol: AnyObject {
    
    var relationLinks: [RelationLink] { get }
    
    func set(relationLinks: [RelationLink])
    func amend(relationLinks: [RelationLink])
    func remove(relationIds: [String])
    
    func contains(relationKeys: [String]) -> Bool
}
