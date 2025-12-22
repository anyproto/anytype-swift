import SwiftUI
import AnytypeCore

struct ObjectSettingsMenuView<LabelView: View>: View {

    @State private var viewModel: ObjectSettingsMenuViewModel
    private let labelView: LabelView

    init(
        objectId: String,
        spaceId: String,
        output: some ObjectSettingsModelOutput,
        @ViewBuilder labelView: () -> LabelView
    ) {
        let settingsVM = ObjectSettingsViewModel(objectId: objectId, spaceId: spaceId, output: output)
        let actionsVM = ObjectActionsViewModel(objectId: objectId, spaceId: spaceId, output: settingsVM)
        self._viewModel = State(wrappedValue: ObjectSettingsMenuViewModel(settingsViewModel: settingsVM, actionsViewModel: actionsVM))
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
            Button {
                Task {
                    await viewModel.handleSetting(setting)
                }
            } label: {
                Label {
                    Text(setting.title)
                } icon: {
                    Image(asset: setting.imageAsset)
                        .renderingMode(.template)
                        .foregroundStyle(Color.Text.primary)
                }
            }
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
                        Image(asset: action.imageAsset)
                    } else {
                        Image(asset: action.imageAsset)
                            .renderingMode(.template)
                            .foregroundStyle(Color.Text.primary)
                    }
                }
            }
        }
    }

}
