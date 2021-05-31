import Foundation

public protocol DetailsProviderProtocol: DetailsEntryValueProvider {
    
    var details: [ParentId: DetailsEntry<AnyHashable>] { get }
    
    var parentId: String? { get set }
    
}
