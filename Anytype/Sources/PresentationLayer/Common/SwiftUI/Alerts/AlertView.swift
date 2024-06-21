import SwiftUI

struct AlertView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    var errorText: String
    
    let presenting: Presenting
    let onButtonTap: () -> ()
    
    var body: some View {
        ZStack(alignment: .center) {
            presenting
            Color.clear
                .fixTappableArea()
                .hidden(!isShowing)
            content
        }
    }
    
    private var content: some View {
        VStack(spacing: 18) {
            AnytypeText(errorText, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .padding(.horizontal, 8)
                .multilineTextAlignment(.center)
            
            StandardButton(
                Loc.ok,
                style: .primaryLarge,
                action: {
                    isShowing.toggle()
                    onButtonTap()
                }
            )
        }
        .padding(32)
        .frame(maxWidth: 300)
        .background(Color.Background.black)
        .cornerRadius(8)
        .transition(.slide)
        .hidden(!isShowing)
    }
    
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            AnytypeText("ParentView", style: .bodyRegular)
                .foregroundColor(.Text.primary)
        }
        return AlertView(isShowing: .constant(true), errorText: "Some Error long very long long long error", presenting: view, onButtonTap: {})
    }
}
