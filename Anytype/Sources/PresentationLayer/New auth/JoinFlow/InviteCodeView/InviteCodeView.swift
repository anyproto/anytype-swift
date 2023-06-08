import SwiftUI

struct InviteCodeView: View {
    @ObservedObject var model: InviteCodeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.InterCode.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            Spacer.fixedHeight(16)
            
            inviteCodeInput
            
            Spacer.fixedHeight(9)
            AnytypeText(Loc.Auth.JoinFlow.InterCode.description, style: .authBoby, color: .Auth.body)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            
            Spacer()
            
            StandardButton(
                Loc.Auth.JoinFlow.next,
                style: .primaryLarge,
                action: {
                    model.onNextButtonTap()
                }
            )
            .colorScheme(model.inviteCode.isEmpty ? .dark : .light)
            .disabled(model.inviteCode.isEmpty)
        }
    }
    
    private var inviteCodeInput: some View {
        AutofocusedTextField(
            placeholder: "",
            placeholderFont: .authInput,
            text: $model.inviteCode
        )
            .disableAutocorrection(true)
            .textContentType(.password)
            .autocapitalization(.none)
            .font(AnytypeFontBuilder.font(anytypeFont: .authInput))
            .foregroundColor(.Text.tertiary)
            .padding(EdgeInsets(horizontal: 22, vertical: 24))
            .background(Color.Auth.input)
            .accentColor(Color.Auth.body)
            .cornerRadius(24)
    }
}

struct InviteCodeView_Previews: PreviewProvider {
    static var previews: some View {
        InviteCodeView(
            model: InviteCodeViewModel(output: nil)
        )
    }
}
