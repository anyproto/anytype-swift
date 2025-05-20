import Services

final class SetPropertiesDetailsLocalSearchInteractor {
    
    private let relationsDetails: [RelationDetails]
    
    init(relationsDetails: [RelationDetails]) {
        self.relationsDetails = relationsDetails
    }
}

extension SetPropertiesDetailsLocalSearchInteractor {
    
    func search(text: String) -> Result<[RelationDetails], LegacySearchError> {
        guard text.isNotEmpty else {
            return .success(relationsDetails)
        }

        let searchedRelations = relationsDetails.filter {
            $0.name.range(of: text, options: .caseInsensitive) != nil
        }
        
        if searchedRelations.isEmpty {
            return .failure(.noObjectErrorWithoutSubtitle(searchText: text))
        } else {
            return .success(searchedRelations)
        }
    }
    
    func convert(ids: [String]) -> [RelationDetails] {
        return relationsDetails.filter { ids.contains($0.id) }
    }
}
