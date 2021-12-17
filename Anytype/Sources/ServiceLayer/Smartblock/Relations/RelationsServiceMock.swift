import Foundation
import ProtobufMessages
import BlocksModels

final class RelationsServiceMock: RelationsServiceProtocol {

    func addFeaturedRelation(relationKey: String) {
    }

    func removeFeaturedRelation(relationKey: String) {
    }

    func removeRelation(relationKey: String) {
    }

    func addRelationOption(relationKey: String, optionText: String) -> String? {
        return nil
    }

    func availableRelations() -> [RelationMetadata]? {
        return nil
    }

}
