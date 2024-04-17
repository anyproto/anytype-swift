import SwiftUI
import Services

struct ObjectSettingsView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
    
    var body: some View {
        settings
            .background(Color.Background.secondary)
    }
    
    private var settings: some View {
        VStack(spacing: 0) {
            settingsList

            ObjectActionsView(objectId: viewModel.objectId, output: viewModel)
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
        ObjectSettingRow(setting: viewModel.settings[index], isLast: index == viewModel.settings.count - 1) {
            switch viewModel.settings[index] {
            case .icon:
                viewModel.onTapIconPicker()
            case .cover:
                viewModel.onTapCoverPicker()
            case .layout:
                viewModel.onTapLayoutPicker()
            case .relations:
                viewModel.onTapRelations()
            }
        }
    }

    private enum Constants {
        static let edgeInset: CGFloat = 16
        static let dividerSpacing: CGFloat = 12
    }
}
