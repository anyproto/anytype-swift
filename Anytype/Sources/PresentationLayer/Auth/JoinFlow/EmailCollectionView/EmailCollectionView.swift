import SwiftUI

struct EmailCollectionView: View {
    
    @StateObject private var model: EmailCollectionViewModel
    
    init(state: JoinFlowState, output: (any JoinFlowStepOutput)?) {
        _model = StateObject(wrappedValue: EmailCollectionViewModel(state: state, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            Spacer()
            
            buttons
        }
        .onAppear {
            model.onAppear()
        }
        .task(item: model.saveEmailTaskId) { _ in
            await model.saveEmail()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Email.title, style: .contentTitleSemibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(8)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Email.description,
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
        ZStack {
            VStack(spacing: 4) {
                if model.showIncorrectEmailError {
                    AnytypeText(Loc.Auth.JoinFlow.Email.incorrectError, style: .caption1Regular)
                        .foregroundColor(.System.red)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                AutofocusedTextField(
                    placeholder: Loc.Auth.JoinFlow.Email.placeholder,
                    font: .authInput,
                    text: $model.inputText
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .foregroundColor(.Auth.inputText)
                .accentColor(.Text.tertiary)
            }
            .padding(.horizontal, 20)            
        }
        .frame(height: 64)
        .background(Color.Shape.transperentSecondary)
        .cornerRadius(16)
    }
    
    private var buttons: some View {
        VStack(spacing: 8) {
            StandardButton(
                Loc.continue,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onNextAction()
                }
            )
            .colorScheme(.light)
            
            StandardButton(
                Loc.skip,
                style: .secondaryLarge,
                action: {
                    model.onSkipAction()
                }
            )
        }
    }
}
