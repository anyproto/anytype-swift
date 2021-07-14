enum ObjectType: String {
    case page = "_otpage"
    case set = "_otset"
    case template = "_ottemplate"
    
    var name: String {
        switch self {
        case .page:
            return "Page"
        case .set:
            return "Set"
        case .template:
            return "Template"
        }
    }
}
