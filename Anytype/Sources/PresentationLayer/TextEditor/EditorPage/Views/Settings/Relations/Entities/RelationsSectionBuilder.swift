import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsSectionBuilder {
    
    func buildObjectSections(
        parsedRelations: ParsedRelations,
        onConflictingRelationsSectionTap: @escaping () -> ()
    ) -> [RelationsSection] {
        var sections: [RelationsSection] = []
        
        if parsedRelations.featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: Loc.header,
                    relations: parsedRelations.featuredRelations,
                    action: nil
                )
            )
        }
        
        if parsedRelations.sidebarRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.sidebarRelationsSectionId,
                    title: Loc.Fields.menu,
                    relations: parsedRelations.sidebarRelations,
                    action: nil
                )
            )
        }
        
        if parsedRelations.conflictedRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.conflictingRelationsSectionId,
                    title: Loc.Fields.missing,
                    relations: parsedRelations.conflictedRelations,
                    action: RelationsSectionAction(iconSystemName: "questionmark.circle.fill", color: .System.red, action: onConflictingRelationsSectionTap)
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
