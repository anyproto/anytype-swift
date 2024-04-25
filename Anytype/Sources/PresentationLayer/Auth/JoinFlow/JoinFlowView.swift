import SwiftUI

struct JoinFlowView: View {
    
    @StateObject private var model: JoinFlowViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(output: JoinFlowOutput?) {
        _model = StateObject(wrappedValue: JoinFlowViewModel(output: output))
    }
    
    var body: some View {
        GeometryReader { geo in
            if !model.hideContent {
                content(height: geo.size.height)
            }
        }
        .customBackSwipe {
            guard !model.disableBackAction else { return }
            if model.step.isFirst {
                 dismiss()
             } else {
                 model.onBack()
             }
        }
        .ifLet(model.errorText) { view, errorText in
            view.alertView(isShowing: $model.showError, errorText: errorText, onButtonTap: {})
        }
        .fitIPadToReadableContentGuide()
    }
    
    private func content(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(14)
            
            navigationBar
            
            Spacer.fixedHeight(
                UIDevice.isPad ? height / Constants.offsetFactor : Constants.topOffset
            )
            
            model.content()
                .transition(model.forward ? .moveAndFadeForward: .moveAndFadeBack)
            
            Spacer.fixedHeight(14)
        }
        .navigationBarHidden(true)
        .background(TransparentBackground())
        .padding(.horizontal, 16)
    }
    
    private var navigationBar : some View {
        VStack(spacing: 13) {
            HStack {
                Spacer()
                counter
                Spacer()
            }
            .overlay(alignment: .leading, content: {
                backButton
            })
        }
        .frame(height: 44)
    }
    
    private var backButton : some View {
        Button(action: {
            if model.step.isFirst {
                dismiss()
            } else {
                model.onBack()
            }
        }) {
            Image(asset: .X18.slashMenuArrow)
                .foregroundColor(.Button.active)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
        }
        .disabled(model.disableBackAction)
    }
    
    private var counter : some View {
        AnytypeText(model.counter, style: .authBody)
            .foregroundColor(.Button.active)
    }
}


struct JoinFlowView_Previews : PreviewProvider {
    static var previews: some View {
        JoinFlowView(output: nil)
    }
}

extension JoinFlowView {
    enum Constants {
        static let offsetFactor = UIDevice.isPad ? 3.5 : 4.5
        static let topOffset: CGFloat = 36
    }
}
