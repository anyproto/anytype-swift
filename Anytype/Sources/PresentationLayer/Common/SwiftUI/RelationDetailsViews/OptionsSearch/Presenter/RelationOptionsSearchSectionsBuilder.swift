import Foundation
import BlocksModels

final class RelationOptionsSearchSectionsBuilder {
    
    static func makeSections(using searchResult: RelationOptionsSearchResult) -> [RelationOptionsSearchSectionModel] {
        switch searchResult {
        case .objects(let array):
            return objectsSection(array)
        case .files(let array):
            return filesSection(array)
        case .tags(let array):
            return tagsSections(array)
        case .statuses(let array):
            return statusesSections(array)
        }
    }
    
}

private extension RelationOptionsSearchSectionsBuilder {
    
    static func objectsSection(_ objects: [ObjectDetails]) -> [RelationOptionsSearchSectionModel] {
        [
            RelationOptionsSearchSectionModel(
                id: "objects.search.section.model.id",
                title: nil,
                rows: objects.map {
                    RelationOptionsSearchRowModel.object(
                        RelationOptionsSearchObjectRowView.Model(
                            details: $0
                        )
                    )
                }
            )
        ]
    }
    
    static func filesSection(_ files: [ObjectDetails]) -> [RelationOptionsSearchSectionModel] {
        [
            RelationOptionsSearchSectionModel(
                id: "files.search.section.model.id",
                title: nil,
                rows: files.map {
                    RelationOptionsSearchRowModel.file(
                        RelationOptionsSearchObjectRowView.Model(
                            details: $0
                        )
                    )
                }
            )
        ]
    }
    
    static func tagsSections(_ tags: [Relation.Tag.Option]) -> [RelationOptionsSearchSectionModel] {
        scopedOptionsSections(tags) { tag in
            return RelationOptionsSearchRowModel.tag(
                RelationOptionsSearchTagRowView.Model(option: tag)
            )
        }
    }
    
    static func statusesSections(_ statuses: [Relation.Status.Option]) -> [RelationOptionsSearchSectionModel] {
        scopedOptionsSections(statuses) { status in
            return RelationOptionsSearchRowModel.status(
                RelationOptionsSearchStatusRowView.Model(option: status)
            )
        }
    }
    
    static func scopedOptionsSections<O: NewRelationOptionProtocol>(_ options: [O], transformation: (O) -> RelationOptionsSearchRowModel) -> [RelationOptionsSearchSectionModel] {
        var localOptions: [O] = []
        var otherOptions: [O] = []
        
        options.forEach {
            if $0.scope == .local {
                localOptions.append($0)
            } else {
                otherOptions.append($0)
            }
        }
        
        var sections: [RelationOptionsSearchSectionModel] = []
        
        if localOptions.isNotEmpty {
            sections.append(
                RelationOptionsSearchSectionModel(
                    id: "localOptionsSectionID",
                    title: "In this object".localized,
                    rows: localOptions.map { transformation($0) }
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                RelationOptionsSearchSectionModel(
                    id: "otherOptionsSectionID",
                    title: "Everywhere".localized,
                    rows: otherOptions.map { transformation($0) }
                )
            )
        }
        
        return sections
    }
    
}
