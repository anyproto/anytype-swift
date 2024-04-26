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
    @Published var newSearchData: NewSearchData?
    
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
        newSearchData = NewSearchData(
            selectedObjectTypesIds: selectedObjectTypesIds,
            onSelect: { [weak self] ids in
                self?.newSearchData = nil
                onSelect(ids)
            }
        )
    }
    
    func didCreateRelation(_ relation: RelationDetails) {
        output?.didCreateRelation(relation)
    }
    
}

extension NewRelationCoordinatorViewModel {
    struct NewSearchData: Identifiable {
        let id = UUID()
        let selectedObjectTypesIds: [String]
        let onSelect: (_ ids: [String]) -> Void
    }
}
