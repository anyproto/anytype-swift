import SwiftUI
import StoreKit
import Services
import Combine
import AnytypeCore


struct MembershipModuleView: View {
    @State private var safariUrl: URL?

    private let membership: MembershipStatus
    private let tiers: [MembershipTier]
    private let onTierTap: (MembershipTier) -> ()
    private let onActivateCodeTap: () -> ()
    private let onAskQuestionTap: () -> ()
    private let onSelectNameTap: () -> ()

    init(
        membership: MembershipStatus,
        tiers: [MembershipTier],
        onTierTap: @escaping (MembershipTier) -> (),
        onActivateCodeTap: @escaping () -> (),
        onAskQuestionTap: @escaping () -> (),
        onSelectNameTap: @escaping () -> ()
    ) {
        self.membership = membership
        self.tiers = tiers
        self.onTierTap = onTierTap
        self.onActivateCodeTap = onActivateCodeTap
        self.onAskQuestionTap = onAskQuestionTap
        self.onSelectNameTap = onSelectNameTap
    }

    private var currentTier: MembershipTier? {
        membership.tier
    }

    private var recommendedTier: MembershipTier? {
        MembershipTierRecommendation.recommendedTier(membership: membership, tiers: tiers)
    }

    private var showAnyNameBlock: Bool {
        MembershipTierRecommendation.showAnyName(membership: membership)
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            if let currentTier {
                                MembershipPlanCardView(
                                    tier: currentTier,
                                    ctaText: Loc.Membership.currentPlan,
                                    ctaStyle: .current
                                ) {
                                    onTierTap(currentTier)
                                }
                            }

                            if let recommendedTier {
                                MembershipPlanCardView(
                                    tier: recommendedTier,
                                    ctaText: Loc.upgrade,
                                    ctaStyle: .upgrade
                                ) {
                                    onTierTap(recommendedTier)
                                }
                            }

                            if showAnyNameBlock {
                                MembershipAnyNameView(name: membership.anyName.formatted) {
                                    onSelectNameTap()
                                }
                            }

                            MembershipCellCardRow(text: Loc.Membership.Code.entry, icon: .disclosure) {
                                onActivateCodeTap()
                            }

                            MembershipCellCardRow(text: Loc.Membership.seeAllPlans, icon: .externalLink) {
                                safariUrl = URL(string: AboutApp.pricingLink)
                            }
                        }

                        // Footer sits at the bottom of the screen; on short content it is
                        // pushed down, on tall content it keeps a 44pt minimum gap.
                        Spacer(minLength: 44)

                        footer
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .frame(minHeight: proxy.size.height)
                }
            }
        }
        .safariSheet(url: $safariUrl)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsMembership()
        }
    }

    @MainActor
    private var footer: some View {
        VStack(spacing: 12) {
            AsyncButton {
                try await AppStore.sync()
            } label: {
                footerLabel(Loc.Membership.Legal.restorePurchases)
            }
            footerButton(Loc.Membership.askQuestion) {
                onAskQuestionTap()
            }
            footerButton(Loc.Membership.Legal.privacy) {
                safariUrl = URL(string: AboutApp.privacyPolicyLink)
            }
            footerButton(Loc.Membership.Legal.terms) {
                safariUrl = URL(string: AboutApp.termsLink)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func footerButton(_ text: String, action: @escaping () -> ()) -> some View {
        Button(action: action) {
            footerLabel(text)
        }
    }

    private func footerLabel(_ text: String) -> some View {
        AnytypeText(text, style: .calloutRegular)
            .foregroundStyle(Color.Text.secondary)
    }
}

#Preview {
    NavigationView {
        MembershipModuleView(
            membership: .mock(tier: nil),
            tiers: [.mockStarter, .mockBuilder, .mockCoCreator],
            onTierTap: { _ in },
            onActivateCodeTap: { },
            onAskQuestionTap: { },
            onSelectNameTap: { }
        )
    }
}
