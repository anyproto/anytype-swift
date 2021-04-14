import Foundation

public protocol DetailsInformationProvider {
    var title: DetailsContent.Title? { get }
    var iconEmoji: DetailsContent.Emoji? { get }
    var iconColor: DetailsContent.OurHexColor? { get }
    var iconImage: DetailsContent.ImageId? { get }
}


// DetailsInformationProvider
extension DetailsInformationModel {
    var title: DetailsContent.Title? {
        switch details[DetailsContent.Title.id] {
        case let .title(value): return value
        default: return nil
        }
    }
    
    var iconEmoji: DetailsContent.Emoji? {
        switch self.details[DetailsContent.Emoji.id] {
        case let .iconEmoji(value): return value
        default: return nil
        }
    }
    
    var iconColor: DetailsContent.OurHexColor? {
        switch self.details[DetailsContent.OurHexColor.id] {
        case let .iconColor(value): return value
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
