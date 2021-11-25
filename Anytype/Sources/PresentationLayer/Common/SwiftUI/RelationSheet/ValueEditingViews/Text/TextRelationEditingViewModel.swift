import Foundation
import BlocksModels
import SwiftUI

final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var value: String = ""
    let valueType: TextRelationValueType
    
    private let service: TextRelationEditingServiceProtocol
    private let key: String
    
    init(
        service: TextRelationEditingServiceProtocol,
        key: String,
        value: String?
    ) {
        self.service = service
        self.key = key
        self.value = value ?? ""
        self.valueType = service.valueType
    }
    
}

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        service.save(value: value, forKey: key)
    }
    
    func makeView() -> AnyView {
        AnyView(TextRelationEditingView(viewModel: self))
    }
    
}
