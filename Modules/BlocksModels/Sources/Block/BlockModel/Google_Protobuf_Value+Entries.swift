import SwiftProtobuf
import AnytypeCore

extension Google_Protobuf_Value {
    
    func asStringEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for type String."
            )
            return nil
        }
        
        let trimmed = string.trimmed
        
        return DetailsEntry(value: trimmed)
    }
    
    func asBoolEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .boolValue(bool) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for type Bool"
            )
            return nil
        }
        return DetailsEntry(value: bool)
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
}
