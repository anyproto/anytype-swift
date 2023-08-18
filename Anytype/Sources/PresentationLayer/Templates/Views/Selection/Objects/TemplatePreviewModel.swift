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
        id: BlockId,
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
    
    let id: BlockId
    let title: String
    let header: ObjectHeader?
    let isBundled: Bool
    let style: Style
}

enum TemplateType: Equatable {
    case blank
    case addTemplate
    case installed(TemplateModel)
}

struct TemplatePreviewModel: Identifiable, Equatable {
    let mode: TemplateType
    let alignment: LayoutAlignment
    let isDefault: Bool
}

extension TemplatePreviewModel: IdProvider {
    var id: BlockId {
        switch mode {
        case .blank:
            return ""
        case .addTemplate:
            return "Add template"
        case let .installed(model):
            return model.id
        }
    }
}

extension TemplatePreviewModel {
    var contextualMenuOptions: [TemplateOptionAction] {
        switch mode {
        case .addTemplate:
            return []
        case .installed:
            return TemplateOptionAction.allCases
        case .blank:
            return [.setAsDefault]
        }
    }
}
