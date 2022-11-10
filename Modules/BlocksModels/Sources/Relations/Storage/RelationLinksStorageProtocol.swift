import Foundation
import Combine

public protocol RelationLinksStorageProtocol: AnyObject {
    
    var relationLinks: [RelationLink] { get }
    
    var relationLinksPublisher: AnyPublisher<[RelationLink], Never> { get }
        
    func set(relationLinks: [RelationLink])
    func amend(relationLinks: [RelationLink])
    func remove(relationIds: [String])
    
    func contains(relationKeys: [String]) -> Bool
}
