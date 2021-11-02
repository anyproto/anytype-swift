
import Foundation

public struct Relation {
    
    let key: String
    let name: String
    let format: Format
    let source: Source
    let isHidden: Bool = false
    let isReadOnly: Bool = false
    let isMulti: Bool = false
    let selections: [Option] = []
    let objectTypes: [String] = []
    let defaultValue: Any? = nil
    
}
