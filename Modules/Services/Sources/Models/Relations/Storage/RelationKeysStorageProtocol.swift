import Foundation
import Combine

public protocol RelationKeysStorageProtocol: AnyObject {
    
    var relationKeys: [String] { get }
    
    func set(relationKeys: [String])
    func amend(relationKeys: [String])
    func remove(relationKeys: [String])
    
    func contains(relationKeys: [String]) -> Bool
}
