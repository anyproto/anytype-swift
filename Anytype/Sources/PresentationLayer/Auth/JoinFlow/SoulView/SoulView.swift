import SwiftUI

struct SoulView: View {
    
    @StateObject private var model: SoulViewModel
    
    init(state: JoinFlowState, output: (any JoinFlowStepOutput)?) {
        _model = StateObject(wrappedValue: SoulViewModel(state: state, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            Spacer()
            
            StandardButton(
                Loc.continue,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onNextAction()
                }
            )
            .colorScheme(.light)
        }
        .task {
            await model.startParticipantTask()
        }
        .onAppear {
            model.onAppear()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Soul.title, style: .contentTitleSemibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(8)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Soul.description,
                style: .bodyRegular
            )
            .foregroundColor(.Text.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            
            Spacer.fixedHeight(24)
            
            input
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var input: some View {
        AutofocusedTextField(
            placeholder: model.generatedNamePlaceholder,
            font: .authInput,
            text: $model.inputText
        )
        .disableAutocorrection(true)
        .autocapitalization(.sentences)
        .foregroundColor(.Auth.inputText)
        .padding(EdgeInsets(horizontal: 20, vertical: 20))
        .background(Color.Shape.transperentSecondary)
        .accentColor(.Text.tertiary)
        .cornerRadius(16)
        .frame(height: 64)
    }
}

struct JoinFlowInputView_Previews: PreviewProvider {
    static var previews: some View {
        SoulView(state: JoinFlowState(), output: nil)
    }
}
