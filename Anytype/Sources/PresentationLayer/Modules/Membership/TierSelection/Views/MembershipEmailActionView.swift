import SwiftUI


struct MembershipEmailActionView: View {
    @State var email = ""
    
    let action: (String) async throws -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(Loc.Membership.EmailForm.title, style: .bodyRegular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(6)
            AnytypeText(Loc.Membership.EmailForm.subtitle, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(10)
            TextField(Loc.eMail, text: $email)
                .textContentType(.emailAddress)
                .padding(.vertical, 12)
                .newDivider()
            
            Spacer.fixedHeight(20)
            AsyncStandardButton(
                text: Loc.submit,
                style: .primaryLarge
            ) {
                try await action(email)
            }
            .disabled(!email.isValidEmail())
            Spacer.fixedHeight(102)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

#Preview {
    MembershipEmailActionView { _ in
        
    }
}
