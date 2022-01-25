import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class StatusRelationDetailsViewModel: ObservableObject {

    var layoutPublisher: Published<FloatingPanelLayout>.Publisher { $layout }
    @Published private var layout: FloatingPanelLayout = RelationOptionsPopupLayout()
    
    var onDismiss: () -> Void = {}
    
    @Published var isPresented: Bool = false

    @Published var selectedStatus: Relation.Status.Option? {
        didSet {
            saveValue()
        }
    }
    
    @Published var sections: [RelationOptionsSection<Relation.Status.Option>]
    
    private let allStatuses: [Relation.Status.Option]
    
    private let relation: Relation
    private let service: RelationsServiceProtocol
    
    init(
        selectedStatus: Relation.Status.Option?,
        allStatuses: [Relation.Status.Option],
        relation: Relation,
        service: RelationsServiceProtocol
    ) {
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
        let optionId = service.addRelationOption(relationKey: relation.id, optionText: text)
        guard let optionId = optionId else { return}
        
        service.updateRelation(relationKey: relation.id, value: optionId.protobufValue)
        withAnimation {
            isPresented = false
        }
    }
    
    func saveValue() {
        service.updateRelation(relationKey: relation.id, value: selectedStatus?.id.protobufValue ?? nil)
    }
    
}

extension StatusRelationDetailsViewModel: RelationDetailsViewModelProtocol {
    
    func makeViewController() -> UIViewController {
        UIHostingController(rootView: StatusRelationDetailsView(viewModel: self))
    }
    
}

extension StatusRelationDetailsViewModel: RelationEditingViewModelProtocol {
  
    func makeView() -> AnyView {
        AnyView(StatusRelationDetailsView(viewModel: self))
    }
    
}
