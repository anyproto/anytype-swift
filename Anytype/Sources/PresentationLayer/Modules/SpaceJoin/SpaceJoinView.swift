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
                invite(placeholder: true, withoutApprove: model.dataState.inviteWithoutApprove)
            }
        }
        .multilineTextAlignment(.center)
        .background(Color.Background.secondary)
        .snackbar(toastBarData: $model.toast)
        .anytypeSheet(isPresented: $model.showSuccessAlert, cancelAction: { model.onDismissSuccessAlert() }) {
            requestSent
        }
        .task(item: model.joinTaskId) { _ in
            await model.onJoin()
        }
        .task {
            await model.onAppear()
        }
        .onChange(of: model.dismiss) {
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
        case let .invite(withoutApprove):
            invite(placeholder: false, withoutApprove: withoutApprove)
        case .alreadyJoined:
            alreadyJoined
        case .inviteNotFound:
            inviteNotFound
        case .spaceDeleted:
            spaceDeleted
        case .limitReached:
            limitReached
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
    
    private func invite(placeholder: Bool, withoutApprove: Bool) -> some View {
        VStack(spacing: 0) {
            Image(asset: .Dialog.invite)
            Spacer.fixedHeight(15)
            AnytypeText(model.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(model.message, style: .bodyRegular, enableMarkdown: true)
                .foregroundColor(.Text.primary)
                .if(placeholder) {
                    $0.redacted(reason: .placeholder)
                }
            Spacer.fixedHeight(19)
            StandardButton(model.button, style: .primaryLarge) {
                model.onJoinTapped()
            }
            .if(placeholder) {
                $0.redacted(reason: .placeholder)
            }
            
            if !placeholder {
                if withoutApprove {
                    Spacer.fixedHeight(8)
                    StandardButton(Loc.cancel, style: .secondaryLarge, action: {
                        model.onCancel()
                    })
                } else {
                    Spacer.fixedHeight(17)
                    AnytypeText(Loc.SpaceShare.Join.info, style: .caption1Regular)
                        .foregroundColor(.Text.secondary)
                }
            }
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
            icon: .Dialog.lock
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
            icon: .Dialog.duck
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
    
    private var limitReached: some View {
        BottomAlertView(
            title: Loc.SpaceShare.Join.LimitReached.title,
            message: Loc.SpaceShare.Join.LimitReached.message,
            icon: .Dialog.duck
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
