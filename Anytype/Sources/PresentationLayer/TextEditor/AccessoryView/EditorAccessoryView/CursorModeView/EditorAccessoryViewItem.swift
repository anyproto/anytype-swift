import UIKit

extension EditorAccessoryView {
    enum Item {
        case mention
        case slash
        case style
        case actions

        var image: UIImage {
            switch self {
            case .mention:
                return UIImage.edititngToolbar.mention
            case .slash:
                return UIImage.edititngToolbar.addNew
            case .style:
                return UIImage.edititngToolbar.style
            case .actions:
                return UIImage.edititngToolbar.actions
            }
        }

        var action: EditorAccessoryViewAction {
            switch self {
            case .mention:
                return .mention
            case .slash:
                return .slashMenu
            case .style:
                return .showStyleMenu
            case .actions:
                return .editingMode
            }
        }

        var analyticsEvent: String {
            switch self {
            case .mention:
                return AmplitudeEventsName.buttonMentionMenu
            case .slash:
                return AmplitudeEventsName.buttonSlashMenu
            case .style:
                return AmplitudeEventsName.buttonStyleMenu
            case .actions:
                return ""
            }
        }
    }
}
