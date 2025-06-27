import Services

final class SetPropertiesDetailsLocalSearchInteractor {
    
    private let relationsDetails: [PropertyDetails]
    
    init(relationsDetails: [PropertyDetails]) {
        self.relationsDetails = relationsDetails
    }
}

extension SetPropertiesDetailsLocalSearchInteractor {
    
    func search(text: String) -> Result<[PropertyDetails], LegacySearchError> {
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
    
    func convert(ids: [String]) -> [PropertyDetails] {
        return relationsDetails.filter { ids.contains($0.id) }
    }
}
