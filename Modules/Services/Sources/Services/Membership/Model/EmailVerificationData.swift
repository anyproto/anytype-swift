public struct EmailVerificationData: Hashable, Identifiable {
    let email: String
    let subscribeToNewsletter: Bool
    
    public var id: Self {
        self
    }
    
    public init(email: String, subscribeToNewsletter: Bool) {
        self.email = email
        self.subscribeToNewsletter = subscribeToNewsletter
    }
}
