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
    
    let name: String
    let document: BaseDocumentProtocol
    let target: RelationsModuleTarget
    
    private weak var output: NewRelationCoordinatorViewOutput?
    
    init(
        name: String,
        document: BaseDocumentProtocol,
        target: RelationsModuleTarget,
        output: NewRelationCoordinatorViewOutput?
    ) {
        self.name = name
        self.document = document
        self.target = target
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
            spaceId: document.spaceId,
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
