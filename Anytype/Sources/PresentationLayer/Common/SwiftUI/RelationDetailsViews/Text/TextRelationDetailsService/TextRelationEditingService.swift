import Foundation
import Services

protocol TextRelationEditingServiceProtocol: AnyObject {
    func saveRelation(objectId: String, value: String, key: String, textType: TextRelationViewType)
}

final class TextRelationEditingService: TextRelationEditingServiceProtocol {

    @Injected(\.relationsService)
    private var service: any RelationsServiceProtocol
    
    private let numberFormatter = NumberFormatter.default
    
    // MARK: - TextRelationDetailsServiceProtocol
    
    func saveRelation(objectId: String, value: String, key: String, textType: TextRelationViewType) {
        Task {
            switch textType {
            case .text:
                try await service.updateRelation(objectId: objectId, relationKey: key, value: value.protobufValue)
            case .number, .numberOfDays:
                guard let number = numberFormatter.number(from: value)?.doubleValue else { return }
                try await service.updateRelation(objectId: objectId, relationKey: key, value: number.protobufValue)
            case .phone, .email, .url:
                let value = value.replacingOccurrences(of: " ", with: "")
                try await service.updateRelation(objectId: objectId, relationKey: key, value: value.protobufValue)
            }
        }
    }
}
