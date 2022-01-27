import Foundation

struct RelationOptionsSection<Option: RelationScopedOptionProtocol>: Hashable, Identifiable {
    
    let id: String
    
    let title: String
    let options: [Option]
    
}
