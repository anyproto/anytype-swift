import SwiftUI

struct VoidView: View {
    
    @ObservedObject var model: VoidViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            info
            
            Spacer()
            
            StandardButton(
                .text(Loc.Auth.next),
                style: .primaryLarge,
                action: {
                    model.onNextButtonTap()
                }
            )
            .colorScheme(.light)
        }
        .onAppear {
            model.onAppear()
        }
    }
    
    private var info: some View {
        VStack(spacing: 12) {
            AnytypeText(Loc.Auth.JoinFlow.Void.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            AnytypeText(Loc.Auth.JoinFlow.Void.description, style: .authBody, color: .Auth.body)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(100)
        }
        .padding(.horizontal, 24)
    }
}


struct VoidView_Previews : PreviewProvider {
    static var previews: some View {
        VoidView(model: VoidViewModel(output: nil))
    }
}
