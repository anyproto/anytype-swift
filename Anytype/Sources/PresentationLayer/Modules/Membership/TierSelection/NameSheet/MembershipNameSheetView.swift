import SwiftUI
import Services
import StoreKit
 

struct MembershipNameSheetView: View {    
    @StateObject private var model: MembershipNameSheetViewModel
    @State private var name = ""
    
    init(tier: MembershipTier, anyName: AnyName, product: Product, onSuccessfulPurchase: @escaping (MembershipTier) -> ()) {
        _model = StateObject(
            wrappedValue: MembershipNameSheetViewModel(tier: tier, anyName: anyName, product: product, onSuccessfulPurchase: onSuccessfulPurchase)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            info
            nameView
            AnytypeText("\(model.tier.paymentType?.displayPrice ?? "") ", style: .title)
                .foregroundColor(.Text.primary) +
            AnytypeText(model.tier.paymentType?.localizedPeriod ?? "", style: .relation1Regular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(15)
            AsyncStandardButton(
                Loc.payByCard,
                style: .primaryLarge
            ) {
                AnytypeAnalytics.instance().logClickMembership(type: .payByCard)
                try await model.purchase(name: name)
            }
            .disabled(!model.canBuyTier)
            Spacer.fixedHeight(16)
            disclamer
            Spacer.fixedHeight(40)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
    }
    
    var info: some View {
        Group {
            switch model.anyNameAvailability {
            case .notAvailable, .alreadyBought:
                EmptyView()
            case .availableForPruchase:
                AnytypeText(Loc.Membership.NameForm.title, style: .bodySemibold)
                    .foregroundColor(.Text.primary)
                Spacer.fixedHeight(6)
                AnytypeText(Loc.Membership.NameForm.subtitle, style: .calloutRegular)
                    .foregroundColor(.Text.primary)
                Spacer.fixedHeight(10)
            }
        }
    }
    
    var nameView: some View {
        Group {
            switch model.anyNameAvailability {
            case .notAvailable:
                EmptyView()
            case .availableForPruchase:
                MembershipNameValidationView(tier: model.tier, name: $name) { isValid in
                    model.isNameValidated = isValid
                }
            case .alreadyBought:
                nameLabel
            }
        }
    }
    
    var nameLabel: some View {
        HStack {
            AnytypeText(model.anyName.handle, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
            Spacer()
            AnytypeText(model.anyName.extension.description, style: .bodyRegular)
                .foregroundColor(.Text.primary)
        }
        .padding(.vertical, 12)
        .newDivider()
    }
    
    var disclamer: some View {
        AnytypeText(
            Loc.agreementDisclamer(AboutApp.termsLink, AboutApp.privacyPolicyLink),
            style: .caption1Regular,
            enableMarkdown: true
        )
        .foregroundColor(.Text.tertiary)
        .accentColor(.Text.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 38)
    }
}
