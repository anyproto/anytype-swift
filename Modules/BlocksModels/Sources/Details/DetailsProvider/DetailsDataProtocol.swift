import Foundation

public protocol DetailsDataProtocol {
    
    var name: String? { get }
    var iconEmoji: String? { get }
    var iconImage: String? { get }
    var coverId: String? { get }
    var coverType: CoverType? { get }
    var isArchived: Bool? { get }
    var layout: DetailsLayout? { get }
    var layoutAlign: LayoutAlignment? { get }
    var done: Bool? { get }
    var typeUrl: String? { get }
    
}
