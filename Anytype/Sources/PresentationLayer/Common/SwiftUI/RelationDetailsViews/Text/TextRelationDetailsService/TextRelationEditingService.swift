import Foundation
import Services

protocol TextRelationEditingServiceProtocol: AnyObject {
    func saveRelation(objectId: String, value: String, key: String, textType: TextRelationDetailsViewType)
}

final class TextRelationEditingService: TextRelationEditingServiceProtocol {

    @Injected(\.relationsService)
    private var service: RelationsServiceProtocol
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    // MARK: - TextRelationDetailsServiceProtocol
    
    func saveRelation(objectId: String, value: String, key: String, textType: TextRelationDetailsViewType) {
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
