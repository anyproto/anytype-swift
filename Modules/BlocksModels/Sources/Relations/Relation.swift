
import Foundation

public struct Relation: Hashable {
    
    public let key: String
    public let name: String
    public let format: Format
    public let isHidden: Bool = false
    public let isReadOnly: Bool = false
    public let isMulti: Bool = false
    // list of values for multiple relations. ex.: tags
    public let selections: [Option] = []
    // list of types used by relation. ex.: type of file
    public let objectTypes: [String] = []
    
}

extension Relation: Identifiable {

    public var id: String {
        return key
    }
    
}
