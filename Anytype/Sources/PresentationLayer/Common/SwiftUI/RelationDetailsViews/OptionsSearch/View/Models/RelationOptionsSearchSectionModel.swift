import Foundation

struct RelationOptionsSearchSectionModel: Hashable, Identifiable {
    
    let id: String
    
    let title: String?
    let rows: [RelationOptionsSearchRowModel]
    
}
