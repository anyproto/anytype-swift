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
            Spacer()
            content
            Spacer()
        }
        .overlay(alignment: .bottom) {
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
            AnytypeText(Loc.Auth.JoinFlow.Key.title, style: .contentTitleSemibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(8)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Key.description,
                style: .uxCalloutRegular
            )
            .foregroundColor(.Text.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            
            Spacer.fixedHeight(24)
            
            phraseTextView
            
            Spacer.fixedHeight(18)
            
            readMore
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var readMore: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.Text.secondary)
            AnytypeText(Loc.Auth.JoinFlow.Key.Button.Info.title, style: .button1Medium)
                .foregroundColor(.Text.secondary)
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
            .blur(radius: model.keyShown ? 0 : 12)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 0) {
            StandardButton(model.keyShown ? Loc.Auth.JoinFlow.Key.Button.Saved.title : Loc.Auth.JoinFlow.Key.Button.Show.title,
                style: .primaryOvalLarge,
                action: {
                    model.onPrimaryButtonTap()
                }
            )
            .colorScheme(.light)
            
            if !model.keyShown {
                Spacer.fixedHeight(8)
                StandardButton(
                    Loc.Auth.JoinFlow.Key.Button.Later.title,
                    style: .linkLarge,
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
