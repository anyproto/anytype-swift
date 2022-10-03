import SwiftUI

struct AlphaInviteCodeView: View {
    @StateObject var signUpData: SignUpData
    @State private var showCreateNewProfile = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Gradients.mainBackground()
            bottomSheet
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.invitaionScreenShow)
        }
    }
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            contentView
                .horizontalReadabilityPadding(20)
                .padding(.bottom, 20)
        }
    }
    
    
    private var contentView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(Loc.enterYourInvitationCode, style: .heading, color: .textPrimary)
                Spacer.fixedHeight(11)
                AnytypeText(Loc.doNotHaveInvite, style: .uxCalloutRegular, color: .textPrimary)
                Spacer.fixedHeight(30)
                
                AutofocusedTextField(
                    placeholder: Loc.SignUp.InvintationCode.placeholder,
                    placeholderFont: .uxBodyRegular,
                    text: $signUpData.inviteCode
                )
                    .disableAutocorrection(true)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                    .foregroundColor(.textPrimary)
                    .divider(spacing: 11.5)
                Spacer.fixedHeight(20)
                
                buttons
            }
            .padding(EdgeInsets(top: 23, leading: 20, bottom: 10, trailing: 20))
        }
        .background(Color.backgroundPrimary)
        .cornerRadius(16.0)
    }
    
    private var buttons: some View {
        HStack(spacing: 10) {
            StandardButton(text: Loc.back, style: .secondary) {
                presentationMode.wrappedValue.dismiss()
            }
            
            NavigationLink(
                destination: CreateNewProfileView(
                    viewModel: CreateNewProfileViewModel(seedService: ServiceLocator.shared.seedService()),
                    showCreateNewProfile: $showCreateNewProfile
                ).environmentObject(signUpData),
                isActive: $showCreateNewProfile
            ) {
                StandardButtonView(disabled: signUpData.inviteCode.isEmpty, text: "Confirm", style: .primary)
            }
            .disabled(signUpData.inviteCode.isEmpty)
            .buttonStyle(ShrinkingButtonStyle())
        }
    }
}

struct AlphaInviteCodeView_Previews: PreviewProvider {
    static var previews: some View {
        AlphaInviteCodeView(signUpData: SignUpData(mnemonic: UUID().uuidString))
    }
}
