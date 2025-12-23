import SwiftUI
import Services


struct MembershipNameFinalizationView: View {
    @State private var model: MembershipNameFinalizationViewModel
    @State private var name = ""

    @Environment(\.dismiss) private var dismiss

    init(tier: MembershipTier) {
        _model = State(initialValue: MembershipNameFinalizationViewModel(tier: tier))
    }
    
    var body: some View {
        content
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            info
            
            MembershipNameValidationView(tier: model.tier, name: $name) { isValid in
                model.isNameValid = isValid
            }
            
            Spacer.fixedHeight(16)
            
            AsyncStandardButton(
                Loc.confirm,
                style: .primaryLarge
            ) {
                AnytypeAnalytics.instance().logClickMembership(type: .payByCard)
                try await model.finalize(name: name)
                dismiss()
            }.disabled(!model.isNameValid)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
    }
    
    var info: some View {
        Group {
            AnytypeText(Loc.Membership.NameForm.title, style: .bodySemibold)
                .foregroundStyle(Color.Text.primary)
            Spacer.fixedHeight(6)
            AnytypeText(Loc.Membership.NameForm.subtitle, style: .calloutRegular)
                .foregroundStyle(Color.Text.primary)
            Spacer.fixedHeight(10)
        }
    }
}

#Preview {
    MembershipNameFinalizationView(tier: .mockCustom)
}
