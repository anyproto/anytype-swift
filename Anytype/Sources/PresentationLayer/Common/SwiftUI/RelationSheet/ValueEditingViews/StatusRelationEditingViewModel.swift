import Foundation
import SwiftUI
import BlocksModels

final class StatusRelationEditingViewModel: ObservableObject {

    @Published var selectedStatus: RelationValue.Status?

    let allStatuses: [RelationValue.Status]
    
    private let relationKey: String
    private let detailsService: DetailsServiceProtocol
    
    init(
        relationKey: String,
        relationOptions: [RelationMetadata.Option],
        selectedStatus: RelationValue.Status?,
        detailsService: DetailsServiceProtocol
    ) {
        self.relationKey = relationKey
        self.allStatuses = relationOptions.map { RelationValue.Status(option: $0) }
        self.selectedStatus = selectedStatus
        self.detailsService = detailsService
    }
    
}

extension StatusRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        
    }
    
    func makeView() -> AnyView {
        AnyView(StatusRelationEditingView(viewModel: self))
    }
    
}
