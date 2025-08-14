import Foundation
import Services

protocol TextPropertyEditingServiceProtocol: AnyObject, Sendable {
    func saveRelation(objectId: String, value: String, key: String, textType: TextPropertyViewType)
}

final class TextPropertyEditingService: TextPropertyEditingServiceProtocol, Sendable {

    private let service: any PropertiesServiceProtocol = Container.shared.propertiesService()
    
    private let numberFormatter = NumberFormatter.decimalWithNoSeparator
    
    // MARK: - TextRelationDetailsServiceProtocol
    
    func saveRelation(objectId: String, value: String, key: String, textType: TextPropertyViewType) {
        Task {
            switch textType {
            case .text:
                try await service.updateProperty(objectId: objectId, propertyKey: key, value: value.protobufValue)
            case .number, .numberOfDays:
                guard let number = numberFormatter.number(from: value)?.doubleValue else { return }
                try await service.updateProperty(objectId: objectId, propertyKey: key, value: number.protobufValue)
            case .phone, .email, .url:
                let value = value.replacingOccurrences(of: " ", with: "")
                try await service.updateProperty(objectId: objectId, propertyKey: key, value: value.protobufValue)
            }
        }
    }
}
