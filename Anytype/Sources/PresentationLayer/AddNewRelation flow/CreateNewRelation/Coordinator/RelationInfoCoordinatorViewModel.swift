import Foundation
import SwiftUI
import Services
import Combine

@MainActor
protocol RelationInfoCoordinatorViewOutput: AnyObject {
    func didPressConfirm(_ relation: RelationDetails)
}

@MainActor
final class RelationInfoCoordinatorViewModel: ObservableObject, RelationInfoModuleOutput {
    
    @Published var relationFormatsData: RelationFormatsData?
    @Published var searchData: ObjectTypesLimitedSearchData?
    
    let data: RelationInfoData
    
    private weak var output: (any RelationInfoCoordinatorViewOutput)?
    
    init(data: RelationInfoData, output: (any RelationInfoCoordinatorViewOutput)?) {
        self.data = data
        self.output = output
    }
    
    // MARK: - RelationInfoModuleOutput
    
    func didAskToShowRelationFormats(selectedFormat: SupportedRelationFormat, onSelect: @escaping (SupportedRelationFormat) -> Void) {
        relationFormatsData = RelationFormatsData(
            format: selectedFormat,
            onSelect: onSelect
        )
    }
    
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String], onSelect: @escaping ([String]) -> Void) {
        searchData = ObjectTypesLimitedSearchData(
            title: Loc.limitObjectTypes,
            spaceId: data.spaceId,
            selectedObjectTypesIds: selectedObjectTypesIds,
            onSelect: { ids in
                onSelect(ids)
            }
        )
    }
    
    func didPressConfirm(_ relation: RelationDetails) {
        output?.didPressConfirm(relation)
    }
    
}
