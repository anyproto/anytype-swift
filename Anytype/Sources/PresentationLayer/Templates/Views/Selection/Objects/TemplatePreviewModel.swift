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
    init(
        id: BlockId,
        title: String,
        header: ObjectHeader?,
        isBundled: Bool
    ) {
        self.id = id
        self.title = title
        self.header = header
        self.isBundled = isBundled
    }
    
    let id: BlockId
    let title: String
    let header: ObjectHeader?
    let isBundled: Bool
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
            return "Blank"
        case .addTemplate:
            return "Add template"
        case let .installed(model):
            return model.id
        }
    }
}
