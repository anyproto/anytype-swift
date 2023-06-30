import SwiftUI

struct LegacyErrorAlertView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    var errorText: String
    
    let presenting: Presenting
    let onOkPressed: () -> ()
    
    var body: some View {
        ZStack(alignment: .center) {
            self.presenting.blur(radius: self.isShowing ? 1 : 0)
            
            VStack() {
                AnytypeText(self.errorText, style: .bodyRegular, color: .Text.primary)
                    .padding()
                    .layoutPriority(1)
                
                
                VStack(spacing: 0) {
                    AnytypeDivider()
                    Button(action: {
                        isShowing.toggle()
                        onOkPressed()
                    }) {
                        AnytypeText("Ok", style: .bodyRegular, color: .Button.accent)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: 300, minHeight: 0)
            .background(Color.Background.secondary)
            .cornerRadius(10)
            .transition(.slide)
            .shadow(color: Color.Shadow.primary, radius: 4)
            .opacity(self.isShowing ? 1 : 0)
        }
    }
    
}

struct LegacyErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            AnytypeText("ParentView", style: .bodyRegular, color: .Text.primary)
        }
        return LegacyErrorAlertView(isShowing: .constant(true), errorText: "Some Error long very long long long error", presenting: view, onOkPressed: {})
    }
}
