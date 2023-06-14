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
            Spacer()
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
