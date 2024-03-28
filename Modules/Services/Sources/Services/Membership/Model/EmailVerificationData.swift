public struct EmailVerificationData: Hashable, Identifiable {
    public let email: String
    public let subscribeToNewsletter: Bool
    public let tier: MembershipTier
    
    public var id: Self {
        self
    }
    
    public init(email: String, subscribeToNewsletter: Bool, tier: MembershipTier) {
        self.email = email
        self.subscribeToNewsletter = subscribeToNewsletter
        self.tier = tier
    }
}
