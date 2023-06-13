import SwiftUI

struct LoginView: View {
    
    @ObservedObject var model: LoginViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    var body: some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationTitle(Loc.login)
            .navigationBarTitleDisplayMode(.inline)
            .background(TransparentBackground())
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
            .fitIPadToReadableContentGuide()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            AuthMultilineTextField(
                text: $model.key,
                showText: .constant(true)
            )
            .focused($model.autofocus)
            
            Spacer.fixedHeight(16)

            buttonsBlock
            
            Spacer()
        }
    }
    
    private var buttonsBlock : some View {
        VStack(spacing: 12) {
            StandardButton(
                Loc.Auth.next,
                style: .primaryLarge,
                action: {}
            )
            .colorScheme(model.key.isEmpty ? .dark : .light)
            .disabled(model.key.isEmpty)
            
            AnytypeText(
                Loc.Auth.LoginFlow.or,
                style: .caption2Medium,
                color: .Auth.inputText
            )
            
            StandardButton(
                Loc.scanQRCode,
                style: .secondaryLarge,
                action: {}
            )
            
            StandardButton(
                Loc.Auth.LoginFlow.Use.Keychain.title,
                style: .secondaryLarge,
                action: {}
            )
        }
    }
    
    private var backButton : some View {
        Button(action: {
            presentationMode.dismiss()
        }) {
            Image(asset: .backArrow)
                .foregroundColor(.Text.tertiary)
        }
    }
}


struct LoginView_Previews : PreviewProvider {
    static var previews: some View {
        LoginView(
            model: LoginViewModel()
        )
    }
}
