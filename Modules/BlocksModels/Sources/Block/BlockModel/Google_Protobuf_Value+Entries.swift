import SwiftProtobuf
import AnytypeCore

extension Google_Protobuf_Value {
    
    func asNameEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.name)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asIconEmojiEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconEmoji)"
            )
            return nil
        }
        
        let trimmed = string.trimmed
        guard !trimmed.isEmpty else { return nil }
    
        return DetailsEntry(value: trimmed)
    }
    
    func asIconImageEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconImage)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asCoverIdEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverId)"
            )
            return nil
        }
        return DetailsEntry(value: string)
    }
    
    func asCoverTypeEntry() -> DetailsEntry<AnyHashable>? {
        guard let number = safeIntValue else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverType)"
            )
            return nil
        }
        
        guard let coverType = CoverType(rawValue: number) else { return nil }
        
        return DetailsEntry(value: coverType)
    }
    
    func asIsArchiveEntry() -> DetailsEntry<AnyHashable>? {
        guard case .boolValue(let isArchive) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.isArchived)"
            )
            return nil
        }
        
        return DetailsEntry(value: isArchive)
    }
    
    func asDescriptionEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.description)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asLayoutEntry() -> DetailsEntry<AnyHashable>? {
        guard let number = self.safeIntValue else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.layout)"
            )
            return nil
        }
        guard let layout = DetailsLayout(rawValue: number) else { return nil }
        
        return DetailsEntry(value: layout)
    }
    
    func asAlignmentEntry() -> DetailsEntry<AnyHashable>? {
        guard let number = self.safeIntValue else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.layoutAlign)"
            )
            return nil
        }
        guard let layout = LayoutAlignment(rawValue: number) else { return nil }
        
        return DetailsEntry(value: layout)
    }
    
    func asDoneEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .boolValue(bool) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.done)"
            )
            return nil
        }
        return DetailsEntry(value: bool)
    }
    
    func asTypeEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.type)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
}
