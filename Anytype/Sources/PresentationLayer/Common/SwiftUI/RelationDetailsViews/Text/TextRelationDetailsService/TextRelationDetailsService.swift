import Foundation

final class TextRelationDetailsService {

    private let service: RelationsServiceProtocol
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    // MARK: - Initializers
    
    init(service: RelationsServiceProtocol) {
        self.service = service
    }
    
}

// MARK: - TextRelationDetailsServiceProtocol

extension TextRelationDetailsService: TextRelationDetailsServiceProtocol {
    
    func saveRelation(value: String, key: String, textType: TextRelationDetailsViewType) {
        Task {
            switch textType {
            case .text:
                try await service.updateRelation(relationKey: key, value: value.protobufValue)
            case .number, .numberOfDays:
                guard let number = numberFormatter.number(from: value)?.doubleValue else { return }
                try await service.updateRelation(relationKey: key, value: number.protobufValue)
            case .phone, .email, .url:
                let value = value.replacingOccurrences(of: " ", with: "")
                try await service.updateRelation(relationKey: key, value: value.protobufValue)
            }
        }
    }
}
