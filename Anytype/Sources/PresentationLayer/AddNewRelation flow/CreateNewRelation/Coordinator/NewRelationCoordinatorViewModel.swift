import Foundation
import SwiftUI
import Services
import Combine

@MainActor
final class NewRelationCoordinatorViewModel: ObservableObject, NewRelationModuleOutput {
    
    @Published var relationFormatsData: RelationFormatsData?
    
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
    
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String]) {
        
    }
    
    func didCreateRelation(_ relation: RelationDetails) {
        
    }
    
    // MARK: - RelationFormatsListModuleOutput
    
    func didSelectFormat(_ format: SupportedRelationFormat) {
        
    }
    
}
