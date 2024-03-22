import Foundation
import SwiftUI

struct SpaceJoinView: View {
    
    @StateObject private var model: SpaceJoinViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceJoinModuleData, onManageSpaces: @escaping () -> Void) {
        self._model = StateObject(wrappedValue: SpaceJoinViewModel(data: data, onManageSpaces: onManageSpaces))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScreenStateView(state: model.state, error: model.errorMessage) {
                content
            }
        }
        .multilineTextAlignment(.center)
        .background(Color.Background.secondary)
        .snackbar(toastBarData: $model.toast)
        .anytypeSheet(isPresented: $model.showSuccessAlert, cancelAction: { model.onDismissSuccessAlert() }) {
            SpaceJoinConfirmationView(onDone: {
                model.onDismissSuccessAlert()
            }, onManageSpaces: {
                model.onTapManageSpaces()
            })
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            // TODO: Add icon
            ButtomAlertHeaderImageView(icon: .BottomAlert.update, style: .color(.blue))
            Spacer.fixedHeight(15)
            AnytypeText(Loc.SpaceShare.Join.title, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(16)
            AnytypeText(model.message, style: .bodyRegular, color: .Text.primary)
            Spacer.fixedHeight(16)
            AsyncStandardButton(text: Loc.SpaceShare.Join.button, style: .primaryLarge) {
                try await model.onJoin()
            }
            Spacer.fixedHeight(20)
            AnytypeText(Loc.SpaceShare.Join.info, style: .caption1Regular, color: .Text.secondary)
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 30)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Default") {
    SpaceJoinView(data: SpaceJoinModuleData(cid: "", key: ""), onManageSpaces: {})
}

#Preview("Sheet") {
    Color.black.anytypeSheet(isPresented: .constant(true)) {
        SpaceJoinView(data: SpaceJoinModuleData(cid: "", key: ""), onManageSpaces: {})
    }
}
