import Foundation
import SwiftUI
import Services

@MainActor
@Observable
final class ObjectSettingsMenuViewModel {

    var menuConfig = ObjectMenuConfiguration(sections: [])

    @ObservationIgnored
    let viewModel: ObjectSettingsViewModel

    var showConflictAlert: Binding<Bool> {
        Binding(
            get: { self.viewModel.showConflictAlert },
            set: { self.viewModel.showConflictAlert = $0 }
        )
    }

    var toastData: Binding<ToastBarData?> {
        Binding(
            get: { self.viewModel.toastData },
            set: { self.viewModel.toastData = $0 }
        )
    }

    var showDeleteChatConfirmation: Binding<Bool> {
        Binding(
            get: { self.viewModel.showDeleteChatConfirmation },
            set: { self.viewModel.showDeleteChatConfirmation = $0 }
        )
    }

    init(viewModel: ObjectSettingsViewModel) {
        self.viewModel = viewModel
        setupSubscriptions()
    }

    func startTasks() async {
        await viewModel.startDocumentTask()
    }

    func onTapResolveConflictApprove() async throws {
        try await viewModel.onTapResolveConflictApprove()
    }

    private func setupSubscriptions() {
        observeSettings()
        observeActions()
        observeIsChat()
    }

    private func observeSettings() {
        withObservationTracking {
            _ = viewModel.settings
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.rebuildMenu()
                self?.observeSettings()
            }
        }
    }

    private func observeIsChat() {
        withObservationTracking {
            _ = viewModel.isChat
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.rebuildMenu()
                self?.observeIsChat()
            }
        }
    }

    private func observeActions() {
        withObservationTracking {
            _ = viewModel.objectActions
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.rebuildMenu()
                self?.observeActions()
            }
        }
    }

    private func rebuildMenu() {
        menuConfig = ObjectMenuBuilder.buildMenu(
            settings: viewModel.settings,
            actions: viewModel.objectActions,
            isChat: viewModel.isChat
        )
    }

    func isDestructiveAction(_ action: ObjectAction) -> Bool {
        switch action {
        case .delete, .archive:
            return true
        default:
            return false
        }
    }

    func handleSetting(_ setting: ObjectSetting) async {
        switch setting {
        case .icon:
            viewModel.onTapIconPicker()
        case .cover:
            viewModel.onTapCoverPicker()
        case .description:
            try? await viewModel.onTapDescription()
        case .relations:
            viewModel.onTapRelations()
        case .history:
            viewModel.onTapHistory()
        case .resolveConflict:
            viewModel.onTapResolveConflict()
        case .webPublishing:
            viewModel.onTapPublishing()
        case .prefillName:
            try? await viewModel.onTapPrefillName()
        case .notifications:
            break // Handled by submenu
        }
    }

    func handleNotificationModeChange(_ mode: SpacePushNotificationsMode) async {
        try? await viewModel.changeNotificationMode(mode)
    }

    func handleAction(_ action: ObjectAction) async {
        switch action {
        case .archive(let isArchived):
            if viewModel.isChat && !isArchived {
                viewModel.showDeleteChatConfirmation = true
            } else {
                try? await viewModel.changeArchiveState()
            }
        case let .pin(pinned):
            try? await viewModel.changePinState(pinned)
        case .locked:
            try? await viewModel.changeLockState()
        case .undoRedo:
            viewModel.undoRedoAction()
        case .duplicate:
            try? await viewModel.duplicateAction()
        case .linkItself:
            viewModel.linkItselfAction()
        case .makeAsTemplate:
            try? await viewModel.makeAsTemplate()
        case .templateToggleDefaultState:
            try? await viewModel.templateToggleDefaultState()
        case .delete:
            try? await viewModel.deleteAction()
        case .copyLink:
            try? await viewModel.copyLinkAction()
        case .inviteMembers:
            viewModel.inviteMembersAction()
        case .editInfo:
            viewModel.editInfoAction()
        }
    }
}
