import Foundation
import SwiftUI
import Services
import Combine

@MainActor
protocol PropertyInfoCoordinatorViewOutput: AnyObject {
    func didPressConfirm(_ relation: RelationDetails)
}

@MainActor
final class PropertyInfoCoordinatorViewModel: ObservableObject, PropertyInfoModuleOutput {
    
    @Published var relationFormatsData: PropertyFormatsData?
    @Published var searchData: ObjectTypesLimitedSearchData?
    
    let data: PropertyInfoData
    
    private weak var output: (any PropertyInfoCoordinatorViewOutput)?
    
    init(data: PropertyInfoData, output: (any PropertyInfoCoordinatorViewOutput)?) {
        self.data = data
        self.output = output
    }
    
    // MARK: - PropertyInfoModuleOutput
    
    func didAskToShowRelationFormats(selectedFormat: SupportedPropertyFormat, onSelect: @escaping (SupportedPropertyFormat) -> Void) {
        relationFormatsData = PropertyFormatsData(
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
