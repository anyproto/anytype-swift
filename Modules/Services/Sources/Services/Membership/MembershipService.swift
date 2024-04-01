import ProtobufMessages
import Foundation
import AnytypeCore


public typealias MiddlewareMemberhsipStatus = Anytype_Model_Membership

enum MembershipServiceError: Error {
    case tierNotFound
}


public protocol MembershipServiceProtocol {
    func getStatus() async throws -> MembershipStatus
    func makeStatusFromMiddlewareModel(membership: MiddlewareMemberhsipStatus) async throws -> MembershipStatus
    
    func getTiers(noCache: Bool) async throws -> [MembershipTier]
    func dropTiersCache() async throws
    
    
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tierType: MembershipTierType) async throws
}

public extension MembershipServiceProtocol {
    func getTiers() async throws -> [MembershipTier] {
        try await getTiers(noCache: false)
    }
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getStatus() async throws -> MembershipStatus {
        let status = try await ClientCommands.membershipGetStatus().invoke().data
        return try await makeStatusFromMiddlewareModel(membership: status)
    }
    
    public func makeStatusFromMiddlewareModel(membership: MiddlewareMemberhsipStatus) async throws -> MembershipStatus {
        let tier = try await getTiers().first { $0.type.id == membership.tier }
        
        guard let tier else {
            anytypeAssertionFailure("Not found tier info for \(membership)")
            throw MembershipServiceError.tierNotFound
        }
        
        return convertMiddlewareMembership(membership: membership, tier: tier)
    }
    
    public func getTiers(noCache: Bool) async throws -> [MembershipTier] {
        return try await ClientCommands.membershipGetTiers(.with {
            $0.locale = Locale.current.languageCode ?? "en"
            $0.noCache = noCache
        })
        .invoke().tiers.filter { !$0.isTest }.compactMap { $0.asModel() }
    }
    
    func dropTiersCache() async throws {
        _ = try await getTiers(noCache: true)
    }
    
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
    
    public func validateName(name: String, tierType: MembershipTierType) async throws {
        try await ClientCommands.membershipIsNameValid(.with {
            $0.requestedAnyName = name
            $0.requestedTier = tierType.id
        }).invoke(ignoreLogErrors: .hasInvalidChars, .tooLong, .tooShort)
    }
    
    // MARK: - Private
    private func convertMiddlewareMembership(membership: MiddlewareMemberhsipStatus, tier: MembershipTier) -> MembershipStatus {
        anytypeAssert(tier.type.id == membership.tier, "\(tier) and \(membership) does not match an id")
        
        return MembershipStatus(
            tier: tier,
            status: membership.status,
            dateEnds: Date(timeIntervalSince1970: TimeInterval(membership.dateEnds)),
            paymentMethod: membership.paymentMethod,
            anyName: membership.requestedAnyName
        )
    }
}
