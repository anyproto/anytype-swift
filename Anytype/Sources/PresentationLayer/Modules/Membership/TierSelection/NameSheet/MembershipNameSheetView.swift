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
        content
            .background(Color.Background.primary)
            .onChange(of: name) { name in
                model.validateName(name: name)
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            info
            nameView
            AnytypeText("\(model.tier.paymentType.displayPrice ?? "") ", style: .title)
                .foregroundColor(.Text.primary) +
            AnytypeText(model.tier.paymentType.localizedPeriod ?? "", style: .relation1Regular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(15)
            AsyncStandardButton(
                text: Loc.payByCard,
                style: .primaryLarge
            ) {
                AnytypeAnalytics.instance().logClickMembership(type: .payByCard)
                try await model.purchase(name: name)
            }
            .disabled(!model.canBuyTier)
            Spacer.fixedHeight(40)
        }
        .padding(.horizontal, 20)
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
                nameInput
            case .alreadyBought:
                nameLabel
            }
        }
    }
    
    var nameInput: some View {
        VStack(spacing: 0) {
            HStack {
                TextField(Loc.myself, text: $name)
                    .textContentType(.username)
                AnytypeText(".any", style: .bodyRegular)
                    .foregroundColor(.Text.primary)
            }
            .padding(.vertical, 12)
            .newDivider()
            
            nameStatus
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
    
    var nameStatus: some View {
        HStack {
            Spacer()
            Group {
                switch model.state {
                case .default:
                    AnytypeText(Loc.minXCharacters(model.minimumNumberOfCharacters), style: .relation2Regular)
                        .foregroundColor(.Text.secondary)
                case .validating:
                    AnytypeText(Loc.Membership.NameForm.validating, style: .relation2Regular)
                        .foregroundColor(.Text.secondary)
                case .error(text: let text):
                    AnytypeText(text, style: .relation2Regular)
                        .foregroundColor(.Dark.red)
                case .validated:
                    AnytypeText(Loc.Membership.NameForm.validated, style: .relation2Regular)
                        .foregroundColor(.Dark.green)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 4)
            
            Spacer()
        }
        .lineLimit(1)
    }
}
