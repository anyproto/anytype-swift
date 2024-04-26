import SwiftUI

struct VaultView: View {
    
    @StateObject private var model: VaultViewModel
    
    init(state: JoinFlowState, output: JoinFlowStepOutput?) {
        _model = StateObject(wrappedValue: VaultViewModel(state: state, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            Spacer()
            
            StandardButton(
                Loc.Auth.JoinFlow.Vault.button,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onNextAction()
                }
            )
            .colorScheme(.light)
        }
        .onAppear {
            model.onAppear()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Vault.title, style: .heading)
                .foregroundColor(.Auth.inputText)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Vault.description,
                style: .bodyRegular
            )
                .foregroundColor(.Auth.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
}

#Preview {
    VaultView(state: JoinFlowState(), output: nil)
}
