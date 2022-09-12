import Foundation
import BlocksModels

protocol RelationStorageProtocol: AnyObject {
    
    func relations(for links: [RelationLink]) -> [Relation]
    func relations() -> [Relation]
}
