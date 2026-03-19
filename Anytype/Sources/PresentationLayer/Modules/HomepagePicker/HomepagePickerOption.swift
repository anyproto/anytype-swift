import Foundation
import Services

enum HomepagePickerOption: String, CaseIterable, Identifiable {
    case chat
    case widgets
    case page
    case collection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: return Loc.chat
        case .widgets: return Loc.SpaceSettings.HomePage.widgets
        case .page: return Loc.page
        case .collection: return Loc.collection
        }
    }

    /// Returns the ObjectTypeUniqueKey for options that create objects.
    /// Widgets does not create an object.
    var objectTypeKey: ObjectTypeUniqueKey? {
        switch self {
        case .chat: return .chatDerived
        case .widgets: return nil
        case .page: return .page
        case .collection: return .collection
        }
    }
}
