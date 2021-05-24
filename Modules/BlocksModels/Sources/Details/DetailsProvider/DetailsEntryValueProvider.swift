import Foundation

public protocol DetailsEntryValueProvider {
    
    func value(for kind: DetailsKind) -> String?
    
}
