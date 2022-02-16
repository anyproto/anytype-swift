import SwiftUI
import Amplitude
import BlocksModels

struct ObjectSettingsView: View {
    
    @EnvironmentObject var viewModel: ObjectSettingsViewModel
    
    @Binding var isCoverPickerPresented: Bool
    @Binding var isIconPickerPresented: Bool
    @Binding var isLayoutPickerPresented: Bool
    @Binding var isRelationsViewPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator(bottomPadding: 0)
            settings
        }
        .background(Color.backgroundSecondary)
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
                isIconPickerPresented = true
            case .cover:
                isCoverPickerPresented = true
            case .layout:
                withAnimation() {
                    isLayoutPickerPresented = true
                }
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

struct ObjectSettingsView_Previews: PreviewProvider {
    @State static private var isIconPickerPresented = false
    @State static private var isCoverPickerPresented = false
    @State static private var isLayoutPickerPresented = false
    @State static private var isRelationsViewPresented = false
    
    static var previews: some View {
        ObjectSettingsView(
            isCoverPickerPresented: $isCoverPickerPresented,
            isIconPickerPresented: $isIconPickerPresented,
            isLayoutPickerPresented: $isLayoutPickerPresented,
            isRelationsViewPresented: $isRelationsViewPresented
        )
            .environmentObject(
                ObjectSettingsViewModel(
                    objectId: "dummyPageId",
                    objectDetailsService: DetailsService(objectId: ""),
                    popScreenAction: {},
                    onRelationValueEditingTap: { _ in }
                )
            )
    }
}
