import SwiftUI

struct AlphaInviteCodeView: View {
    @StateObject var signUpData: SignUpData
    @State private var showCreateNewProfile = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            contentView
                .padding()
        }
        .navigationBarHidden(true)
    }
    
    
    private var contentView: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                AnytypeText("Enter your invitation code", style: .heading)
                    .padding(.bottom, 14)
                AnytypeText("Do not have invite", style: .uxCalloutRegular)
                    .lineSpacing(7)
                    .padding(.bottom, 14)

                CustomTextField(text: $signUpData.inviteCode, title: "Invitation code")
                    .font(AnytypeFontBuilder.font(textStyle: .uxBodyRegular))
                    .padding(.bottom, 24)
                
                HStack(spacing: 12) {
                    StandardButton(text: "Back", style: .secondary) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    NavigationLink(
                        destination: CreateNewProfileView(
                            viewModel: CreateNewProfileViewModel(),
                            showCreateNewProfile: $showCreateNewProfile
                        ).environmentObject(signUpData),
                        isActive: $showCreateNewProfile
                    ) {
                        StandardButtonView(disabled: signUpData.inviteCode.isEmpty, text: "Confirm", style: .primary)
                    }.disabled(signUpData.inviteCode.isEmpty)
                }
            }
            .navigationBarBackButtonHidden(true)
            .padding()
            .background(Color.background)
            .cornerRadius(16.0)
        }
    }
}

struct AlphaInviteCodeView_Previews: PreviewProvider {
    static var previews: some View {
        AlphaInviteCodeView(signUpData: SignUpData())
    }
}
