import Foundation

enum RelationOptionsSearchRowModel: Hashable, Identifiable {

    case object(RelationOptionsSearchObjectRowView.Model)
    case file(RelationOptionsSearchObjectRowView.Model)
    case tag(RelationOptionsSearchTagRowView.Model)
    
}

extension RelationOptionsSearchRowModel {
    
    var id: String {
        switch self {
        case .object(let model): return model.id
        case .file(let model): return model.id
        case .tag(let model): return model.id
        }
    }
    
}
