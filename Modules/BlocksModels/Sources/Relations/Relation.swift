
import Foundation

public struct Relation: Hashable {
    
    public let key: String
    public let name: String
    public let format: Format
    public let source: Source
    public let isHidden: Bool = false
    public let isReadOnly: Bool = false
    public let isMulti: Bool = false
    public let selections: [Option] = []
    public let objectTypes: [String] = []
    public let defaultValue: AnyHashable? = nil
    
}

extension Relation: Identifiable {

    public var id: String {
        return key
    }
    
}
