public protocol MembershipServiceProtocol {
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws
}

public final class MembershipService: MembershipServiceProtocol {
    public init() { }
    
    public func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        try await Task.sleep(nanoseconds: 3_000_000_000)
        throw CommonError.undefined
    }
}
