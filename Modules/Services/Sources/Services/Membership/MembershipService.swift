import ProtobufMessages
import Foundation
import AnytypeCore
import StoreKit


public enum MembershipServiceError: Error {
    case tierNotFound
    case forcefullyFailedValidation
}

public protocol MembershipServiceProtocol {
    func getMembership(noCache: Bool) async throws -> MembershipStatus
    
    func getTiers(noCache: Bool) async throws -> [MembershipTier]    
    
    func getVerificationEmail(email: String) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tierType: MembershipTierType) async throws
    
    func getBillingId(name: String, tier: MembershipTier) async throws -> String
    func verifyReceipt(billingId: String, receipt: String) async throws
    
    func finalizeMembership(name: String) async throws
}

public extension MembershipServiceProtocol {
    func getTiers() async throws -> [MembershipTier] {
        try await getTiers(noCache: false)
    }
}

final class MembershipService: MembershipServiceProtocol {
    
    @Injected(\.membershipModelBuilder)
    private var builder: MembershipModelBuilderProtocol
    
    public func getMembership(noCache: Bool) async throws -> MembershipStatus {
        let status = try await ClientCommands.membershipGetStatus(.with {
            $0.noCache = noCache
        }).invoke(ignoreLogErrors: .canNotConnect).data
        
        let tiers = try await getTiers(noCache: noCache)
        
        return try builder.buildMembershipStatus(membership: status, allTiers: tiers)
    }
    
    public func getTiers(noCache: Bool) async throws -> [MembershipTier] {
        return try await ClientCommands.membershipGetTiers(.with {
            $0.locale = Locale.current.languageCode ?? "en"
            $0.noCache = noCache
        })
        .invoke(ignoreLogErrors: .canNotConnect).tiers
        .filter { FeatureFlags.membershipTestTiers || !$0.isTest }
        .asyncMap { await builder.buildMemberhsipTier(tier: $0) }.compactMap { $0 }
    }
    
    public func getVerificationEmail(email: String) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = email
            $0.subscribeToNewsletter = true
        }).invoke(ignoreLogErrors: .canNotConnect)
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await ClientCommands.membershipVerifyEmailCode(.with {
            $0.code = code
        }).invoke(ignoreLogErrors: .wrong, .canNotConnect)
    }
    
    public func validateName(name: String, tierType: MembershipTierType) async throws {
        try await ClientCommands.membershipIsNameValid(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
            $0.requestedTier = tierType.id
        }).invoke(ignoreLogErrors: .hasInvalidChars, .tooLong, .tooShort, .canNotConnect)
    }
    
    public func getBillingId(name: String, tier: MembershipTier) async throws -> String {
        try await ClientCommands.membershipGetPaymentUrl(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
            $0.paymentMethod = .methodInappApple
            $0.requestedTier = tier.type.id
        }).invoke(ignoreLogErrors: .canNotConnect).billingID
    }
    
    public func verifyReceipt(billingId: String, receipt: String) async throws {
        guard !FeatureFlags.failReceiptValidation else {
            throw MembershipServiceError.forcefullyFailedValidation
        }
        
        try await ClientCommands.membershipVerifyAppStoreReceipt(.with {
            $0.billingID = billingId
            $0.receipt = receipt
        }).invoke()
    }
    
    public func finalizeMembership(name: String) async throws {
        try await ClientCommands.membershipFinalize(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
        }).invoke()
    }
}
