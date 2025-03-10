import SwiftUI

struct KeyPhraseView: View {
    
    @StateObject private var model: KeyPhraseViewModel
    
    init(state: JoinFlowState, output: (any JoinFlowStepOutput)?) {
        _model = StateObject(
            wrappedValue: KeyPhraseViewModel(state: state, output: output)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            Spacer()
            buttons
        }
        .snackbar(toastBarData: $model.snackBar)
        .onAppear {
            model.onAppear()
        }
        .sheet(isPresented: $model.showMoreInfo) {
            model.keyPhraseMoreInfo()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Key.title, style: .heading)
                .foregroundColor(.Auth.inputText)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Key.description,
                style: .bodyRegular
            )
            .foregroundColor(.Auth.body)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            
            Spacer.fixedHeight(18)
            
            phraseTextView
            
            Spacer.fixedHeight(18)
            
            readMore
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var readMore: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.Auth.body)
            AnytypeText(Loc.Auth.JoinFlow.Key.Button.Info.title, style: .button1Medium)
                .foregroundColor(.Auth.body)
        }
        .fixTappableArea()
        .onTapGesture {
            model.showMoreInfo.toggle()
        }
    }
    
    private var phraseTextView: some View {
        Button {
            model.onPhraseTap()
        } label: {
            PhraseTextView(
                text: $model.key,
                noninteractive: true,
                alignTextToCenter: true,
                hideWords: !model.keyShown
            )
            .disabled(true)
            .blur(radius: model.keyShown ? 0 : 5)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 0) {
            StandardButton(model.keyShown ? Loc.Auth.JoinFlow.Key.Button.Saved.title : Loc.Auth.JoinFlow.Key.Button.Show.title,
                style: .primaryLarge,
                action: {
                    model.onPrimaryButtonTap()
                }
            )
            .colorScheme(.light)
            
            if !model.keyShown {
                Spacer.fixedHeight(13)
                StandardButton(
                    Loc.Auth.JoinFlow.Key.Button.Later.title,
                    style: .secondaryLarge,
                    action: {
                        model.onSecondaryButtonTap()
                    }
                )
            }
        }
    }
}


#Preview {
    KeyPhraseView(state: JoinFlowState(), output: nil)
}
