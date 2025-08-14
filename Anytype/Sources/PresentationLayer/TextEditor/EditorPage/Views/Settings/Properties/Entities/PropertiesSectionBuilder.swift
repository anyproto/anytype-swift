import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

final class PropertiesSectionBuilder {
    
    func buildObjectSections(parsedProperties: ParsedProperties) -> [PropertiesSection] {
        var sections: [PropertiesSection] = []
        
        if parsedProperties.featuredProperties.isNotEmpty || parsedProperties.sidebarProperties.isNotEmpty {
            sections.append(
                PropertiesSection(
                    id: PropertiesSection.Constants.featuredPropertiesSectionId,
                    title: "",
                    relations: parsedProperties.featuredProperties + parsedProperties.sidebarProperties,
                    isMissingFields: false,
                    isExpandable: false
                )
            )
        }
        
        if parsedProperties.hiddenProperties.isNotEmpty {
            sections.append(
                PropertiesSection(
                    id: PropertiesSection.Constants.hiddenPropertiesSectionId,
                    title: Loc.hidden,
                    relations: parsedProperties.hiddenProperties,
                    isMissingFields: false,
                    isExpandable: true
                )
            )
        }
        
        if parsedProperties.conflictedProperties.isNotEmpty {
            sections.append(
                PropertiesSection(
                    id: PropertiesSection.Constants.conflictingPropertiesSectionId,
                    title: Loc.Fields.local,
                    relations: parsedProperties.conflictedProperties,
                    isMissingFields: true,
                    isExpandable: true
                )
            )
        }

        return sections
    }

    func buildSectionsLegacy(from parsedProperties: ParsedProperties, objectTypeName: String) -> [PropertiesSection] {
        anytypeAssertionFailure("Not supported in a new API")
        return []
    }
}
