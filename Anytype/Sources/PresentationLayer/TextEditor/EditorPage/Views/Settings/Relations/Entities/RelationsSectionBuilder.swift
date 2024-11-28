import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsSectionBuilder {
    
    func buildObjectSections(from parsedRelations: ParsedRelations) -> [RelationsSection] {
        let objectRelations = parsedRelations.sidebarRelations
        
        var sections: [RelationsSection] = []
        
        if objectRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.typeRelationsSectionId,
                    title: "",
                    relations: objectRelations
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
