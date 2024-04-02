import Foundation
import SwiftUI
import AnytypeCore

struct SpaceSettingsView: View {
    
    @StateObject private var model: SpaceSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(output: SpaceSettingsModuleOutput?) {
        _model = StateObject(wrappedValue: SpaceSettingsViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.title)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    .disabled(!model.allowEditSpace)
                    
                    spaceSection
                    
                    SectionHeaderView(title: Loc.settings)
                    
                    if model.allowRemoteStorage {
                        SettingsSectionItemView(
                            name: Loc.SpaceSettings.remoteStorage,
                            imageAsset: .Settings.fileStorage,
                            onTap: { model.onStorageTap() }
                        )
                    }
                    
                    SettingsSectionItemView(
                        name: Loc.personalization,
                        imageAsset: .Settings.personalization,
                        onTap: { model.onPersonalizationTap() }
                    )
                    
                    SectionHeaderView(title: Loc.SpaceSettings.info)
                    
                    ForEach(0..<model.info.count, id:\.self) { index in
                        SettingsInfoBlockView(model: model.info[index])
                    }
                    
                    VStack(spacing: 10) {
                        if model.allowDelete {
                            StandardButton(Loc.SpaceSettings.deleteButton, style: .warningLarge) {
                                model.onDeleteTap()
                            }
                        }
                        if model.allowLeave {
                            StandardButton(Loc.SpaceSettings.leaveButton, style: .warningLarge) {
                                model.onLeaveTap()
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 20)
        }
        .snackbar(toastBarData: $model.snackBarData)
        .onAppear {
            model.onAppear()
        }
        .task {
            await model.startJoiningTask()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .anytypeSheet(isPresented: $model.showSpaceDeleteAlert) {
            SpaceDeleteAlert(spaceId: model.workspaceInfo.accountSpaceId)
        }
        .anytypeSheet(isPresented: $model.showSpaceLeaveAlert) {
            SpaceLeaveAlert(spaceId: model.workspaceInfo.accountSpaceId)
        }
    }
    
    @ViewBuilder
    private var spaceSection: some View {
        SectionHeaderView(title: Loc.Settings.spaceType)
        
        if FeatureFlags.multiplayer {
            if model.allowShare {
                SettingsSectionItemView(
                    name: model.spaceAccessType,
                    decoration: .arrow(text: model.sharedSpaceDescription),
                    onTap: { model.onShareTap() }
                )
            } else if model.allowSpaceMembers {
                SettingsSectionItemView(
                    name: model.spaceAccessType,
                    decoration: .arrow(text: Loc.SpaceShare.members),
                    onTap: { model.onMembersTap() }
                )
            } else {
                SettingsSectionItemView(name: model.spaceAccessType, decoration: nil, onTap: {})
            }
        } else {
            SpaceTypeView(name: model.spaceAccessType)
        }
    }
}

