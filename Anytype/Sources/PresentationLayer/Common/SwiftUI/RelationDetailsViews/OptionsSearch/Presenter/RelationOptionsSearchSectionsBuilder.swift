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
            return []
        }
    }
    
}
