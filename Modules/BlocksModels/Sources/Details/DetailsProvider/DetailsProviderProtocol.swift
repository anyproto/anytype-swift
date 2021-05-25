import Foundation

public protocol DetailsProviderProtocol: DetailsEntryValueProvider {
    
    var details: [DetailsId: DetailsEntry<AnyHashable>] { get }
    
    var parentId: String? { get set }
    
}
