import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class StatusRelationDetailsViewModel: ObservableObject {
    
    let source: RelationSource
        
    private weak var delegate: AnytypePopupContentDelegate?
    
    let popupLayout: FloatingPanelLayout = FullScreenHeightPopupLayout()

    @Published var selectedStatus: Relation.Status.Option? {
        didSet {
            saveValue(selectedStatus?.id)
        }
    }
    
    @Published var sections: [RelationOptionsSection<Relation.Status.Option>]
    
    private let allStatuses: [Relation.Status.Option]
    
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    init(
        source: RelationSource,
        selectedStatus: Relation.Status.Option?,
        allStatuses: [Relation.Status.Option],
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
        self.source = source
        
        self.selectedStatus = selectedStatus
        self.allStatuses = allStatuses
        
        self.relation = relation
        self.service = service
        
        self.sections = RelationOptionsSectionBuilder.sections(from: allStatuses)
    }
    
}

extension StatusRelationDetailsViewModel {
    
    func filterStatuses(text: String) {
        guard text.isNotEmpty else {
            self.sections = RelationOptionsSectionBuilder.sections(from: allStatuses)
            return
        }
        
        let filteredStatuses: [Relation.Status.Option] = allStatuses.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }
        
        self.sections = RelationOptionsSectionBuilder.sections(from: filteredStatuses)
    }
    
    func addOption(text: String) {
        let optionId = service.addRelationOption(source: source, relationKey: relation.id, optionText: text)
        guard let optionId = optionId else { return}
        
        saveValue(optionId)
    }
    
    func saveValue(_ statusId: String?) {
        service.updateRelation(relationKey: relation.id, value: statusId?.protobufValue ?? nil)
        delegate?.didAskToClose()
    }
    
}

extension StatusRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(rootView: StatusRelationDetailsView(viewModel: self))
    }
    
    func setContentDelegate(_ сontentDelegate: AnytypePopupContentDelegate) {
        delegate = сontentDelegate
    }
    
}
