import AnytypeCore
import Foundation
import ProtobufMessages
import StoreKit

public typealias MiddlewareMembershipStatus = Anytype_Model_Membership
public typealias MiddlewareMembershipTier = Anytype_Model_MembershipTierData

public protocol MembershipModelBuilderProtocol: Sendable {
    func buildMembershipStatus(membership: MiddlewareMembershipStatus, tier: MembershipTier?) -> MembershipStatus
    func buildMembershipStatus(membership: MiddlewareMembershipStatus, allTiers: [MembershipTier]) throws -> MembershipStatus
    
    func buildMembershipTier(tier: MiddlewareMembershipTier) async -> MembershipTier?
}


final class MembershipModelBuilder: MembershipModelBuilderProtocol {
    func buildMembershipStatus(membership: MiddlewareMembershipStatus, allTiers: [MembershipTier]) throws -> MembershipStatus {
        let tier = allTiers.first { $0.type.id == membership.tier }
        
        if tier == nil, membership.tier != 0 {
            anytypeAssertionFailure(
                "Not found tier info for membership",
                info: [
                    "membership": membership.debugDescription,
                    "tiers": allTiers.debugDescription,
                ]
            )
            throw MembershipServiceError.tierNotFound
        }
        
        return buildMembershipStatus(membership: membership, tier: tier)
    }
    
    func buildMembershipStatus(membership: MiddlewareMembershipStatus, tier: MembershipTier?) -> MembershipStatus {
        if let tier {
            anytypeAssert(tier.type.id == membership.tier, "\(tier) and \(membership) does not match an id")
        }
        
        let dateEnds: MembershipDateEnds = membership.dateEnds == 0 ? .never : .date(Date(timeIntervalSince1970: TimeInterval(membership.dateEnds)))
        
        return MembershipStatus(
            tier: tier,
            status: membership.status,
            dateEnds: dateEnds,
            paymentMethod: membership.paymentMethod,
            anyName: AnyName(handle: membership.nsName, extension: membership.nsNameType),
            email: membership.userEmail
        )
    }

    func buildMembershipTier(tier: Anytype_Model_MembershipTierData) async -> MembershipTier? {
        guard let type = MembershipTierType(intId: tier.id) else { return nil } // ignore 0 tier
        
        let paymentType = await buildMembershipPaymentType(type: type, tier: tier)
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
    
    // MARK: - Private
    
    private func buildMembershipPaymentType(
        type: MembershipTierType,
        tier: Anytype_Model_MembershipTierData
    ) async -> MembershipTierPaymentType? {
        guard type != .explorer else { return nil }
        
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
                validateMissingProductId(tier.iosProductID)
                return buildStripePayment(tier: tier)
            }
            
            let info = AppStorePaymentInfo(
                product: product,
                fallbackPaymentUrl: buildPaymentUrl(tier: tier)
            )
            
            return .appStore(info: info)
        } catch {
            anytypeAssertionFailure("Get products error", info: ["error": error.localizedDescription])
            return buildStripePayment(tier: tier)
        }
    }
    
    private func validateMissingProductId(_ productId: String) {
        switch BuildTypeProvider.buidType {
        case .appStore:
            // If prod app uses staging middleware it will receive stage product id, skip this error
            if productId != "io.anytype.dev.membership.builder" {
                anytypeAssertionFailure("Not found product for id \(productId)")
            }
        case .testflight:
            // If testflight app uses prod middleware it will receive prod product id, skip this error
            if productId != "io.anytype.membership.tier.builder" {
                anytypeAssertionFailure("Not found product for id \(productId)")
            }
        case .debug:
            break
        }
    }
    
    private func buildStripePayment(tier: Anytype_Model_MembershipTierData) -> MembershipTierPaymentType {
        let info = StripePaymentInfo(
            periodType: tier.periodType,
            periodValue: tier.periodValue,
            priceInCents: tier.priceStripeUsdCents,
            paymentUrl: buildPaymentUrl(tier: tier)
        )
        return .external(info: info)
    }
    
    private func buildPaymentUrl(tier: Anytype_Model_MembershipTierData) -> URL {
        anytypeAssert(tier.iosManageURL.isNotEmpty, "Empty iosManageURL", info: ["tier": tier.debugDescription])
        
        return URL(string: tier.iosManageURL) ?? URL(string: "https://anytype.io/pricing")!
    }
}

public extension Container {
    var membershipModelBuilder: Factory<MembershipModelBuilderProtocol> {
        self { MembershipModelBuilder() }.shared
    }
}
