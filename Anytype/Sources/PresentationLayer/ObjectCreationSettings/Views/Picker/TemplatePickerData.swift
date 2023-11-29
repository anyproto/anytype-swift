import Services
import SwiftUI

struct TemplatePickerData {
    let template: ObjectDetails
    let editorView: AnyView
}

enum BlankTemplateSetting: CaseIterable {
    case setAsDefault
    
    var title: String {
        switch self {
        case .setAsDefault:
            return Loc.Actions.templateMakeDefault
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
        case .setAsDefault:
            return .templateMakeDefault
        }
    }
}
