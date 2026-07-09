import Services


// Pure helpers driving the redesigned membership screen: which upgrade (if any)
// to recommend, and whether to show the `.any` name block. The current plan is
// simply `membership.tier` — the free tier is not part of the purchasable list,
// so it must never be inferred from `tiers`.
enum MembershipTierRecommendation {

    // The next tier up to offer as an upgrade. With no owned tier, recommend the
    // cheapest available tier. Otherwise the entry right after the owned tier in
    // middleware order — nil when it's already the last tier, or isn't in the
    // loaded list yet (stale cache).
    static func recommendedTier(membership: MembershipStatus, tiers: [MembershipTier]) -> MembershipTier? {
        guard let current = membership.tier else {
            return tiers.first
        }
        guard let currentIndex = tiers.firstIndex(where: { $0.type.id == current.type.id }) else {
            return nil
        }

        let nextIndex = currentIndex + 1
        guard tiers.indices.contains(nextIndex) else { return nil }
        return tiers[nextIndex]
    }

    // Whether to show the claim-your-`.any`-name prompt: only when the owned tier
    // includes a name that has not been claimed yet. Hidden once a name is set.
    // Also suppressed while status is `.pending`: the payment is confirmed but the
    // middleware is still allocating the purchased name, so prompting here would
    // race that side-effect.
    static func showAnyName(membership: MembershipStatus) -> Bool {
        guard membership.status != .pending else { return false }
        guard let anyName = membership.tier?.anyName, anyName != .none else { return false }
        return membership.anyName.handle.isEmpty
    }
}
