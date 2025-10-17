import ProtobufMessages
import Foundation
import AnytypeCore
import StoreKit


public enum MembershipServiceError: Error {
    case tierNotFound
    case invalidBillingIdFormat
}

public protocol MembershipServiceProtocol: Sendable {
    func getMembership(noCache: Bool) async throws -> MembershipStatus
    
    func getTiers(noCache: Bool) async throws -> [MembershipTier]    
    
    func getVerificationEmailSubscribeToNewsletter(email: String) async throws
    func getVerificationEmailOnOnboarding(email: String) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tierType: MembershipTierType) async throws
    
    func getBillingId(name: String, tier: MembershipTier) async throws -> UUID
    func verifyReceipt(receipt: String) async throws
    
    func finalizeMembership(name: String) async throws
}

public extension MembershipServiceProtocol {
    func getTiers() async throws -> [MembershipTier] {
        try await getTiers(noCache: false)
    }
}

final class MembershipService: MembershipServiceProtocol {
    
    private let builder: any MembershipModelBuilderProtocol = Container.shared.membershipModelBuilder()
    
    public func getMembership(noCache: Bool) async throws -> MembershipStatus {
        let membership = try await ClientCommands.membershipGetStatus(.with {
            $0.noCache = noCache
        }).invoke(ignoreLogErrors: .canNotConnect).data
        
        let tiers = try await getTiers(noCache: noCache, currentMembership: membership)
        
        return try builder.buildMembershipStatus(membership: membership, allTiers: tiers)
    }
    
    func getTiers(noCache: Bool) async throws -> [MembershipTier] {
        let membership = try await ClientCommands.membershipGetStatus(.with {
            $0.noCache = noCache
        }).invoke(ignoreLogErrors: .canNotConnect).data
        
        return try await getTiers(noCache: noCache, currentMembership: membership)
    }
    
    private func getTiers(noCache: Bool, currentMembership: Anytype_Model_Membership) async throws -> [MembershipTier] {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"

        let tiers = try await ClientCommands.membershipGetTiers(.with {
            $0.locale = locale
            $0.noCache = noCache
        })
        .invoke(ignoreLogErrors: .canNotConnect).tiers
        .filter { FeatureFlags.membershipTestTiers || !$0.isTest }
        .filter { $0.iosProductID.isNotEmpty || $0.id == currentMembership.tier }
        .asyncMap { await builder.buildMembershipTier(tier: $0) }.compactMap { $0 }

        return tiers
    }

    
    public func getVerificationEmailSubscribeToNewsletter(email: String) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = email
            $0.subscribeToNewsletter = true
        }).invoke(ignoreLogErrors: .canNotConnect)
    }
    
    public func getVerificationEmailOnOnboarding(email: String) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = email
            $0.isOnboardingList = true
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
    
    public func getBillingId(name: String, tier: MembershipTier) async throws -> UUID {
        let billingId = try await ClientCommands.membershipRegisterPaymentRequest(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
            $0.paymentMethod = .methodInappApple
            $0.requestedTier = tier.type.id
        })
        .invoke(ignoreLogErrors: .canNotConnect)
        .billingID

        guard let uuid = UUID(uuidString: billingId) else {
            throw MembershipServiceError.invalidBillingIdFormat
        }

        return uuid
    }
    
    public func verifyReceipt(receipt: String) async throws {
        let receipt = FeatureFlags.failReceiptValidation ? "Completely Broken Receipt" : receipt
        
        try await ClientCommands.membershipVerifyAppStoreReceipt(.with {
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
