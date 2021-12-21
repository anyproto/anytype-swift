import Foundation
import BlocksModels

final class TextRelationEditingService {
    
    let valueType: TextRelationValueType
    private let service: RelationsServiceProtocol
    
    init(objectId: BlockId, valueType: TextRelationValueType) {
        self.service = RelationsService(objectId: objectId)
        self.valueType = valueType
    }
    
}

extension TextRelationEditingService: TextRelationEditingServiceProtocol {

    func save(value: String, forKey key: String) {
        switch valueType {
        case .text, .phone, .email, .url:
            service.updateRelation(relationKey: key, value: value.protobufValue)
            
        case .number:
            let filterredString = value.components(
                separatedBy:CharacterSet(charactersIn: "0123456789.").inverted
            )
                .joined()
            
            guard let number = Double(filterredString) else { return }
            service.updateRelation(relationKey: key, value: number.protobufValue)
        }
    }
    
}
