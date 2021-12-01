import Foundation
import SwiftUI

final class StatusRelationEditingViewModel: ObservableObject {
    
    @Published var selectedValue: RelationValue.Status?
    let values: [RelationValue.Status]
    
    private let service: DetailsServiceProtocol
    private let key: String
    
    init(
        service: DetailsServiceProtocol,
        key: String,
        allValues: [RelationValue.Status],
        value: RelationValue.Status?
    ) {
        self.service = service
        self.key = key
        self.values = allValues
        self.selectedValue = value
    }
    
}

extension StatusRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        
    }
    
    func makeView() -> AnyView {
        AnyView(StatusRelationEditingView(viewModel: self))
    }
    
}
