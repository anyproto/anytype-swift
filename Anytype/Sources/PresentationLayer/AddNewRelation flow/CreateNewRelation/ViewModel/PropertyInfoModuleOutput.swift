import Foundation
import Services

@MainActor
protocol PropertyInfoModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats(
        selectedFormat: SupportedRelationFormat,
        onSelect: @escaping (SupportedRelationFormat) -> Void
    )
    func didAskToShowObjectTypesSearch(
        selectedObjectTypesIds: [String],
        onSelect: @escaping ([String]) -> Void
    )
    func didPressConfirm(_ relation: RelationDetails)
    
}
