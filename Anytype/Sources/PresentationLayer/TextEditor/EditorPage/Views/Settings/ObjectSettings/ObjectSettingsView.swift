import SwiftUI
import Services
import AnytypeCore

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
            
            VStack(spacing: 0) {
                layoutSection
                objectSection
            }

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
    
    private var layoutSection: some View {
        let layoutSettings = viewModel.settings.filter { $0.section == .layout }
        
        return VStack(spacing: 0) {
            if !layoutSettings.isEmpty {
                SectionHeaderView(title: Loc.layout)
                    .padding(.horizontal, Constants.edgeInset)
                
                VStack(spacing: 0) {
                    ForEach(Array(layoutSettings.enumerated()), id: \.offset) { index, setting in
                        settingRow(setting, showDivider: index != layoutSettings.count - 1)
                    }
                }
                .padding(.horizontal, Constants.edgeInset)
            }
        }
    }
    
    private var objectSection: some View {
        let objectSettings = viewModel.settings.filter { $0.section == .object }
        
        return VStack(spacing: 0) {
            if !objectSettings.isEmpty {
                SectionHeaderView(title: Loc.objects)
                    .padding(.horizontal, Constants.edgeInset)
                
                VStack(spacing: 0) {
                    ForEach(Array(objectSettings.enumerated()), id: \.offset) { index, setting in
                        settingRow(setting, showDivider: index != objectSettings.count - 1)
                    }
                }
                .padding(.horizontal, Constants.edgeInset)
                .divider(spacing: Constants.dividerSpacing)
            }
        }
    }
    
    private func settingRow(_ setting: ObjectSetting, showDivider: Bool) -> some View {
        ObjectSettingRow(setting: setting, showDivider: showDivider) {
            try await handleSetting(setting)
        }
    }
    
    private func handleSetting(_ setting: ObjectSetting) async throws {
        switch setting {
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
        case .webPublishing:
            viewModel.onTapPublishing()
        }
    }
    

    private enum Constants {
        static let edgeInset: CGFloat = 16
        static let dividerSpacing: CGFloat = 12
    }
}
