import SwiftUI

struct JoinFlowInputView<ViewModel: JoinFlowInputProtocol>: View {
    
    @ObservedObject var model: ViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(model.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            Spacer.fixedHeight(16)
            
            input
            
            Spacer.fixedHeight(9)
            AnytypeText(model.description, style: .authBody, color: .Auth.body)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            
            Spacer()
            
            StandardButton(
                Loc.Auth.JoinFlow.next,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onNextAction()
                }
            )
            .colorScheme(model.inputText.isEmpty ? .dark : .light)
            .disabled(model.inputText.isEmpty)
        }
    }
    
    private var input: some View {
        AutofocusedTextField(
            placeholder: model.placeholder,
            placeholderFont: .authInput,
            text: $model.inputText
        )
            .disableAutocorrection(true)
            .textContentType(.password)
            .autocapitalization(.none)
            .font(AnytypeFontBuilder.font(anytypeFont: .authInput))
            .foregroundColor(.Auth.inputText)
            .padding(EdgeInsets(horizontal: 22, vertical: 18))
            .background(Color.Auth.input)
            .accentColor(.Auth.inputText)
            .cornerRadius(24)
    }
}

struct JoinFlowInputView_Previews: PreviewProvider {
    static var previews: some View {
        JoinFlowInputView(
            model: SoulViewModel(
                state: JoinFlowState(),
                output: nil,
                accountManager: DI.preview.serviceLocator.accountManager(),
                objectActionsService: DI.preview.serviceLocator.objectActionsService()
            )
        )
    }
}
