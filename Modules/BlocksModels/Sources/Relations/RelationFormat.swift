
import Foundation

public extension Relation {
    
    enum Format: String, Hashable {
        case shortText = "Short text"
        case longText = "Text"
        case number = "Number"
        case status = "Status"
        case tag = "Tag"
        case date = "Date"
        case file = "File"
        case checkbox = "Checkbox"
        case url = "URL"
        case email = "Email"
        case phone = "Phone number"
        case emoji = "Emoji"
        case object = "Object"
        case relations = "Relations"
    }
    
}
