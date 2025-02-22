import Foundation
import SwiftUI


struct RelationsSection: Identifiable {
    let id: String
    let title: String
    let relations: [Relation]
    let isMissingFields: Bool
    
    var addedToObject: Bool {
        id != Constants.conflictingRelationsSectionId
    }
}

extension RelationsSection {
    enum Constants {
        static let featuredRelationsSectionId = "featuredRelationsSectionId"
        static let sidebarRelationsSectionId = "sidebarRelationsSectionId"
        static let conflictingRelationsSectionId = "conflictingRelationsSectionId"
    }
}
