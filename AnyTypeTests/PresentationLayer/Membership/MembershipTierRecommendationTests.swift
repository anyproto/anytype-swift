import Testing
@testable import Anytype
import Services

struct MembershipTierRecommendationTests {

    private let tiers: [MembershipTier] = [.mockStarter, .mockBuilder, .mockCoCreator]

    // MARK: - recommendedTier

    @Test func recommended_noTier_isFirstAvailableTier() {
        let membership = MembershipStatus.mock(tier: nil)
        let recommended = MembershipTierRecommendation.recommendedTier(membership: membership, tiers: tiers)
        #expect(recommended?.type == MembershipTierType.starter)
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

    @Test func recommended_noTierAndEmptyTiers_isNil() {
        let membership = MembershipStatus.mock(tier: nil)
        #expect(MembershipTierRecommendation.recommendedTier(membership: membership, tiers: []) == nil)
    }

    @Test func recommended_currentTierNotInLoadedList_isNil() {
        // Stale cache: the owned tier isn't in the loaded tiers array yet.
        let membership = MembershipStatus.mock(tier: .mockCustom)
        #expect(MembershipTierRecommendation.recommendedTier(membership: membership, tiers: tiers) == nil)
    }

    // MARK: - showAnyName

    @Test func showAnyName_noTier_isFalse() {
        let membership = MembershipStatus.mock(tier: nil)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership) == false)
    }

    @Test func showAnyName_tierWithoutAnyName_isFalse() {
        // .mockStarter has anyName == .none.
        let membership = MembershipStatus.mock(tier: .mockStarter)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership) == false)
    }

    @Test func showAnyName_tierWithAnyNameAndNoNameSet_isTrue() {
        let membership = MembershipStatus.mock(tier: .mockBuilder, anyName: .mockEmpty)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership) == true)
    }

    @Test func showAnyName_nameAlreadyClaimed_isFalse() {
        let membership = MembershipStatus.mock(tier: .mockBuilder, anyName: .mock)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership) == false)
    }

    @Test func showAnyName_pending_isFalse() {
        let membership = MembershipStatus.mock(tier: .mockBuilder, status: .pending, anyName: .mockEmpty)
        #expect(MembershipTierRecommendation.showAnyName(membership: membership) == false)
    }
}
