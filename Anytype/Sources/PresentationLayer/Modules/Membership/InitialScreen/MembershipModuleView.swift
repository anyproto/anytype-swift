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
    
    init(
        membership: MembershipStatus,
        tiers: [MembershipTier],
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.membership = membership
        self.tiers = tiers
        self.onTierTap =  onTierTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScrollView {
                VStack {
                    Spacer.fixedHeight(35)
                    title
                    AnytypeText(Loc.Membership.Ad.subtitle, style: .relation2Regular)
                        .foregroundColor(.Text.primary)
                        .padding(.horizontal, 60)
                        .multilineTextAlignment(.center)
                    Spacer.fixedHeight(32)
                    
                    baners
                    MembershipTierListView(userMembership: membership, tiers: tiers) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onTierTap($0)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                    
                    legal
                }
            }
        }
        .safariSheet(url: $safariUrl)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsMembership()
        }
    }
    
    private var title: some View {
        Group {
            if Loc.Membership.Ad.title.latinCharactersOnly {
                AnytypeText(Loc.Membership.Ad.title, style: .riccioneBannerTitle)
            } else {
                AnytypeText(Loc.Membership.Ad.title, style: .interBannerTitle)
            }
        }
        .foregroundColor(.Text.primary)
        .padding(.horizontal, 20)
        .multilineTextAlignment(.center)
    }
    
    private var baners: some View {
        Group {
            switch membership.tier?.type {
            case .starter, .legacyExplorer, nil:
                MembershipBannersView()
            case .builder, .coCreator, .custom, .anyTeam, .explorer, .seatBasedTier:
                EmptyView()
            }
        }
    }
    
    @MainActor
    var legal: some View {
        VStack(alignment: .leading) {
            MembershipLegalButton(text: Loc.Membership.Legal.details) {
                safariUrl = URL(string: AboutApp.pricingLink)
            }
            MembershipLegalButton(text: Loc.Membership.Legal.privacy) { 
                safariUrl = URL(string: AboutApp.privacyPolicyLink)
            }
            MembershipLegalButton(text: Loc.Membership.Legal.terms) { 
                safariUrl = URL(string: AboutApp.termsLink)
            }
            
            Spacer.fixedHeight(32)
            restorePurchases
        }
    }
    
    
    private var restorePurchases: some View {
        AsyncButton {
            try await AppStore.sync()
        } label: {
            Group {
                AnytypeText(
                    "\(Loc.Membership.Legal.alreadyPurchasedTier) ",
                    style: .caption1Regular
                ).foregroundColor(.Text.primary) +
                AnytypeText(
                    Loc.Membership.Legal.restorePurchases,
                    style: .caption1Regular
                )
                .foregroundColor(.Text.primary).underline()
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationView {
        MembershipModuleView(
            membership: .empty,
            tiers: [],
            onTierTap: { _ in }
        )
    }
}
