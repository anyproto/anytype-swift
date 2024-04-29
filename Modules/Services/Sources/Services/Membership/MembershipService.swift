import ProtobufMessages
import Foundation
import AnytypeCore
import StoreKit


public typealias MiddlewareMemberhsipStatus = Anytype_Model_Membership

enum MembershipServiceError: Error {
    case tierNotFound
}


public protocol MembershipServiceProtocol {
    func getMembership(noCache: Bool) async throws -> MembershipStatus
    func makeMembershipFromMiddlewareModel(membership: MiddlewareMemberhsipStatus, noCache: Bool) async throws -> MembershipStatus
    
    func getTiers(noCache: Bool) async throws -> [MembershipTier]    
    
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tierType: MembershipTierType) async throws
    
    func getBillingId(name: String, tier: MembershipTier) async throws -> String
    func verifyReceipt(billingId: String, receipt: String) async throws
}

public extension MembershipServiceProtocol {
    func makeMembershipFromMiddlewareModel(membership: MiddlewareMemberhsipStatus) async throws -> MembershipStatus {
        try await makeMembershipFromMiddlewareModel(membership: membership, noCache: false)
    }
    
}

public extension MembershipServiceProtocol {
    func getTiers() async throws -> [MembershipTier] {
        try await getTiers(noCache: false)
    }
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getMembership(noCache: Bool) async throws -> MembershipStatus {
        let status = try await ClientCommands.membershipGetStatus(.with {
            $0.noCache = noCache
        }).invoke(ignoreLogErrors: .canNotConnect).data
        return try await makeMembershipFromMiddlewareModel(membership: status, noCache: noCache)
    }
    
    public func makeMembershipFromMiddlewareModel(membership: MiddlewareMemberhsipStatus, noCache: Bool) async throws -> MembershipStatus {
        let tiers = try await getTiers(noCache: noCache)
        
        let tier = tiers.first { $0.type.id == membership.tier }
        
        if tier == nil, membership.tier != 0 {
            anytypeAssertionFailure(
                "Not found tier info for membership",
                info: [
                    "membership": membership.debugDescription,
                    "tiers": tiers.debugDescription,
                    "noCache": noCache.description
                ]
            )
            throw MembershipServiceError.tierNotFound
        }
        
        return convertMiddlewareMembership(membership: membership, tier: tier)
    }
    
    public func getTiers(noCache: Bool) async throws -> [MembershipTier] {
        return try await ClientCommands.membershipGetTiers(.with {
            $0.locale = Locale.current.languageCode ?? "en"
            $0.noCache = noCache
        })
        .invoke(ignoreLogErrors: .canNotConnect).tiers
        .filter { FeatureFlags.membershipTestTiers || !$0.isTest }
        .asyncMap { await buildMemberhsipTier(tier: $0) }.compactMap { $0 }
    }
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = data.email
            $0.subscribeToNewsletter = data.subscribeToNewsletter
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
        try await ClientCommands.membershipVerifyAppStoreReceipt(.with {
            $0.billingID = billingId
            $0.receipt = receipt
        }).invoke()
    }
    
    // MARK: - Private
    private func convertMiddlewareMembership(membership: MiddlewareMemberhsipStatus, tier: MembershipTier?) -> MembershipStatus {
        if let tier {
            anytypeAssert(tier.type.id == membership.tier, "\(tier) and \(membership) does not match an id")
        }
        
        return MembershipStatus(
            tier: tier,
            status: membership.status,
            dateEnds: Date(timeIntervalSince1970: TimeInterval(membership.dateEnds)),
            paymentMethod: membership.paymentMethod,
            anyName: AnyName(handle: membership.nsName, extension: membership.nsNameType)
        )
    }

    private func buildMemberhsipTier(tier: Anytype_Model_MembershipTierData) async -> MembershipTier? {
        guard let type = MembershipTierType(intId: tier.id) else { return nil } // ignore 0 tier
        guard let paymentType = await buildMembershipPaymentType(type: type, tier: tier) else { return nil }
        
        let anyName: MembershipAnyName = tier.anyNamesCountIncluded > 0 ? .some(minLenght: tier.anyNameMinLength) : .none
        
        return MembershipTier(
            type: type,
            name: tier.name,
            anyName: anyName,
            features: tier.features,
            paymentType: paymentType,
            color: MembershipColor(string: tier.colorStr)
        )
    }
    
    private func buildMembershipPaymentType(
        type: MembershipTierType,
        tier: Anytype_Model_MembershipTierData
    ) async -> MembershipTierPaymentType? {
        guard type != .explorer else { return .email }
        
        if tier.iosProductID.isNotEmpty {
            return await buildAppStorePayment(tier: tier)
        } else {
            return buildStripePayment(tier: tier)
        }
    }
    
    private func buildAppStorePayment(tier: Anytype_Model_MembershipTierData) async -> MembershipTierPaymentType {
        do {
            let products = try await Product.products(for: [tier.iosProductID])
            guard let product = products.first else {
                anytypeAssertionFailure("Not found product for id \(tier.iosProductID)")
                return buildStripePayment(tier: tier)
            }
            
            return .appStore(product: product)
        } catch {
            anytypeAssertionFailure("Get products error", info: ["error": error.localizedDescription])
            return buildStripePayment(tier: tier)
        }
    }
    
    private func buildStripePayment(tier: Anytype_Model_MembershipTierData) -> MembershipTierPaymentType {
        let info = StripePaymentInfo(
            periodType: tier.periodType,
            periodValue: tier.periodValue,
            priceInCents: tier.priceStripeUsdCents,
            paymentUrl: URL(string: tier.iosManageURL) ?? URL(string: "https://anytype.io/pricing")!
        )
        return .external(info: info)
    }
}
