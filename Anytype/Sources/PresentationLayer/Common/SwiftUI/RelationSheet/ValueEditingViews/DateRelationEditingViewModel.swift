import Foundation
import SwiftUI

final class DateRelationEditingViewModel: ObservableObject {
    
    @Published var values: [DateRelationValue] = DateRelationValue.allCases
    @Published var selectedValues: DateRelationValue? = nil
    
    private let service: DetailsServiceProtocol
    private let key: String
    
    init(
        service: DetailsServiceProtocol,
        key: String,
        value: String?
    ) {
        self.service = service
        self.key = key
    }
    
}

extension DateRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        
    }
    
    func makeView() -> AnyView {
        AnyView(DateRelationEditingView(viewModel: self))
    }
    
    
}
