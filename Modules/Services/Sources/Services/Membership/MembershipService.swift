public protocol MembershipServiceProtocol {
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws
    func verifyEmailCode(code: String) async throws
}

public final class MembershipService: MembershipServiceProtocol {
    public init() { }
    
    public func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if Int(code) != 1337 {
            throw CommonError.undefined
        }
    }
}
