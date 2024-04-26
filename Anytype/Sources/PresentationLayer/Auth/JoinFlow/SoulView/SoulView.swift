import SwiftUI

struct SoulView: View {
    
    @StateObject var model: SoulViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            Spacer()
            
            StandardButton(
                Loc.Auth.next,
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
            AnytypeText(Loc.Auth.JoinFlow.Soul.title, style: .heading, color: .Auth.inputText)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Soul.description,
                style: .calloutRegular,
                color: .Auth.body
            )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer.fixedHeight(16)
            
            input
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
            .padding(EdgeInsets(horizontal: 22, vertical: 23))
            .background(Color.Auth.input)
            .accentColor(.Auth.inputText)
            .cornerRadius(24)
            .frame(height: 68)
    }
}

struct JoinFlowInputView_Previews: PreviewProvider {
    static var previews: some View {
        SoulView(
            model: SoulViewModel(
                state: JoinFlowState(),
                output: nil,
                accountManager: DI.preview.serviceLocator.accountManager(),
                objectActionsService: DI.preview.serviceLocator.objectActionsService(),
                authService: DI.preview.serviceLocator.authService(),
                seedService: DI.preview.serviceLocator.seedService(),
                usecaseService: DI.preview.serviceLocator.usecaseService(),
                workspaceService: DI.preview.serviceLocator.workspaceService(),
                activeWorkspaceStorage: DI.preview.serviceLocator.activeWorkspaceStorage()
            )
        )
    }
}
