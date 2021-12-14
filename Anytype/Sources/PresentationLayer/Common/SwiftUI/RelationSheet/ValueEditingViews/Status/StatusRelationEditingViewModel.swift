import Foundation
import SwiftUI
import BlocksModels

final class StatusRelationEditingViewModel: ObservableObject {

    @Published var selectedStatus: RelationValue.Status?
    @Published var statusSections: [RelationValueStatusSection]
    
    private let relationOptions: [RelationMetadata.Option]
    private let relationKey: String
    private let detailsService: DetailsServiceProtocol
    private let relationsService: RelationsServiceProtocol
    
    init(
        relationKey: String,
        relationOptions: [RelationMetadata.Option],
        selectedStatus: RelationValue.Status?,
        detailsService: DetailsServiceProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.relationOptions = relationOptions
        self.relationKey = relationKey
        self.statusSections = RelationValueStatusSectionBuilder.sections(
            from: relationOptions,
            filterText: nil
        )
        self.selectedStatus = selectedStatus
        self.detailsService = detailsService
        self.relationsService = relationsService
    }
    
}

extension StatusRelationEditingViewModel {
    
    func filterStatusSections(text: String) {
        self.statusSections = RelationValueStatusSectionBuilder.sections(
            from: relationOptions,
            filterText: text
        )
    }
    
    func addOption(text: String) {
        let optionId = relationsService.addRelationOption(relationKey: relationKey, optionText: text)
        guard let optionId = optionId else { return}

        detailsService.updateDetails([
            DetailsUpdate(key: relationKey, value: optionId.protobufValue)
        ])
    }
    
}

extension StatusRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func viewWillDisappear() {}
    
    func saveValue() {
        detailsService.updateDetails([
            DetailsUpdate(key: relationKey, value: selectedStatus?.id.protobufValue ?? nil)
        ])
    }
    
    func makeView() -> AnyView {
        AnyView(StatusRelationEditingView(viewModel: self))
    }
    
}
