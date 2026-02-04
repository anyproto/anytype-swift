import SwiftUI
import Services


struct MembershipNameValidationView: View {
    @State private var model: MembershipNameValidationViewModel
    @Binding private var name: String

    private let onValidation: (Bool) -> ()

    init(tier: MembershipTier, name: Binding<String>, onValidation: @escaping (Bool) -> ()) {
        _name = name
        _model = State(initialValue: MembershipNameValidationViewModel(tier: tier))

        self.onValidation = onValidation
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField(Loc.myself, text: $name)
                    .textContentType(.username)
                AnytypeText(AnyNameExtension.anyName.description, style: .bodyRegular)
                    .foregroundStyle(Color.Text.primary)
            }
            .padding(.vertical, 12)
            .newDivider()
            
            nameStatus
        }
        .onChange(of: name) { _, name in
            model.validateName(name: name)
        }
        .onChange(of: model.state) { _, state in
            onValidation(state == .validated)
        }
    }
    
    var nameStatus: some View {
        HStack {
            Spacer()
            Group {
                switch model.state {
                case .default:
                    AnytypeText(Loc.minXCharacters(model.minimumNumberOfCharacters), style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                case .validating:
                    AnytypeText(Loc.Membership.NameForm.validating, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                case .error(text: let text):
                    AnytypeText(text, style: .relation2Regular)
                        .foregroundStyle(Color.Dark.red)
                case .validated:
                    AnytypeText(Loc.Membership.NameForm.validated, style: .relation2Regular)
                        .foregroundStyle(Color.Dark.green)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 4)
            
            Spacer()
        }
        .lineLimit(2)
    }

}

#Preview {
    MembershipNameValidationView(tier: .mockCustom, name: .constant("V00")) { _ in }
}
