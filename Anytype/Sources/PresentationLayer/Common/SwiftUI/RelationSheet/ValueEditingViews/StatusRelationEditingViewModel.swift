import Foundation
import SwiftUI

final class StatusRelationEditingViewModel: ObservableObject {
    
    let allStatuses: [RelationValue.Status]
    @Published var selectedStatus: RelationValue.Status?
    
    private let key: String
    private let service: DetailsServiceProtocol
    
    init(
        allStatuses: [RelationValue.Status],
        selectedStatus: RelationValue.Status?,
        key: String,
        service: DetailsServiceProtocol
    ) {
        self.allStatuses = allStatuses
        self.selectedStatus = selectedStatus
        self.key = key
        self.service = service
    }
    
}

extension StatusRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        
    }
    
    func makeView() -> AnyView {
        AnyView(StatusRelationEditingView(viewModel: self))
    }
    
}
