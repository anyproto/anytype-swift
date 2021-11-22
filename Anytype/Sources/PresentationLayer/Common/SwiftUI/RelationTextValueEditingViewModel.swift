import Foundation
import BlocksModels

final class RelationTextValueEditingViewModel: ObservableObject {
    
    @Published var value: String = ""
    
    private let relationKey: String
    private let service: DetailsService
    
    init(objectId: BlockId, relationKey: String, value: String) {
        self.service = DetailsService(objectId: objectId)
        self.relationKey = relationKey
        self.value = value
        
    }
    
    func saveValue() {
        service.updateRelationValue(key: relationKey, value: value.protobufValue)
    }
    
}
