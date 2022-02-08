import Foundation
import SwiftUI
import BlocksModels

final class StatusRelationEditingViewModel: ObservableObject {

    var onDismiss: () -> Void = {}
    
    @Published var isPresented: Bool = false
    @Published var selectedStatus: Relation.Status.Option?
    @Published var statusSections: [RelationOptionsSection<Relation.Status.Option>]
    
    let relationName: String
    
    private let relationOptions: [Relation.Status.Option]
    private let relationKey: String
    private let relationsService: RelationsServiceProtocol
    
    init(
        relationKey: String,
        relationName: String,
        relationOptions: [Relation.Status.Option],
        selectedStatus: Relation.Status.Option?,
        relationsService: RelationsServiceProtocol
    ) {
        self.relationKey = relationKey
        self.relationName = relationName
        self.relationOptions = relationOptions
        self.statusSections = RelationOptionsSectionBuilder.sections(from: relationOptions, filterText: nil)
        self.selectedStatus = selectedStatus
        self.relationsService = relationsService
    }
    
}

extension StatusRelationEditingViewModel {
    
    func filterStatusSections(text: String) {
        self.statusSections = RelationOptionsSectionBuilder.sections(from: relationOptions, filterText: text)
    }
    
    func addOption(text: String) {
        let optionId = relationsService.addRelationOption(relationKey: relationKey, optionText: text)
        guard let optionId = optionId else { return}
        
        relationsService.updateRelation(relationKey: relationKey, value: optionId.protobufValue)
        withAnimation {
            isPresented = false
        }
    }
    
    func saveValue() {
        relationsService.updateRelation(relationKey: relationKey, value: selectedStatus?.id.protobufValue ?? nil)
    }
}

extension StatusRelationEditingViewModel: RelationEditingViewModelProtocol {
  
    func makeView() -> AnyView {
        AnyView(StatusRelationEditingView(viewModel: self))
    }
    
}
