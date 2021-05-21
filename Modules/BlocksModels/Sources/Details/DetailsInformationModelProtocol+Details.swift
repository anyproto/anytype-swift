import Foundation

public protocol DetailsInformationProvider {
    var name: DetailsContent.Name? { get }
    var iconEmoji: DetailsContent.Emoji? { get }
    var iconImage: DetailsContent.ImageId? { get }
}


// DetailsInformationProvider
extension DetailsInformationModel {
    var name: DetailsContent.Name? {
        switch details[DetailsContent.Name.id] {
        case let .name(value): return value
        default: return nil
        }
    }
    
    var iconEmoji: DetailsContent.Emoji? {
        switch self.details[DetailsContent.Emoji.id] {
        case let .iconEmoji(value): return value
        default: return nil
        }
    }
    
    var iconImage: DetailsContent.ImageId? {
        switch self.details[DetailsContent.ImageId.id] {
        case let .iconImage(value): return value
        default: return nil
        }
    }
}
