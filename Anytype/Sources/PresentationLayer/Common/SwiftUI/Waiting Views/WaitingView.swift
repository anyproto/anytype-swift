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
            VStack(alignment: .leading) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    if !showError {
                        Image("clock")
                            .background(Circle().fill(Color.background)
                                .frame(width: 64, height: 64)
                        )
                            .frame(width: 64, height: 64)
                            .animation(.default)
                            .transition(.scale)
                    } else {
                        AnytypeText("Failed", style: .title)
                            .foregroundColor(.pureRed)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                    }
                    
                    AnytypeText(text, style: .bodyBold)
                    
                    if showError {
                        AnytypeText(errorText, style: .body)
                            .padding(.top, -10)
                            .transition(.opacity)
                        
                        StandardButton(disabled: false, text: "Ok", style: .secondary) {
                            presentationMode.wrappedValue.dismiss()
                            onErrorTap()
                        }
                        .transition(.opacity)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.background)
                .cornerRadius(12.0)
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView(text: "Setting up the wallet…", showError: .constant(false), errorText: .constant("Some error happens"), onErrorTap: {})
    }
}
