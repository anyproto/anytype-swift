import Services


// Pure helpers driving the redesigned membership screen: which tier is shown as
// the current plan and which one (if any) is offered as the next upgrade.
enum MembershipTierRecommendation {

    // The plan the user is on. Falls back to the first tier (free) when no paid
    // tier is owned.
    static func currentTier(membership: MembershipStatus, tiers: [MembershipTier]) -> MembershipTier? {
        membership.tier ?? tiers.first
    }

    // The next tier up to recommend as an upgrade. Uses the middleware array order:
    // the entry right after the current tier. Returns nil when the user is already
    // on the last tier (nothing to upgrade to).
    static func recommendedTier(membership: MembershipStatus, tiers: [MembershipTier]) -> MembershipTier? {
        guard let current = currentTier(membership: membership, tiers: tiers),
              let currentIndex = tiers.firstIndex(where: { $0.type.id == current.type.id }) else {
            return tiers.first
        }

        let nextIndex = currentIndex + 1
        guard tiers.indices.contains(nextIndex) else { return nil }
        return tiers[nextIndex]
    }
}
