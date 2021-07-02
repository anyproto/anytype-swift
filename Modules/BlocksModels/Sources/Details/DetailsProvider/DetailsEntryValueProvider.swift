import Foundation

public protocol DetailsEntryValueProvider {
    
    var name: String? { get }
    var iconEmoji: String? { get }
    var iconImage: String? { get }
    var coverId: String? { get }
    var coverType: CoverType? { get }
    var isArchived: Bool? { get }
    var layout: DetailsLayout? { get }
    
}
