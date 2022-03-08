import Foundation

final class RelationOptionsSearchSectionsBuilder {
    
    func makeSections(using searchResult: RelationOptionsSearchResult) -> [RelationOptionsSearchSectionModel] {
        switch searchResult {
        case .objects(let array):
            return [
                RelationOptionsSearchSectionModel(
                    id: "objects.search.section.model.id",
                    title: nil,
                    rows: []
                )
            ]
        case .files(let array):
            return []
        case .tags(let array):
            return []
        }
    }
    
}
