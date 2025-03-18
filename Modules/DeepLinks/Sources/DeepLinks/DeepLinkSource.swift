public enum DeepLinkSource: Equatable, Sendable {
    case `internal`
    case external
    
    public var isExternal: Bool {
        self == .external
    }
}
