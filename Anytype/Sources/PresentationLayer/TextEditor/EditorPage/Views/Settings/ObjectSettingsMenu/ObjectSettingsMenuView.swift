import SwiftUI
import AnytypeCore
import Services

struct ObjectSettingsMenuView<LabelView: View>: View {

    @State private var viewModel: ObjectSettingsMenuViewModel
    private let labelView: LabelView

    init(
        objectId: String,
        spaceId: String,
        output: some ObjectSettingsModelOutput,
        @ViewBuilder labelView: () -> LabelView
    ) {
        let vm = ObjectSettingsViewModel(objectId: objectId, spaceId: spaceId, output: output)
        self._viewModel = State(wrappedValue: ObjectSettingsMenuViewModel(viewModel: vm))
        self.labelView = labelView()
    }

    var body: some View {
        Menu {
            ForEach(viewModel.menuConfig.sections) { section in
                if section.showDividerBefore {
                    Divider()
                }
                renderSection(section)
            }
        } label: {
            labelView
        }
        .task {
            await viewModel.startTasks()
        }
        .anytypeSheet(isPresented: viewModel.showConflictAlert) {
            ObjectSettingsResolveConflictAlert {
                try await viewModel.onTapResolveConflictApprove()
            }
        }
        .anytypeSheet(isPresented: viewModel.showDeleteChatConfirmation) {
            ChatDeleteChatAlert {
                try await viewModel.viewModel.changeArchiveState()
            }
        }
        .snackbar(toastBarData: viewModel.toastData)
    }

    @ViewBuilder
    private func renderSection(_ section: ObjectMenuSection) -> some View {
        switch section.layout {
        case .horizontal:
            ControlGroup {
                ForEach(section.items) { item in
                    renderMenuItem(item)
                }
            }
            .controlGroupStyle(.menu)
        case .collapsible:
            Menu {
                ForEach(section.items) { item in
                    renderMenuItem(item)
                }
            } label: {
                Label {
                    Text(Loc.more)
                } icon: {
                    Image(asset: .X24.more)
                        .renderingMode(.template)
                        .foregroundStyle(Color.Text.primary)
                }
            }
        case .vertical:
            ForEach(section.items) { item in
                renderMenuItem(item)
            }
        }
    }

    @ViewBuilder
    private func renderMenuItem(_ item: ObjectMenuItem) -> some View {
        switch item {
        case .setting(let setting):
            settingMenuItem(setting)
        case .action(let action):
            Button(role: viewModel.isDestructiveAction(action) ? .destructive : nil) {
                Task {
                    await viewModel.handleAction(action)
                }
            } label: {
                Label {
                    Text(action.title)
                } icon: {
                    if viewModel.isDestructiveAction(action) {
                        menuIconImage(action.menuIcon)
                    } else {
                        menuIconImage(action.menuIcon)
                            .foregroundStyle(Color.Text.primary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func settingMenuItem(_ setting: ObjectSetting) -> some View {
        switch setting {
        case .notifications(let mode):
            notificationsMenuItem(mode: mode)
        default:
            defaultSettingMenuItem(setting)
        }
    }

    private func notificationsMenuItem(mode: SpacePushNotificationsMode) -> some View {
        NotificationModeMenu(
            currentMode: mode,
            onModeChange: viewModel.handleNotificationModeChange
        )
    }

    private func defaultSettingMenuItem(_ setting: ObjectSetting) -> some View {
        Button {
            Task {
                await viewModel.handleSetting(setting)
            }
        } label: {
            Label {
                Text(setting.title)
            } icon: {
                menuIconImage(setting.menuIcon)
                    .foregroundStyle(Color.Text.primary)
            }
        }
    }

    @ViewBuilder
    private func menuIconImage(_ icon: MenuIcon) -> some View {
        switch icon {
        case .asset(let asset):
            Image(asset: asset).renderingMode(.template)
        case .system(let name):
            Image(systemName: name)
        }
    }

}
