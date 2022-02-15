import SwiftUI

struct ErrorAlertView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    var errorText: String
    
    let presenting: Presenting
    let onOkPressed: () -> ()
    
    var body: some View {
        ZStack(alignment: .center) {
            self.presenting.blur(radius: self.isShowing ? 1 : 0)
            
            VStack() {
                AnytypeText(self.errorText, style: .body, color: .textPrimary)
                    .padding()
                    .layoutPriority(1)
                
                
                VStack(spacing: 0) {
                    AnytypeDivider()
                    Button(action: {
                        isShowing.toggle()
                        onOkPressed()
                    }) {
                        AnytypeText("Ok", style: .body, color: .buttonAccent)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: 300, minHeight: 0)
            .background(Color.backgroundSecondary)
            .cornerRadius(10)
            .transition(.slide)
            .shadow(color: Color.shadowPrimary, radius: 4)
            .opacity(self.isShowing ? 1 : 0)
        }
    }
    
}

struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            AnytypeText("ParentView", style: .body, color: .textPrimary)
        }
        return ErrorAlertView(isShowing: .constant(true), errorText: "Some Error long very long long long error", presenting: view, onOkPressed: {})
    }
}
