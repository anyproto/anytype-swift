import Foundation
import SwiftUI
import BlocksModels

final class StatusRelationEditingViewModel: ObservableObject {

    var onDismiss: (() -> Void)?
    
    @Published var isPresented: Bool = false
    @Published var selectedStatus: RelationValue.Status?
    @Published var statusSections: [RelationValueStatusSection]
    
    let relationName: String
    
    private let relationOptions: [RelationMetadata.Option]
    private let relationKey: String
    private let detailsService: DetailsServiceProtocol
    private let relationsService: RelationsServiceProtocol
    
    init(
        relationKey: String,
        relationName: String,
        relationOptions: [RelationMetadata.Option],
        selectedStatus: RelationValue.Status?,
        detailsService: DetailsServiceProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.relationKey = relationKey
        self.relationName = relationName
        self.relationOptions = relationOptions
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
        
        withAnimation {
            isPresented = false
        }
    }
    
}

extension StatusRelationEditingViewModel: RelationEditingViewModelProtocol2 {}
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
