import Foundation

public struct DetailsData {
    
    public let details: [DetailsKind: DetailsEntry<AnyHashable>]
    public let parentId: String
    
    public init(details: [DetailsKind: DetailsEntry<AnyHashable>], parentId: String) {
        self.details = details
        self.parentId = parentId
    }
    
}

// MARK: - DetailsInformationProvider

extension DetailsData: DetailsDataProtocol {
    
    public var name: String? {
        value(for: .name)
    }
    
    public var iconEmoji: String? {
        value(for: .iconEmoji)
    }
    
    public var iconImage: String? {
        value(for: .iconImage)
    }
    
    public var coverId: String? {
        value(for: .coverId)
    }
    
    public var coverType: CoverType? {
        value(for: .coverType)
    }
    
    public var isArchived: Bool? {
        value(for: .isArchived)
    }
    
    public var description: String? {
        value(for: .description)
    }
    
    public var layout: DetailsLayout? {
        value(for: .layout)
    }
    
    public var alignment: LayoutAlignment? {
        value(for: .alignment)
    }
    
    private func value<V>(for kind: DetailsKind) -> V? {
        guard let entry = details[kind] else {
            return nil
        }
        
        return entry.value as? V
    }

}

// MARK: Hashable
extension DetailsData: Hashable {}
