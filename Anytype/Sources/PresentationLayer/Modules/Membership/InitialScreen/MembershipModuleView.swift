import SwiftUI
import StoreKit
import Services
import Combine


struct MembershipModuleView: View {
    @Environment(\.openURL) private var openURL
    @State private var safariUrl: URL?
    @Injected(\.accountManager) private var accountManager: AccountManagerProtocol
    
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
                    Spacer.fixedHeight(40)
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
                    .padding(.vertical, 32)
                    
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
            case .explorer, nil:
                MembershipBannersView()
            case .builder, .coCreator, .custom:
                EmptyView()
            }
        }
    }
    
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
            contactUs
            Spacer.fixedHeight(24)
            restorePurchases
        }
    }
    
    private var contactUs: some View {
        Button {
            let mailLink = MailUrl(
                to: AboutApp.licenseMailTo,
                subject: "\(Loc.Membership.Email.subject) \(accountManager.account.id)",
                body: Loc.Membership.Email.body
            )
            guard let mailUrl = mailLink.url else { return }
            openURL(mailUrl)
        } label: {
            Group {
                AnytypeText(
                    "\(Loc.Membership.Legal.wouldYouLike) ",
                    style: .caption1Regular
                ).foregroundColor(.Text.primary) +
                AnytypeText(
                    Loc.Membership.Legal.letUsKnow,
                    style: .caption1Regular
                ).foregroundColor(.Text.primary).underline()
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
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
