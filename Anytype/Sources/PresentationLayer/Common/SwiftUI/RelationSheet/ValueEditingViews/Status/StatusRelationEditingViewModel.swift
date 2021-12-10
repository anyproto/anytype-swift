import Foundation
import SwiftUI
import BlocksModels

final class StatusRelationEditingViewModel: ObservableObject {

    @Published var selectedStatus: RelationValue.Status?
    @Published var statusSections: [RelationValueStatusSection]
    
    private let relationOptions: [RelationMetadata.Option]
    private let relationKey: String
    private let detailsService: DetailsServiceProtocol
    
    init(
        relationKey: String,
        relationOptions: [RelationMetadata.Option],
        selectedStatus: RelationValue.Status?,
        detailsService: DetailsServiceProtocol
    ) {
        self.relationOptions = relationOptions
        self.relationKey = relationKey
        self.statusSections = RelationValueStatusSectionBuilder.sections(
            from: relationOptions,
            filterText: nil
        )
        self.selectedStatus = selectedStatus
        self.detailsService = detailsService
    }
    
}

extension StatusRelationEditingViewModel {
    
    func filterStatusSections(text: String) {
        self.statusSections = RelationValueStatusSectionBuilder.sections(
            from: relationOptions,
            filterText: text
        )
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
