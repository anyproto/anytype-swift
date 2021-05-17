import SwiftUI

struct WaitingView: View {
    var text: String
    var errorState: Bool
    var errorText: String?
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.loginBackground, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    if !errorState {
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
                    
                    if errorState, let errorText = errorText {
                        AnytypeText(errorText, style: .body)
                            .padding(.top, -10)
                            .transition(.opacity)
                        
                        StandardButton(disabled: false, text: "Ok", style: .secondary) {
                            self.presentationMode.wrappedValue.dismiss()
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
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView(text: "Setting up the wallet…", errorState: false, errorText: "Some error happens")
    }
}


struct WaitingViewModifier: ViewModifier {
    var showWaitingView: Bool = false
    var text: String
    var errorState: Bool
    var errorText: String?
    
    func body(content: Content) -> some View {
        VStack {
            if showWaitingView {
                WaitingView(text: text, errorState: errorState, errorText: errorText)
            } else {
                content
            }
        }
    }
}
