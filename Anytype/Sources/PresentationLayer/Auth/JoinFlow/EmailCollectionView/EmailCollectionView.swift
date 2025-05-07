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
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Email.title, style: .heading)
                .foregroundColor(.Auth.inputText)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Email.description,
                style: .bodyRegular
            )
                .foregroundColor(.Auth.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer.fixedHeight(32)
            
            input
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var input: some View {
        VStack(spacing: 8) {
            AutofocusedTextField(
                placeholder: Loc.Auth.JoinFlow.Email.placeholder,
                font: .authInput,
                text: $model.inputText
            )
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textContentType(.emailAddress)
            .foregroundColor(.Auth.inputText)
            .padding(EdgeInsets(horizontal: 20, vertical: 20))
            .background(Color.Auth.input)
            .accentColor(.Text.tertiary)
            .cornerRadius(16)
            .frame(height: 64)
            
            if model.inputText.isNotEmpty && !model.inputText.isValidEmail() {
                AnytypeText(Loc.Auth.JoinFlow.Email.incorrectError, style: .caption1Regular)
                    .foregroundColor(.System.red)
                    .multilineTextAlignment(.center)
            }
        }
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
            .colorScheme(model.inputText.isValidEmail() ? .light : .dark)
            .disabled(!model.inputText.isValidEmail())
            
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
