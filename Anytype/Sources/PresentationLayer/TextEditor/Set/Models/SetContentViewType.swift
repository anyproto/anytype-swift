import BlocksModels

enum SetContentViewType {
    case collection(CollectionType)
    case table
    case kanban
    
    enum CollectionType {
        case gallery
        case list
    }
}
