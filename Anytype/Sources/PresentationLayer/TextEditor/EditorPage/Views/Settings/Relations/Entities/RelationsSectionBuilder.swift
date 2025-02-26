import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsSectionBuilder {
    
    func buildObjectSections(parsedRelations: ParsedRelations) -> [RelationsSection] {
        var sections: [RelationsSection] = []
        
        if parsedRelations.featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: Loc.header,
                    relations: parsedRelations.featuredRelations,
                    isMissingFields: false
                )
            )
        }
        
        if parsedRelations.sidebarRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.sidebarRelationsSectionId,
                    title: Loc.Fields.menu,
                    relations: parsedRelations.sidebarRelations,
                    isMissingFields: false
                )
            )
        }
        
        if parsedRelations.conflictedRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.conflictingRelationsSectionId,
                    title: Loc.Fields.local,
                    relations: parsedRelations.conflictedRelations,
                    isMissingFields: true
                )
            )
        }

        return sections
    }

    func buildSectionsLegacy(from parsedRelations: ParsedRelations, objectTypeName: String) -> [RelationsSection] {
        anytypeAssertionFailure("Not supported in a new API")
        return []
    }
}
