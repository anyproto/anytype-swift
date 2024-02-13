import Foundation
import SwiftUI
import AnytypeCore

struct SpaceSettingsView: View {
    
    @StateObject var model: SpaceSettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.title)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    
                    if FeatureFlags.multiplayer {
                        SectionHeaderView(title: Loc.SpaceSettings.sharing)
                        SettingsSectionItemView(
                            name: Loc.SpaceSettings.share,
                            onTap: { model.onShareTap() }
                        )

                    } else {
                        SectionHeaderView(title: Loc.type)
                        
                        SpaceTypeView(name: model.spaceType)
                    }
                    
                    SectionHeaderView(title: Loc.settings)
                    
                    SettingsSectionItemView(
                        name: Loc.SpaceSettings.remoteStorage,
                        imageAsset: .Settings.fileStorage,
                        onTap: { model.onStorageTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.personalization,
                        imageAsset: .Settings.personalization,
                        onTap: { model.onPersonalizationTap() }
                    )
                    
                    SectionHeaderView(title: Loc.SpaceSettings.info)
                    
                    ForEach(0..<model.info.count, id:\.self) { index in
                        SettingsInfoBlockView(model: model.info[index])
                    }
                    
                    if FeatureFlags.multiplayer {
                        SpaceShareMVPView()
                    }
                    
                    if model.allowDelete {
                        StandardButton(Loc.SpaceSettings.deleteButton, style: .warningLarge) {
                            model.onDeleteTap()
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .snackbar(toastBarData: $model.snackBarData)
        .onAppear {
            model.onAppear()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .anytypeSheet(isPresented: $model.showSpaceDeleteAlert) {
            FloaterAlertView.deleteSpaceAlert(spaceName: model.spaceName) {
                model.onDeleteConfirmationTap()
            }
        }
    }
}

