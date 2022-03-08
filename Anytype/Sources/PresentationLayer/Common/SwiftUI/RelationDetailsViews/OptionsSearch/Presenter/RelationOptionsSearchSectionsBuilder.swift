import Foundation

final class RelationOptionsSearchSectionsBuilder {
    
    static func makeSections(using searchResult: RelationOptionsSearchResult) -> [RelationOptionsSearchSectionModel] {
        switch searchResult {
        case .objects(let array):
            return [
                RelationOptionsSearchSectionModel(
                    id: "objects.search.section.model.id",
                    title: nil,
                    rows: array.map {
                        RelationOptionsSearchRowModel.object(
                            RelationOptionsSearchObjectRowView.Model(
                                details: $0
                            )
                        )
                    }
                )
            ]
        case .files(let array):
            return [
                RelationOptionsSearchSectionModel(
                    id: "files.search.section.model.id",
                    title: nil,
                    rows: array.map {
                        RelationOptionsSearchRowModel.object(
                            RelationOptionsSearchObjectRowView.Model(
                                details: $0
                            )
                        )
                    }
                )
            ]
        case .tags(let array):
            return sections(from: array)
        }
    }
    
}

private extension RelationOptionsSearchSectionsBuilder {
    
    static func sections(from tags: [Relation.Tag.Option]) -> [RelationOptionsSearchSectionModel] {
        var localOptions: [Relation.Tag.Option] = []
        var otherOptions: [Relation.Tag.Option] = []
        
        tags.forEach {
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
                    rows: localOptions.map {
                        RelationOptionsSearchRowModel.tag(
                            RelationOptionsSearchTagRowView.Model(option: $0)
                        )
                    }
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                RelationOptionsSearchSectionModel(
                    id: "otherOptionsSectionID",
                    title: "Everywhere".localized,
                    rows: otherOptions.map {
                        RelationOptionsSearchRowModel.tag(
                            RelationOptionsSearchTagRowView.Model(option: $0)
                        )
                    }
                )
            )
        }
        
        return sections
    }
    
}
