import UIKit

enum EditorAccessory {
    enum Item {
        case menuItems([MenuItem])
        case changeType(isOpened: Bool)
    }

    struct MenuItem {
        enum MenuItemType {
            case mention
            case slash
            case style

            var image: UIImage {
                switch self {
                case .mention:
                    return UIImage.edititngToolbar.mention
                case .slash:
                    return UIImage.edititngToolbar.addNew
                case .style:
                    return UIImage.edititngToolbar.style
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
                }
            }
        }

        let action: () -> Void
        let type: MenuItemType
    }
}
