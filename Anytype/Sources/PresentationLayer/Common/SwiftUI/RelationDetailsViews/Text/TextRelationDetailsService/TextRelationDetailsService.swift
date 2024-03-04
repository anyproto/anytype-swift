import Foundation
import Services

final class TextRelationDetailsService: TextRelationDetailsServiceProtocol {

    private let objectId: String
    private let service: RelationsServiceProtocol
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    // MARK: - Initializers
    
    init(objectId: String, service: RelationsServiceProtocol) {
        self.objectId = objectId
        self.service = service
    }
    
    // MARK: - TextRelationDetailsServiceProtocol
    
    func saveRelation(value: String, key: String, textType: TextRelationDetailsViewType) {
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
