public struct EmailVerificationData: Identifiable {
    let email: String
    let subscribeToNewsletter: Bool
    
    public var id: String {
        "\(email):\(subscribeToNewsletter)"
    }
    
    public init(email: String, subscribeToNewsletter: Bool) {
        self.email = email
        self.subscribeToNewsletter = subscribeToNewsletter
    }
}
