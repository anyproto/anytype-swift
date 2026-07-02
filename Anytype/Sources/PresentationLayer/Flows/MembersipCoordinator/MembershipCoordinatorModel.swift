import SwiftUI
import Services
import AnytypeCore


@MainActor
@Observable
final class MembershipCoordinatorModel {
    var userMembership: MembershipStatus = .empty
    var tiers: [MembershipTier] = []

    var showTiersLoadingError = false
    var showTier: MembershipTier?
    var showNameFinalization: MembershipTier?
    var showSuccess: MembershipTier?
    var showCodeActivation: MembershipCodeActivationData?
    var fireConfetti = false
    var emailUrl: URL?

    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @ObservationIgnored @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol

    @ObservationIgnored
    private let initialTierId: Int?
    @ObservationIgnored
    private let initialCode: String?
    @ObservationIgnored
    private var didPresentInitialCode = false

    init(initialTierId: Int?, initialCode: String?) {
        self.initialTierId = initialTierId
        self.initialCode = initialCode
    }

    func startMembershipSubscription() async {
        for await status in membershipStatusStorage.statusPublisher.values {
            userMembership = status
        }
    }
    
    func onAppear() {
        if let initialCode, !didPresentInitialCode {
            didPresentInitialCode = true
            showCodeActivation = MembershipCodeActivationData(code: initialCode, route: .stripe)
        }

        Task {
            await loadTiers()

            // A code link takes precedence: don't open the purchase sheet behind (or
            // after) the code activation cover.
            guard initialCode == nil, let initialTierId else { return }
            guard let initialTier = tiers.first(where: { $0.type.id == initialTierId }) else {
                anytypeAssertionFailure("Not found initial id for Memberhsip coordinator", info: ["tierId": String(initialTierId)])
                return
            }
            onTierSelected(tier: initialTier)
        }
    }
    
    func loadTiers(noCache: Bool = false) {
        Task { await loadTiers(noCache: noCache) }
    }
    
    private func loadTiers(noCache: Bool = false) async {
        do {
            tiers = try await membershipService.getTiers(noCache: noCache)
            showTiersLoadingError = false
        } catch {
            showTiersLoadingError = true
        }
    }
    
    func onTierSelected(tier: MembershipTier) {
        showTier = tier
    }
    
    func onSuccessfulPurchase(tier: MembershipTier) {
        showSuccessScreen(tier: tier)
    }

    func onActivateCodeTap() {
        showCodeActivation = MembershipCodeActivationData(code: nil, route: .settingsMembership)
    }

    func onAskQuestionTap() {
        AnytypeAnalytics.instance().logContactUs()
        let info = [
            Loc.About.appVersion(MetadataProvider.appVersion ?? ""),
            Loc.About.buildNumber(MetadataProvider.buildNumber ?? ""),
            Loc.About.anytypeId(accountManager.account.id)
        ].joined(separator: "\n")
        let mailLink = MailUrl(
            to: AboutApp.supportMailTo,
            subject: Loc.About.Mail.subject(accountManager.account.id),
            body: Loc.About.Mail.body(info)
        )
        emailUrl = mailLink.url
    }

    // Opens the standalone name-selection flow so the user can claim their `.any`
    // name for the tier they already own.
    func onSelectNameTap() {
        guard let currentTier = userMembership.tier else { return }
        showNameFinalization = currentTier
    }

    func onCodeRedeemed(redeemedTier: MembershipTierType?) async {
        showCodeActivation = nil

        // Resolve the full tier for the success screen. Prefer the tier the redeem
        // returned (reliable, offline for standard tiers already in `tiers`), then a
        // forced status refresh (covers custom/team tiers). Intentionally no cached-status
        // fallback: right after a redeem the cache can still hold the pre-redemption tier,
        // which would show the success screen for the wrong tier.
        var tier = redeemedTier.flatMap { type in tiers.first { $0.type.id == type.id } }
        if tier == nil {
            tier = (try? await membershipService.getMembership(noCache: true))?.tier
        }
        guard let tier else { return }

        AnytypeAnalytics.instance().logActivateMembershipCode(tier: tier)
        showSuccessScreen(tier: tier)
    }
    
    private func showSuccessScreen(tier: MembershipTier) {
        showTier = nil
        loadTiers(noCache: true)
        
        Task {
            // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
            try await Task.sleep(seconds: 0.5)
            showSuccess = tier
            
            try await Task.sleep(seconds:0.5)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            fireConfetti = true
        }
    }
}
