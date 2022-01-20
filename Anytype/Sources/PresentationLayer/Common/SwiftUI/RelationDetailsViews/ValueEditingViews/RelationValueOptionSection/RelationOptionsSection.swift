import Foundation

struct RelationOptionsSection<Option: RelationSectionedOptionProtocol>: Hashable, Identifiable {
    
    let id: String
    let title: String
    let options: [Option]
    
}
