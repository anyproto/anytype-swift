import Foundation
import BlocksModels

protocol RelationDetailsStorageProtocol: AnyObject {
    
    func relations(for links: [RelationLink]) -> [RelationDetails]
    func relations() -> [RelationDetails]
}
