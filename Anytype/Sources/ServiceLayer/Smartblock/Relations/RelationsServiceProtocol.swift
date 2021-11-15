import Foundation
import BlocksModels

protocol RelationsServiceProtocol {
    func addFeaturedRelations(objectId: BlockId, relationIds: [String])
    func removeFeaturedRelations(objectId: BlockId, relationIds: [String])
}
