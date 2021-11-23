import Foundation
import BlocksModels
import SwiftUI

final class RelationTextValueEditingViewModel: ObservableObject {
    
    @Published var value: String = ""
    
    private let relationKey: String
    private let service: DetailsService
    
    init(objectId: BlockId, relationKey: String, value: String?) {
        self.service = DetailsService(objectId: objectId)
        self.relationKey = relationKey
        self.value = value ?? ""
    }
    
}

extension RelationTextValueEditingViewModel: RelationValueEditingViewModelProtocol {
    
    func saveValue() {
        service.updateDetails([DetailsUpdate(key: relationKey, value: value.protobufValue)])
    }
    
    func makeView() -> AnyView {
        AnyView(RelationTextValueEditingView(viewModel: self))
    }
    
}
