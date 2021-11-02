enum ObjectSetting: CaseIterable {
    case icon
    case cover
    case layout
    #if !RELEASE
    case relations
    #endif
    
}
