import SwiftUI
import Services

struct ObjectSettingsView: View {
    
    @StateObject private var viewModel: ObjectSettingsViewModel
    
    init(
        objectId: String,
        spaceId: String,
        output: some ObjectSettingsModelOutput
    ) {
        self._viewModel = StateObject(wrappedValue: ObjectSettingsViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        settings
            .background(Color.Background.secondary)
            .anytypeSheet(isPresented: $viewModel.showConflictAlert) {
                ObjectSettingsResolveConflictAlert {
                    try await viewModel.onTapResolveConflictApprove()
                }
            }
    }
    
    private var settings: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            settingsList

            ObjectActionsView(
                objectId: viewModel.objectId,
                spaceId: viewModel.spaceId,
                output: viewModel
            )
        }
        .task {
            await viewModel.startDocumentTask()
        }
    }
    
    private var settingsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.settings.indices, id: \.self) { index in
                mainSetting(index: index)
            }
        }
        .padding(.horizontal, Constants.edgeInset)
        .divider(spacing: Constants.dividerSpacing)
    }
    
    private func mainSetting(index: Int) -> some View {
        ObjectSettingRow(setting: viewModel.settings[index], showDivider: index != viewModel.settings.count - 1) {
            switch viewModel.settings[index] {
            case .icon:
                viewModel.onTapIconPicker()
            case .cover:
                viewModel.onTapCoverPicker()
            case .description:
                try await viewModel.onTapDescription()
            case .relations:
                viewModel.onTapRelations()
            case .history:
                viewModel.onTapHistory()
            case .resolveConflict:
                viewModel.onTapResolveConflict()
            }
        }
    }

    private enum Constants {
        static let edgeInset: CGFloat = 16
        static let dividerSpacing: CGFloat = 12
    }
}
