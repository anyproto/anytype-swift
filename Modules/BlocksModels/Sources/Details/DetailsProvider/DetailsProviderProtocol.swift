import Foundation

public protocol DetailsProviderProtocol: DetailsEntryValueProvider {
    
    var details: [DetailsId: DetailsEntry] { get }
    
    var parentId: String? { get set }
    
}
