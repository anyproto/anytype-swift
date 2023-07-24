import SwiftUI

enum TemplateOptionAction: CaseIterable {
    case setAsDefault
    case editTemplate
    case duplicate
    case delete
    
    var title: String {
        switch self {
        case .setAsDefault:
            return Loc.TemplateOptions.Alert.setAsDefault
        case .editTemplate:
            return Loc.TemplateOptions.Alert.editTemplate
        case .duplicate:
            return Loc.TemplateOptions.Alert.duplicate
        case .delete:
            return Loc.TemplateOptions.Alert.delete
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
