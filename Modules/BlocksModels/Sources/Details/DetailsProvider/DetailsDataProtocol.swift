import Foundation


// Update DetailsEntryConverter when adding new property
public protocol DetailsDataProtocol {
    
    var blockId: BlockId { get }
    var name: String? { get }
    var description: String? { get }
    var iconEmoji: String? { get }
    var iconImage: String? { get }
    var coverId: String? { get }
    var coverType: CoverType? { get }
    var isArchived: Bool? { get }
    var isFavorite: Bool? { get }
    var layout: DetailsLayout? { get }
    var layoutAlign: LayoutAlignment? { get }
    var done: Bool? { get }
    
    var typeUrl: String? { get }
    
    var rawDetails: RawDetailsData { get }
}
