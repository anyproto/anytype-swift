/*
* Layout have no visual representation, but affects on blocks, that it contains.
* Row/Column layout blocks creates only automatically, after some of a D&D operations, for example
*/
public struct BlockLayout: Hashable, Sendable {
    public enum Style {
        case row
        case column
        case div
        case header
        case tableRows
        case tableColumns
    }
    
    public var style: Style
    // MARK: - Memberwise initializer
    public init(style: Style) {
        self.style = style
    }
}
