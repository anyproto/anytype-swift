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

public protocol MembershipServiceProtocol {
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
}

public final class MembershipService: MembershipServiceProtocol {
    public init() { }
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if Int(code) != 1337 {
            throw CommonError.undefined
        }
    }
}
