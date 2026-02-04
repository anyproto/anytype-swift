import Foundation
import SwiftUI
import Services

@MainActor
protocol PropertyInfoCoordinatorViewOutput: AnyObject {
    func didPressConfirm(_ relation: PropertyDetails)
}

@MainActor
@Observable
final class PropertyInfoCoordinatorViewModel: PropertyInfoModuleOutput {

    var propertyFormatsData: PropertyFormatsData?
    var searchData: ObjectTypesLimitedSearchData?
    
    let data: PropertyInfoData
    
    private weak var output: (any PropertyInfoCoordinatorViewOutput)?
    
    init(data: PropertyInfoData, output: (any PropertyInfoCoordinatorViewOutput)?) {
        self.data = data
        self.output = output
    }
    
    // MARK: - PropertyInfoModuleOutput
    
    func didAskToShowPropertyFormats(selectedFormat: SupportedPropertyFormat, onSelect: @escaping (SupportedPropertyFormat) -> Void) {
        propertyFormatsData = PropertyFormatsData(
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
    
    func didPressConfirm(_ relation: PropertyDetails) {
        output?.didPressConfirm(relation)
    }
    
}
