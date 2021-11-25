import Foundation
import BlocksModels

final class TextRelationEditingService {
    
    let valueType: TextRelationValueType
    private let service: DetailsService
    
    init(objectId: BlockId, valueType: TextRelationValueType) {
        self.service = DetailsService(objectId: objectId)
        self.valueType = valueType
    }
    
}

extension TextRelationEditingService: TextRelationEditingServiceProtocol {

    func save(value: String, forKey key: String) {
        switch valueType {
        case .text:
            service.updateDetails([DetailsUpdate(key: key, value: value.protobufValue)])
        case .number:
            let filterredString = value.components(
                separatedBy:CharacterSet(charactersIn: "0123456789.").inverted
            )
                .joined()
            
            guard let number = Double(filterredString) else { return }
            service.updateDetails([DetailsUpdate(key: key, value: number.protobufValue)])
        case .phone:
            return
        case .email:
            return
        case .url:
            return
        }
    }
    
}
