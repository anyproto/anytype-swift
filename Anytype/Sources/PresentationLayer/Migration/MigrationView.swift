import SwiftUI

struct MigrationView: View {
    
    @StateObject private var model: MigrationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showPublicDebugMenu = false
    
    init(data: MigrationModuleData) {
        _model = StateObject(wrappedValue: MigrationViewModel(data: data))
    }
    
    var body: some View {
        content
            .task(id: model.startFlowId) {
                await model.startFlow()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .padding(.horizontal, 20)
            .onTapGesture(count: 5) {
                showPublicDebugMenu.toggle()
            }
            .sheet(isPresented: $showPublicDebugMenu) {
                PublicDebugMenuView()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .progress:
            progressState
        case .error(title: let title, message: let message):
            errorState(title: title, message: message)
        }
    }
    
    private var progressState: some View {
        VStack(spacing: 0) {
            CircularProgressBar(progress: $model.progress)
                .frame(width: 88, height: 88)
            Spacer.fixedHeight(20)
            AnytypeText(Loc.Migration.title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Migration.subtitle, style: .calloutRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func errorState(title: String, message: String) -> some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.exclamation, style: .color(.red))
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
                Loc.Error.Common.tryAgain,
                style: .primaryLarge,
                action: {
                    model.tryAgainTapped()
                }
            )
        }
    }
}
