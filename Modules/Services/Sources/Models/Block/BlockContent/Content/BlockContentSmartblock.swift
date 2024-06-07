// Aka Page
public struct BlockSmartblock: Hashable, Sendable {
    public enum Style: Sendable {
        case page
        case home
        case profilePage
        case archive
        case breadcrumbs
    }
    
    public var style: Style = .page
    
    // MARK: - Memberwise initializer
    public init(style: Style = .page) {
        self.style = style
    }
}
