enum ContextualMenuAction {
    case addBlockBelow
    case delete
    case duplicate
    case moveTo
    case turnIntoPage
    
    /// Text
    case style
    case color
    case backgroundColor
    
    /// Files
    case download
    case replace
    
    /// Image
    case addCaption
    
    /// Page
    case rename
}
