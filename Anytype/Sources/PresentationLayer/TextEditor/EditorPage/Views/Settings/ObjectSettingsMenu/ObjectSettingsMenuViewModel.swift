import Foundation
import SwiftUI

@MainActor
@Observable
final class ObjectSettingsMenuViewModel {

    var menuConfig = ObjectMenuConfiguration(sections: [])

    @ObservationIgnored
    let settingsViewModel: ObjectSettingsViewModel
    @ObservationIgnored
    let actionsViewModel: ObjectActionsViewModel

    var showConflictAlert: Binding<Bool> {
        Binding(
            get: { self.settingsViewModel.showConflictAlert },
            set: { self.settingsViewModel.showConflictAlert = $0 }
        )
    }

    var toastData: Binding<ToastBarData?> {
        Binding(
            get: { self.actionsViewModel.toastData },
            set: { self.actionsViewModel.toastData = $0 }
        )
    }

    init(settingsViewModel: ObjectSettingsViewModel, actionsViewModel: ObjectActionsViewModel) {
        self.settingsViewModel = settingsViewModel
        self.actionsViewModel = actionsViewModel
        setupSubscriptions()
    }

    func startTasks() async {
        async let settingsTask: () = settingsViewModel.startDocumentTask()
        async let actionsTask: () = actionsViewModel.startSubscriptions()
        _ = await (settingsTask, actionsTask)
    }

    func onTapResolveConflictApprove() async throws {
        try await settingsViewModel.onTapResolveConflictApprove()
    }

    private func setupSubscriptions() {
        observeSettings()
        observeActions()
    }

    private func observeSettings() {
        withObservationTracking {
            _ = settingsViewModel.settings
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.rebuildMenu()
                self?.observeSettings()
            }
        }
    }

    private func observeActions() {
        withObservationTracking {
            _ = actionsViewModel.objectActions
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.rebuildMenu()
                self?.observeActions()
            }
        }
    }

    private func rebuildMenu() {
        menuConfig = ObjectMenuBuilder.buildMenu(
            settings: settingsViewModel.settings,
            actions: actionsViewModel.objectActions
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
            settingsViewModel.onTapIconPicker()
        case .cover:
            settingsViewModel.onTapCoverPicker()
        case .description:
            try? await settingsViewModel.onTapDescription()
        case .relations:
            settingsViewModel.onTapRelations()
        case .history:
            settingsViewModel.onTapHistory()
        case .resolveConflict:
            settingsViewModel.onTapResolveConflict()
        case .webPublishing:
            settingsViewModel.onTapPublishing()
        }
    }

    func handleAction(_ action: ObjectAction) async {
        switch action {
        case .archive:
            try? await actionsViewModel.changeArchiveState()
        case let .pin(pinned):
            try? await actionsViewModel.changePinState(pinned)
        case .locked:
            try? await actionsViewModel.changeLockState()
        case .undoRedo:
            actionsViewModel.undoRedoAction()
        case .duplicate:
            try? await actionsViewModel.duplicateAction()
        case .linkItself:
            actionsViewModel.linkItselfAction()
        case .makeAsTemplate:
            try? await actionsViewModel.makeAsTemplate()
        case .templateToggleDefaultState:
            try? await actionsViewModel.templateToggleDefaultState()
        case .delete:
            try? await actionsViewModel.deleteAction()
        case .copyLink:
            try? await actionsViewModel.copyLinkAction()
        }
    }
}
