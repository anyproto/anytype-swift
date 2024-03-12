

public protocol MembershipServiceProtocol {
    func getStatus() async throws -> MembershipTier?
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if Int(code) != 1337 {
            throw CommonError.undefined
        } else {
            MembershipService.tier = .explorer
        }
    }
    
    private static var tier: MembershipTier?
    public func getStatus() async throws -> MembershipTier? {
        return MembershipService.tier
    }
}
