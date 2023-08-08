import Foundation
import SwiftUI

struct SpaceSettingsView: View {
    
    @StateObject var model: SpaceSettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.title)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    
                    SectionHeaderView(title: Loc.type)
                    
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
                        SettingsInfoBlock(model: model.info[index])
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .snackbar(toastBarData: $model.snackBarData)
    }
}

