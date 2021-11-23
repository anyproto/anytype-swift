import Foundation
import BlocksModels
import SwiftUI

final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var value: String = ""
    
    private let relationKey: String
    private let service: DetailsService
    
    init(objectId: BlockId, relationKey: String, value: String?) {
        self.service = DetailsService(objectId: objectId)
        self.relationKey = relationKey
        self.value = value ?? ""
    }
    
}

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        service.updateDetails([DetailsUpdate(key: relationKey, value: value.protobufValue)])
    }
    
    func makeView() -> AnyView {
        AnyView(TextRelationEditingView(viewModel: self))
    }
    
}
