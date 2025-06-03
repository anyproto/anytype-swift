import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

final class PropertiesSectionBuilder {
    
    func buildObjectSections(parsedRelations: ParsedRelations) -> [PropertiesSection] {
        var sections: [PropertiesSection] = []
        
        if parsedRelations.featuredRelations.isNotEmpty || parsedRelations.sidebarRelations.isNotEmpty {
            sections.append(
                PropertiesSection(
                    id: PropertiesSection.Constants.featuredPropertiesSectionId,
                    title: "",
                    relations: parsedRelations.featuredRelations + parsedRelations.sidebarRelations,
                    isMissingFields: false
                )
            )
        }
        
        if parsedRelations.conflictedRelations.isNotEmpty {
            sections.append(
                PropertiesSection(
                    id: PropertiesSection.Constants.conflictingPropertiesSectionId,
                    title: Loc.Fields.local,
                    relations: parsedRelations.conflictedRelations,
                    isMissingFields: true
                )
            )
        }

        return sections
    }

    func buildSectionsLegacy(from parsedRelations: ParsedRelations, objectTypeName: String) -> [PropertiesSection] {
        anytypeAssertionFailure("Not supported in a new API")
        return []
    }
}
