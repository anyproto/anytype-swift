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
            } loading: {
                invite(placeholder: true)
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
            invite(placeholder: false)
        case .alreadyJoined:
            alreadyJoined
        case .inviteNotFound:
            inviteNotFound
        case .spaceDeleted:
            spaceDeleted
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
    
    private func invite(placeholder: Bool) -> some View {
        VStack(spacing: 0) {
            Image(asset: .BottomAlert.mail)
            Spacer.fixedHeight(15)
            AnytypeText(Loc.SpaceShare.Join.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(model.message, style: .bodyRegular, enableMarkdown: true)
                .foregroundColor(.Text.primary)
                .if(placeholder) {
                    $0.redacted(reason: .placeholder)
                }
            Spacer.fixedHeight(19)
            AsyncStandardButton(Loc.SpaceShare.Join.button, style: .primaryLarge) {
                try await model.onJoin()
            }
            .if(placeholder) {
                $0.redacted(reason: .placeholder)
            }
            Spacer.fixedHeight(17)
            AnytypeText(Loc.SpaceShare.Join.info, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 16)
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
    
    private var inviteNotFound: some View {
        BottomAlertView(
            title: Loc.SpaceShare.Join.NoAccess.title,
            message: Loc.SpaceShare.Join.InviteNotFound.message,
            icon: .BottomAlert.error
        ) {
            BottomAlertButton(
                text: Loc.okay,
                style: .secondary,
                action: {
                    model.onDismissInviteNotFoundAlert()
                }
            )
        }
    }
    
    private var spaceDeleted: some View {
        BottomAlertView(
            title: Loc.SpaceShare.Join.spaceDeleted,
            icon: .BottomAlert.error
        ) {
            BottomAlertButton(
                text: Loc.okay,
                style: .secondary,
                action: {
                    model.onDismissInviteNotFoundAlert()
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
