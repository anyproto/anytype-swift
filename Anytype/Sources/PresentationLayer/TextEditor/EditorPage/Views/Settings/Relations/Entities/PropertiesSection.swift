import Foundation
import SwiftUI


struct PropertiesSection: Identifiable {
    let id: String
    let title: String
    let relations: [Relation]
    let isMissingFields: Bool
    let isExpandable: Bool
    
    var addedToObject: Bool {
        id != Constants.conflictingPropertiesSectionId 
    }
}

extension PropertiesSection {
    enum Constants {
        static let featuredPropertiesSectionId = "featuredPropertiesSectionId "
        static let sidebarPropertiesSectionId = "sidebarPropertiesSectionId"
        static let conflictingPropertiesSectionId = "conflictingPropertiesSectionId"
        static let hiddenPropertiesSectionId = "hiddenPropertiesSectionId"
    }
}
