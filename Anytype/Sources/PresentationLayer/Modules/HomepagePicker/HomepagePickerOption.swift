import Foundation

enum HomepagePickerOption: Identifiable, Equatable {
    case widgets
    case object(ObjectHomepageType)

    var id: String {
        switch self {
        case .widgets: return "widgets"
        case .object(let type): return type.rawValue
        }
    }

    var title: String {
        switch self {
        case .widgets: return Loc.SpaceSettings.HomePage.widgets
        case .object(let type): return type.title
        }
    }

    static var allCases: [HomepagePickerOption] {
        [.object(.chat), .widgets, .object(.page), .object(.collection)]
    }
}

extension HomepagePickerOption {
    var analyticsType: CreateHomePageType {
        switch self {
        case .widgets: return .empty
        case .object(let type):
            switch type {
            case .chat: return .chat
            case .page: return .page
            case .collection: return .collection
            }
        }
    }
}

enum ObjectHomepageType: String, CaseIterable {
    case chat
    case page
    case collection

    var title: String {
        switch self {
        case .chat: return Loc.chat
        case .page: return Loc.page
        case .collection: return Loc.collection
        }
    }
}
