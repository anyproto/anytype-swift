import SwiftUI
import Amplitude
import BlocksModels

struct ObjectSettingsView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
    
    @State private var isIconPickerPresented = false
    @State private var isCoverPickerPresented = false
    @State private var isRelationsViewPresented = false
    
    var body: some View {
        settings
            .background(Color.backgroundSecondary)
            .sheet(
                isPresented: $isCoverPickerPresented
            ) {
                ObjectCoverPicker(viewModel: viewModel.coverPickerViewModel)
            }
            .sheet(
                isPresented: $isIconPickerPresented
            ) {
                ObjectIconPicker(viewModel: viewModel.iconPickerViewModel)
            }
            .sheet(
                isPresented: $isRelationsViewPresented
            ) {
                RelationsListView(viewModel: viewModel.relationsViewModel)
                    .onChange(of: isRelationsViewPresented) { isRelationsViewPresented in
                        if isRelationsViewPresented {
                            Amplitude.instance().logEvent(AmplitudeEventsName.objectRelationShow)
                        }
                    }
            }
    }
    
    private var settings: some View {
        VStack(spacing: 0) {
            settingsList

            ObjectActionsView(viewModel: viewModel.objectActionsViewModel)
                .padding(.horizontal, Constants.edgeInset)
        }
        .readSize { size in
            viewModel.viewDidUpdateHeight(size.height)
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
                isIconPickerPresented = true
            case .cover:
                isCoverPickerPresented = true
            case .layout:
                viewModel.showLayoutSettings()
            case .relations:
                isRelationsViewPresented = true
            }
        }
    }

    private enum Constants {
        static let edgeInset: CGFloat = 16
        static let dividerSpacing: CGFloat = 12
    }
}
