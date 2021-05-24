import Foundation

public protocol DetailsEntryValueProvider {
    
    subscript(kind: DetailsKind) -> String? { get }
    
}
