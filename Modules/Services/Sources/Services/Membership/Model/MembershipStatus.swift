public enum MembershipTier: Hashable, Identifiable {    
    case explorer
    case builder
    case coCreator
    
    case custom(id: Int32)
    
    public var id: Self {
        return self
    }
}

public struct MembershipStatus {
    let tier: MembershipTier?
}

