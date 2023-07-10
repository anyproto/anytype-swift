import SwiftUI

struct JoinFlowView: View {
    
    @ObservedObject var model: JoinFlowViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    var body: some View {
        GeometryReader { geo in
            content(height: geo.size.height)
        }
        .customBackSwipe {
            guard !model.disableBackAction else { return }
            if model.step.isFirst {
                 presentationMode.dismiss()
             } else {
                 model.onBack()
             }
        }
        .ifLet(model.errorText) { view, errorText in
            view.alertView(isShowing: $model.showError, errorText: errorText)
        }
        .fitIPadToReadableContentGuide()
    }
    
    private func content(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(14)
            
            navigationBar
            
            Spacer.fixedHeight(height / Constants.offsetFactor)
            
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
            LineProgressBar(
                percent: model.percent,
                configuration: model.progressBarConfiguration
            )
            HStack {
                backButton
                Spacer()
                counter
            }
        }
        .opacity(model.showNavigation ? 1 : 0)
    }
    
    private var backButton : some View {
        Button(action: {
            if model.step.isFirst {
                presentationMode.dismiss()
            } else {
                model.onBack()
            }
        }) {
            Image(asset: .backArrow)
                .foregroundColor(.Text.tertiary)
        }
        .disabled(model.disableBackAction)
    }
    
    private var counter : some View {
        AnytypeText(model.counter, style: .authBody, color: .Text.tertiary)
    }
}


struct JoinFlowView_Previews : PreviewProvider {
    static var previews: some View {
        JoinFlowView(
            model: JoinFlowViewModel(
                output: nil,
                applicationStateService: DI.preview.serviceLocator.applicationStateService()
            )
        )
    }
}

extension JoinFlowView {
    enum Constants {
        static let offsetFactor = UIDevice.isPad ? 3.0 : 4.5
    }
}
