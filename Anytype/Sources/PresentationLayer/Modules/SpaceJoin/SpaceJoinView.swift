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
            ScreenStateView(state: model.state, error: model.errorMessage) {
                content
            }
        }
        .multilineTextAlignment(.center)
        .background(Color.Background.secondary)
        .snackbar(toastBarData: $model.toast)
        .anytypeSheet(isPresented: $model.showSuccessAlert, cancelAction: { model.onDismissSuccessAlert() }) {
            requestSent
        }
        .task {
            await model.onAppear()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.dataState {
        case .requestSent:
            requestSent
        case .invite:
            invite
        case .alreadyJoined:
            alreadyJoined
        }
    }
    
    private var requestSent: some View {
        SpaceJoinConfirmationView(onDone: {
            model.onDismissSuccessAlert()
        }, onManageSpaces: {
            model.onTapManageSpaces()
        })
        .onAppear {
            model.onRequestSentAppear()
        }
    }
    
    private var invite: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ButtomAlertHeaderImageView(icon: .BottomAlert.mail, style: .color(.blue))
            Spacer.fixedHeight(15)
            AnytypeText(Loc.SpaceShare.Join.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(16)
            AnytypeText(model.message, style: .bodyRegular, enableMarkdown: true)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(16)
            AsyncStandardButton(text: Loc.SpaceShare.Join.button, style: .primaryLarge) {
                try await model.onJoin()
            }
            Spacer.fixedHeight(20)
            AnytypeText(Loc.SpaceShare.Join.info, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 30)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            model.onInviewViewAppear()
        }
    }
    
    private var alreadyJoined: some View {
        BottomAlertView(title: Loc.SpaceShare.AlreadyJoin.title) {
            BottomAlertButton(
                text: Loc.SpaceShare.AlreadyJoin.openSpace,
                style: .secondary,
                action: {
                    try await model.onTapGoToSpace()
                }
            )
            BottomAlertButton(
                text: Loc.cancel,
                style: .warning,
                action: {
                    model.onDismissSuccessAlert()
                }
            )
        }
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
