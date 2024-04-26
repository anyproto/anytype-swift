import Foundation
import SwiftUI
import Services
import Combine

@MainActor
final class NewRelationCoordinatorViewModel: ObservableObject, NewRelationModuleOutput {
    
    @Published var relationFormatsData: RelationFormatsData?
    @Published var newSearchData: NewSearchData?
    
    let name: String
    let document: BaseDocumentProtocol
    let target: RelationsModuleTarget
    
    init(
        name: String,
        document: BaseDocumentProtocol,
        target: RelationsModuleTarget
    ) {
        self.name = name
        self.document = document
        self.target = target
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
        // TODO
    }
    
}

extension NewRelationCoordinatorViewModel {
    struct NewSearchData: Identifiable {
        let id = UUID()
        let selectedObjectTypesIds: [String]
        let onSelect: (_ ids: [String]) -> Void
    }
}
