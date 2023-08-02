import SwiftUI

struct SoulView: View {
    
    @StateObject var model: SoulViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            Spacer()
            
            StandardButton(
                Loc.Auth.JoinFlow.Soul.Button.title,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onNextAction()
                }
            )
            .colorScheme(model.inputText.isEmpty ? .dark : .light)
            .disabled(model.inputText.isEmpty)
        }
        .onAppear {
            model.onAppear()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Soul.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            Spacer.fixedHeight(16)
            
            input
            
            Spacer.fixedHeight(9)
            AnytypeText(Loc.Auth.JoinFlow.Soul.description, style: .authBody, color: .Auth.body)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var input: some View {
        AutofocusedTextField(
            placeholder: Loc.Auth.JoinFlow.Soul.placeholder,
            placeholderFont: .authInput,
            text: $model.inputText
        )
            .disableAutocorrection(true)
            .textContentType(.password)
            .autocapitalization(.sentences)
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
        SoulView(
            model: SoulViewModel(
                state: JoinFlowState(),
                output: nil,
                accountManager: DI.preview.serviceLocator.accountManager(),
                objectActionsService: DI.preview.serviceLocator.objectActionsService()
            )
        )
    }
}
