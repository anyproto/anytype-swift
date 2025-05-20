import Services

struct TemplatePreviewViewModel: Identifiable, Equatable {
    var id: String { model.id }
    
    let model: TemplatePreviewModel
    @EquatableNoop var onOptionSelection: (TemplateOptionAction) -> Void
    
    init(model: TemplatePreviewModel, onOptionSelection: @escaping (TemplateOptionAction) -> Void) {
        self.model = model
        self.onOptionSelection = onOptionSelection
    }
}

struct TemplateModel: Equatable {
    enum Style: Equatable {
        case none
        case todo(Bool)
    }
    
    init(
        id: String,
        title: String,
        header: ObjectHeader?,
        isBundled: Bool,
        style: Style
    ) {
        self.id = id
        self.title = title
        self.header = header
        self.isBundled = isBundled
        self.style = style
    }
    
    let id: String
    let title: String
    let header: ObjectHeader?
    let isBundled: Bool
    let style: Style
}

enum TemplateType: Equatable {
    case addTemplate
    case installed(TemplateModel)
    
    var id: String {
        switch self {
        case .addTemplate:
            return "Add template"
        case let .installed(model):
            return model.id
        }
    }
}

enum TemplateDecoration {
    case border
    case defaultBadge
}

enum TemplatePreviewContext {
    case list
    case type
}

struct TemplatePreviewModel: Identifiable, Equatable {
    let mode: TemplateType
    let context: TemplatePreviewContext
    let alignment: LayoutAlignment
    let decoration: TemplateDecoration?
    
    var id: String {
        mode.id
    }
}

extension TemplatePreviewModel {
    init(mode: TemplateType, context: TemplatePreviewContext, alignment: LayoutAlignment) {
        self.init(mode: mode, context: context, alignment: alignment, decoration: nil)
    }
}

extension TemplatePreviewModel {
    var contextualMenuOptions: [TemplateOptionAction] {
        switch mode {
        case .addTemplate:
            []
        case .installed:
            switch context {
            case .list:
                TemplateOptionAction.allCases
            case .type:
                [.duplicate, .delete]
            }
        }
    }
}
