import BlocksModels

final class SetSortsSearchInteractor {
    
    private let relations: [RelationDetails]
    
    init(relations: [RelationDetails]) {
        self.relations = relations
    }
}

extension SetSortsSearchInteractor {
    
    func search(text: String) -> Result<[RelationDetails], NewSearchError> {
        guard text.isNotEmpty else {
            return .success(relations)
        }

        let searchedRelations = relations.filter {
            $0.name.range(of: text, options: .caseInsensitive) != nil
        }
        
        if searchedRelations.isEmpty {
            return .failure(.noObjectErrorWithoutSubtitle(searchText: text))
        } else {
            return .success(searchedRelations)
        }
    }
}
