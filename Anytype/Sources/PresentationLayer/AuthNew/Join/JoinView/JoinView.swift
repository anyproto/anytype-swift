import SwiftUI

struct JoinView: View {
    
    @StateObject private var model: JoinViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(state: JoinFlowState) {
        _model = StateObject(wrappedValue: JoinViewModel(state: state))
    }
    
    var body: some View {
        GeometryReader { geo in
            content(height: geo.size.height)
                .toolbar(.hidden)
                .fixTappableArea()
                .customBackSwipe {
                    guard !model.backButtonDisabled else { return }
                    model.onBack()
                }
        }
        .ifLet(model.errorText) { view, errorText in
            view.alertView(isShowing: $model.showError, errorText: errorText, onButtonTap: {})
        }
        .fitIPadToReadableContentGuide()
        .onChange(of: model.dismiss) { _ in dismiss() }
    }
    
    private func content(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            header
            
            Group {
                Spacer.fixedHeight(
                    UIDevice.isPad ? height / Constants.ipadOffsetFactor : Constants.topOffset
                )
                
                innerContent
                    .transition(model.forward ? .moveAndFadeForward: .moveAndFadeBack)
                
                Spacer.fixedHeight(12)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var header: some View {
        ModalNavigationHeader {
            backButton
        } titleView: {
            Image(asset: .logo)
                .foregroundColor(.Control.primary)
        } rightView: {
            EmptyView()
        }
    }
    
    private var backButton : some View {
        Button(action: {
            model.onBackButtonTap()
        }) {
            Image(asset: .X24.back)
                .foregroundColor(.Control.secondary)
        }
        .disabled(model.backButtonDisabled)
    }
    
    @ViewBuilder
    private var innerContent: some View {
        switch model.step {
        case .email:
            EmailCollectionView(state: model.state, output: model)
        case .personaInfo:
            JoinSelectionView(type: .persona, state: model.state, output: model)
        case .useCaseInfo:
            JoinSelectionView(type: .useCase, state: model.state, output: model)
        }
    }
}

extension JoinView {
    enum Constants {
        static let ipadOffsetFactor = 3.5
        static let topOffset: CGFloat = 20
    }
}
