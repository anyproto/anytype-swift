import SwiftUI
import Amplitude
import BlocksModels

struct ObjectSettingsView: View {
    
    let viewModel: ObjectSettingsViewModel
    
    @State private var isIconPickerPresented = false
    @State private var isCoverPickerPresented = false
    @State private var isLayoutPickerPresented = false
    @State private var isRelationsViewPresented = false
    
    var body: some View {
        mainView
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
            .popup(
                isPresented: $isLayoutPickerPresented,
                type: .floater(verticalPadding: 0),
                closeOnTap: false,
                closeOnTapOutside: true,
                backgroundOverlayColor: Color.black.opacity(0.25),
                view: {
                    ObjectLayoutPicker()
                        .horizontalReadabilityPadding()
                        .environmentObject(viewModel.layoutPickerViewModel)
                }
            )
    }
    
    private var mainView: some View {
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
            viewModel: ObjectSettingsViewModel(
                objectId: "dummyPageId",
                objectDetailsService: DetailsService(objectId: ""),
                popScreenAction: {},
                onRelationValueEditingTap: { _ in }
            )
        )
    }
}
