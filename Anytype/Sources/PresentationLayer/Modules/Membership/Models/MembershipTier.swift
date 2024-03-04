enum MembershipTier: String, Identifiable {
    case explorer
    case builder
    case coCreator
    
    var id: String { rawValue }
}
