import SwiftUI

struct WaitingView: View {
    let text: String
    @Binding var showError: Bool
    @Binding var errorText: String
    
    var onErrorTap: (() -> ())
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            bottomSheet
        }
        .navigationBarHidden(true)
        .onChange(of: showError) { showError in
            if showError {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            contentView
                .padding(20)
        }
    }
    
    private var contentView: some View {
        VStack() {
            VStack(alignment: .center, spacing: 0) {
                LoadingAnimationView(showError: $showError)
                    .padding(.top, 24)
                    .padding(.bottom, 15)
                AnytypeText(showError ? errorText : text, style: .heading)
                    .padding(.bottom, 19)
                if showError {
                    StandardButton(disabled: false, text: "Dismiss", style: .secondary) {
                        presentationMode.wrappedValue.dismiss()
                        onErrorTap()
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .cornerRadius(16.0)
    }
    
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView(text: "Setting up the wallet…", showError: .constant(false), errorText: .constant("Some error happens"), onErrorTap: {})
    }
}
