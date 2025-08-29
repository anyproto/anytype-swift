import Foundation
import StoredHashMacro

@StoredHash
struct MessageSectionData: Identifiable, Equatable, Hashable {
    
    typealias Header = String
    typealias ID = Int
    
    var header: Header {
        didSet { updateHash() }
    }
    var id: ID {
        didSet { updateHash() }
    }
    var items: [MessageSectionItem] {
        didSet { updateHash() }
    }
}
