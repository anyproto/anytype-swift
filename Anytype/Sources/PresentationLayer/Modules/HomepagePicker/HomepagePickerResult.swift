import Foundation

enum HomepagePickerResult {
    case homepageSet(HomepageValue)
    case later
}

enum HomepageValue {
    case widgets
    case object(id: String)
}
