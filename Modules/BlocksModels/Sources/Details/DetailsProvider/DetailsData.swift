import Foundation

public struct DetailsData {
    
    // MARK: - Properties
    
    public let details: [DetailsKind: DetailsEntry<AnyHashable>]
    public let parentId: String
    
    // MARK: - Initialization
    
    public init(details: [DetailsKind: DetailsEntry<AnyHashable>], parentId: String) {
        self.details = details
        self.parentId = parentId
    }
    
}

// MARK: - DetailsInformationProvider

extension DetailsData: DetailsEntryValueProvider {
    
    public var name: String? {
        return value(for: .name)
    }
    
    public var iconEmoji: String? {
        return value(for: .iconEmoji)
    }
    
    public var iconImage: String? {
        return value(for: .iconImage)
    }
    
    public var coverId: String? {
        return value(for: .coverId)
    }
    
    public var coverType: CoverType? {
        return value(for: .coverType)
    }
    
    public var isArchived: Bool? {
        return value(for: .isArchived)
    }
    
    public var description: String? {
        return value(for: .description)
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
