import Services
import SwiftProtobuf
import UIKit

final class RelationsSectionBuilder {
    
    func buildObjectSections(from parsedRelations: ParsedRelations, objectTypeName: String) -> [RelationsSection] {
        let objectRelations = parsedRelations.otherRelations + parsedRelations.typeRelations
        
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
    
    func buildTypeSections(from parsedRelations: ParsedRelations, objectTypeName: String) -> [RelationsSection] {
        let featuredRelations = parsedRelations.featuredRelations
        let menuRelations = parsedRelations.otherRelations + parsedRelations.typeRelations
        
        var sections: [RelationsSection] = []

        if featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: Loc.header,
                    relations: featuredRelations
                )
            )
        }
        

        if menuRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.otherRelationsSectionId,
                    title: Loc.Fields.menu,
                    relations: menuRelations
                )
            )
        }

        return sections
    }

    func buildSectionsLegacy(from parsedRelations: ParsedRelations, objectTypeName: String) -> [RelationsSection] {
        let featuredRelations = parsedRelations.featuredRelations
        let otherRelations = parsedRelations.otherRelations
        let typeRelations = parsedRelations.typeRelations
        
        var sections: [RelationsSection] = []

        if featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: Loc.featuredRelations,
                    relations: featuredRelations
                )
            )
        }

        if otherRelations.isNotEmpty {
            let otherRelationsSectionTitle = featuredRelations.isNotEmpty ?
            Loc.otherRelations :
            Loc.inThisObject

            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.otherRelationsSectionId,
                    title: otherRelationsSectionTitle,
                    relations: otherRelations
                )
            )
        }
        
        if typeRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.typeRelationsSectionId,
                    title: Loc.Relation.From.type(objectTypeName),
                    relations: typeRelations
                )
            )
        }

        return sections
    }
}
