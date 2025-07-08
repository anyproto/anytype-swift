import SwiftUI

struct MigrationView: View {
    
    @StateObject private var model: MigrationViewModel
    @Environment(\.dismiss) var dismiss
    
    private let topOffcet: CGFloat = UIDevice.isPad ? 310 : 180
    
    init(data: MigrationModuleData, output: (any MigrationModuleOutput)?) {
        _model = StateObject(wrappedValue: MigrationViewModel(data: data, output: output))
    }
    
    var body: some View {
        content
            .task(item: model.startFlowId) { _ in
                await model.startFlow()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .padding(.horizontal, 20)
            .onTapGesture(count: 5) {
                model.onDebugTap()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .initial:
            initialState
        case .progress:
            progressState
        case .error(title: let title, message: let message):
            errorState(title: title, message: message)
        }
    }
    
    private var initialState: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(topOffcet)
            IllustrationView(icon: .Illustration.loading, color: .blue)
            Spacer.fixedHeight(16)
            AnytypeText(Loc.Migration.Initial.title, style: .title)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Migration.Initial.subtitle1, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Migration.Initial.subtitle2, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            
            StandardButton(
                Loc.Migration.Initial.startUpdate,
                style: .primaryLarge,
                action: {
                    model.startUpdate()
                }
            )
            Spacer.fixedHeight(20)
            StandardButton(
                Loc.Migration.Initial.readMore,
                style: .secondaryLarge,
                action: {
                    model.readMore()
                }
            )
        }
    }
    
    private var progressState: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(topOffcet)
            progressHeader
            Spacer.fixedHeight(20)
            AnytypeText(Loc.Migration.Progress.title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Migration.Progress.subtitle, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    private var progressHeader: some View {
        ZStack {
            IllustrationView(icon: nil, color: .blue)
            CircularProgressBar(progress: $model.progress)
                .frame(width: 80, height: 80)
        }
    }
    
    private func errorState(title: String, message: String) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(topOffcet)
            IllustrationView(icon: .Illustration.exclamation, color: .red)
            Spacer.fixedHeight(16)
            AnytypeText(title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(8)
            AnytypeText(message, style: .uxCalloutRegular)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            StandardButton(
                Loc.tryAgain,
                style: .primaryLarge,
                action: {
                    model.tryAgainTapped()
                }
            )
        }
    }
}
