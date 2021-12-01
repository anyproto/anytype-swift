import Foundation
import BlocksModels

protocol RelationsServiceProtocol {
    func addFeaturedRelation(relationKey: String)
    func removeFeaturedRelation(relationKey: String)
    func removeRelation(relationKey: String)
}
