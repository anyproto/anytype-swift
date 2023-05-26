import Foundation

struct RelationsSection: Identifiable {
    let id: String
    let title: String
    let relations: [Relation]
    
    var addedToObject: Bool {
        id != Constants.typeRelationsSectionId
    }
}

extension RelationsSection {
    enum Constants {
        static let featuredRelationsSectionId = "featuredRelationsSectionId"
        static let otherRelationsSectionId = "otherRelationsSectionId"
        static let typeRelationsSectionId = "typeRelationsSectionId"
    }
}
