import Foundation

public struct InformationAccessor {
    private var value: DetailsInformationModelProtocol
    
    public var title: DetailsContent.Title? {
        switch self.value.details[DetailsContent.Title.id] {
        case let .title(value): return value
        default: return nil
        }
    }
    
    public var iconEmoji: DetailsContent.Emoji? {
        switch self.value.details[DetailsContent.Emoji.id] {
        case let .iconEmoji(value): return value
        default: return nil
        }
    }
    
    public var iconColor: DetailsContent.OurHexColor? {
        switch self.value.details[DetailsContent.OurHexColor.id] {
        case let .iconColor(value): return value
        default: return nil
        }
    }
    
    public var iconImage: DetailsContent.ImageId? {
        switch self.value.details[DetailsContent.ImageId.id] {
        case let .iconImage(value): return value
        default: return nil
        }
    }
    
    // MARK: - Memberwise Initializer
    public init(value: DetailsInformationModelProtocol) {
        self.value = value
    }
}
