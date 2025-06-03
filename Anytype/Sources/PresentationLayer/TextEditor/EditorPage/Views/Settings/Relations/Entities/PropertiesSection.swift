import Foundation
import SwiftUI


struct PropertiesSection: Identifiable {
    let id: String
    let title: String
    let relations: [Relation]
    let isMissingFields: Bool
    
    var addedToObject: Bool {
        id != Constants.conflictingRelationsSectionId
    }
}

extension PropertiesSection {
    enum Constants {
        static let featuredRelationsSectionId = "featuredRelationsSectionId"
        static let sidebarRelationsSectionId = "sidebarRelationsSectionId"
        static let conflictingRelationsSectionId = "conflictingRelationsSectionId"
    }
}
