import ProtobufMessages
import Foundation


public protocol MembershipServiceProtocol {
    func getStatus() async throws -> MembershipStatus
    func getTiers(noCache: Bool) async throws -> [MembershipTier]
    
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tier: MembershipTierId) async throws
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = data.email
            $0.subscribeToNewsletter = data.subscribeToNewsletter
        }).invoke()
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await ClientCommands.membershipVerifyEmailCode(.with {
            $0.code = code
        }).invoke()
    }
    
    public func getStatus() async throws -> MembershipStatus {
        return try await ClientCommands.membershipGetStatus().invoke().data.asModel()
    }
    
    public func validateName(name: String, tier: MembershipTierId) async throws {        
        try await ClientCommands.membershipIsNameValid(.with {
            $0.requestedAnyName = name
            $0.requestedTier = tier.middlewareId
        }).invoke(ignoreLogErrors: .hasInvalidChars, .tooLong, .tooShort)
    }
    
    public func getTiers(noCache: Bool) async throws -> [MembershipTier] {
        return try await ClientCommands.membershipGetTiers(.with {
            $0.locale = Locale.current.languageCode ?? "en"
            $0.noCache = noCache
        })
        .invoke().tiers.filter { !$0.isTest }.compactMap { $0.asModel() }
    }
}
