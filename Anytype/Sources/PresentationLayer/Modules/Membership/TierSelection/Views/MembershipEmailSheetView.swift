import SwiftUI


struct MembershipEmailSheetView: View {
    @State var email = ""
    @State var subscribeToNewsletter = true
    
    let action: (String, Bool) async throws -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(Loc.Membership.EmailForm.title, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(6)
            AnytypeText(Loc.Membership.EmailForm.subtitle, style: .calloutRegular, color: .Text.primary)
            Spacer.fixedHeight(10)
            TextField(Loc.eMail, text: $email)
                .textContentType(.emailAddress)
                .padding(.vertical, 12)
                .newDivider()
            Spacer.fixedHeight(15)
        
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                subscribeToNewsletter.toggle()
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    AnytypeCheckbox(checked: $subscribeToNewsletter)
                    AnytypeText(Loc.Membership.EmailForm.newsletter, style: .calloutRegular, color: .Text.primary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer.fixedHeight(31)
            AsyncStandardButton(
                text: Loc.submit,
                style: .primaryLarge
            ) {
                try await action(email, subscribeToNewsletter)
            }
            .disabled(!email.isValidEmail())
            Spacer.fixedHeight(102)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
    }
}

#Preview {
    MembershipEmailSheetView { _, _ in
        
    }
}
