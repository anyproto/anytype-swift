import Foundation
import SwiftUI
import Services
import Combine

@MainActor
protocol NewRelationCoordinatorViewOutput: AnyObject {
    func didCreateRelation(_ relation: RelationDetails)
}

@MainActor
final class NewRelationCoordinatorViewModel: ObservableObject, NewRelationModuleOutput {
    
    @Published var relationFormatsData: RelationFormatsData?
    @Published var searchData: ObjectTypesLimitedSearchData?
    
    let data: NewRelationData
    
    private weak var output: (any NewRelationCoordinatorViewOutput)?
    
    init(data: NewRelationData, output: (any NewRelationCoordinatorViewOutput)?) {
        self.data = data
        self.output = output
    }
    
    // MARK: - NewRelationModuleOutput
    
    func didAskToShowRelationFormats(selectedFormat: SupportedRelationFormat, onSelect: @escaping (SupportedRelationFormat) -> Void) {
        relationFormatsData = RelationFormatsData(
            format: selectedFormat,
            onSelect: onSelect
        )
    }
    
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String], onSelect: @escaping ([String]) -> Void) {
        searchData = ObjectTypesLimitedSearchData(
            title: Loc.limitObjectTypes,
            spaceId: data.document.spaceId,
            selectedObjectTypesIds: selectedObjectTypesIds,
            onSelect: { ids in
                onSelect(ids)
            }
        )
    }
    
    func didCreateRelation(_ relation: RelationDetails) {
        output?.didCreateRelation(relation)
    }
    
}
