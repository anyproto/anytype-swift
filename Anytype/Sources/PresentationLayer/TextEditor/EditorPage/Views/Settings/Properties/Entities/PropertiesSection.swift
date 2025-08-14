import Foundation
import SwiftUI


struct PropertiesSection: Identifiable {
    let id: String
    let title: String
    let relations: [Property]
    let isMissingFields: Bool
    let isExpandable: Bool
    
    var addedToObject: Bool {
        id != Constants.conflictingPropertiesSectionId 
    }
}

extension PropertiesSection {
    enum Constants {
        static let featuredPropertiesSectionId = "featuredPropertiesSectionId "
        static let conflictingPropertiesSectionId = "conflictingPropertiesSectionId"
        static let hiddenPropertiesSectionId = "hiddenPropertiesSectionId"
    }
}
