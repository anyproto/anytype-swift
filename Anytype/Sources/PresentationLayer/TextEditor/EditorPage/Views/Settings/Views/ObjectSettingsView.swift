import SwiftUI
import BlocksModels

struct ObjectSettingsView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
    
    @State private var isRelationsViewPresented = false
    
    var body: some View {
        settings
            .background(Color.backgroundSecondary)
        
            .sheet(
                isPresented: $isRelationsViewPresented
            ) {
                RelationsListView(viewModel: viewModel.relationsViewModel)
            }
    }
    
    private var settings: some View {
        VStack(spacing: 0) {
            settingsList

            ObjectActionsView(viewModel: viewModel.objectActionsViewModel)
                .padding(.horizontal, Constants.edgeInset)
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
                viewModel.showIconPicker()
            case .cover:
                viewModel.showCoverPicker()
            case .layout:
                viewModel.showLayoutSettings()
            case .relations:
                if isRelationsViewPresented == false {
                    AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.objectRelationShow)
                    isRelationsViewPresented = true
                }
            }
        }
    }

    private enum Constants {
        static let edgeInset: CGFloat = 16
        static let dividerSpacing: CGFloat = 12
    }
}
