import SwiftUI
import Services

struct PropertyOptionSettingsConfiguration {
    let option: PropertyOptionParameters
    let mode: PropertyOptionSettingsMode
}

enum PropertyOptionSettingsMode {
    case create(CreateData)
    case edit
    
    var title: String {
        switch self {
        case .create: return Loc.Property.View.Create.title
        case .edit: return Loc.Property.View.Edit.title
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .create: return Loc.create
        case .edit: return Loc.apply
        }
    }
    
    struct CreateData {
        let relationKey: String
        let spaceId: String
    }
}

struct PropertyOptionParameters {
    let id: String
    let text: String
    let color: Color
    
    init(id: String = UUID().uuidString, text: String?, color: Color?) {
        self.id = id
        self.text = text ?? ""
        self.color = color ?? MiddlewareColor.allCasesWithoutDefault.randomElement().map { Color.Dark.color(from: $0) } ?? Color.Dark.grey
    }
}
