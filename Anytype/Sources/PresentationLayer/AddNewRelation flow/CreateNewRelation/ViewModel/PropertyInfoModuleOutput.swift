import Foundation
import Services

@MainActor
protocol PropertyInfoModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats(
        selectedFormat: SupportedPropertyFormat,
        onSelect: @escaping (SupportedPropertyFormat) -> Void
    )
    func didAskToShowObjectTypesSearch(
        selectedObjectTypesIds: [String],
        onSelect: @escaping ([String]) -> Void
    )
    func didPressConfirm(_ relation: RelationDetails)
    
}
