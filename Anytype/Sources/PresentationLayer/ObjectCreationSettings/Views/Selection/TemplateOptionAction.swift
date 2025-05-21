import SwiftUI

enum TemplateOptionAction: Hashable {
    case editTemplate
    case duplicate
    case delete
    case toggleIsDefault(currentlyDefault: Bool)
    
    static func listActions(isDefault: Bool) -> [TemplateOptionAction] {
        [
            .editTemplate,
            .duplicate,
            .delete
        ]
    }
    
    static func typeActions(isDefault: Bool) -> [TemplateOptionAction] {
        [
            .toggleIsDefault(currentlyDefault: isDefault),
            .duplicate,
            .delete
        ]
    }
    
    
    var title: String {
        switch self {
        case .editTemplate:
            return Loc.TemplateOptions.Alert.editTemplate
        case .duplicate:
            return Loc.TemplateOptions.Alert.duplicate
        case .delete:
            return Loc.TemplateOptions.Alert.delete
        case .toggleIsDefault(let currentlyDefault):
            if currentlyDefault {
                return Loc.unsetAsDefault
            } else {
                return Loc.setAsDefault
            }
        }
    }
    
    var style: ButtonRole? {
        switch self {
        case .delete:
            return .destructive
        default:
            return nil
        }
    }
}
