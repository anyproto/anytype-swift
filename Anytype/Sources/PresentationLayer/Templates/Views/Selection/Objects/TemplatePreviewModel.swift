import Services

struct TemplateModel {
    init(
        id: BlockId,
        title: String,
        header: ObjectHeader?
    ) {
        self.id = id
        self.title = title
        self.header = header
    }
    
    let id: BlockId
    let title: String
    let header: ObjectHeader?
}

enum TemplateType {
    case blank
    case addTemplate
    case installed(TemplateModel)
}

struct TemplatePreviewModel: Identifiable {
    let model: TemplateType
    let alignment: LayoutAlignment
    let isDefault: Bool
}

extension TemplatePreviewModel: IdProvider {
    var id: BlockId {
        switch model {
        case .blank:
            return "Blank"
        case .addTemplate:
            return "Add template"
        case let .installed(model):
            return model.id
        }
    }
}
