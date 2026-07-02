import Testing
@testable import Anytype
import Services

struct MembershipTierRecommendationTests {

    private let tiers: [MembershipTier] = [.mockStarter, .mockBuilder, .mockCoCreator]

    // MARK: - currentTier

    @Test func currentTier_noPaidTier_fallsBackToFirst() {
        let membership = MembershipStatus.mock(tier: nil)
        let current = MembershipTierRecommendation.currentTier(membership: membership, tiers: tiers)
        #expect(current?.type == MembershipTierType.starter)
    }

    @Test func currentTier_ownedTier_returnsOwned() {
        let membership = MembershipStatus.mock(tier: .mockBuilder)
        let current = MembershipTierRecommendation.currentTier(membership: membership, tiers: tiers)
        #expect(current?.type == MembershipTierType.builder)
    }

    @Test func currentTier_emptyTiers_isNil() {
        let membership = MembershipStatus.mock(tier: nil)
        #expect(MembershipTierRecommendation.currentTier(membership: membership, tiers: []) == nil)
    }

    // MARK: - recommendedTier

    @Test func recommended_freeUser_isFirstPaidTier() {
        let membership = MembershipStatus.mock(tier: nil)
        let recommended = MembershipTierRecommendation.recommendedTier(membership: membership, tiers: tiers)
        #expect(recommended?.type == MembershipTierType.builder)
    }

    @Test func recommended_midTier_isNextTier() {
        let membership = MembershipStatus.mock(tier: .mockBuilder)
        let recommended = MembershipTierRecommendation.recommendedTier(membership: membership, tiers: tiers)
        #expect(recommended?.type == MembershipTierType.coCreator)
    }

    @Test func recommended_topTier_isNil() {
        let membership = MembershipStatus.mock(tier: .mockCoCreator)
        let recommended = MembershipTierRecommendation.recommendedTier(membership: membership, tiers: tiers)
        #expect(recommended == nil)
    }

    @Test func recommended_emptyTiers_isNil() {
        let membership = MembershipStatus.mock(tier: nil)
        #expect(MembershipTierRecommendation.recommendedTier(membership: membership, tiers: []) == nil)
    }

    // MARK: - showAnyName

    @Test func showAnyName_freeTierWithoutAnyName_isFalse() {
        // Falls back to the first tier (.mockStarter, anyName == .none).
        let membership = MembershipStatus.mock(tier: nil)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership, tiers: tiers) == false)
    }

    @Test func showAnyName_paidTierWithAnyName_isTrue() {
        let membership = MembershipStatus.mock(tier: .mockBuilder)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership, tiers: tiers) == true)
    }

    @Test func showAnyName_emptyTiers_isFalse() {
        let membership = MembershipStatus.mock(tier: nil)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership, tiers: []) == false)
    }
}
