import Foundation

public protocol RelationLinksStorageProtocol: AnyObject {
    
    var relationLinks: [RelationLink] { get }
    
    func set(relationLinks: [RelationLink])
    func amend(relationLinks: [RelationLink])
    func remove(relationKeys: [String])
    
    func contains(relationKeys: [String]) -> Bool
}
