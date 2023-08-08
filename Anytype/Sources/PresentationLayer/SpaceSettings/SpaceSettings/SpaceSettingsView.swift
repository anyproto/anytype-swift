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
                    
                    SettingsInfoBlock(
                        title: "Space ID",
                        subtitle: "bafyreiffhfg6rxuerttu2uhlvd6hlvhh4w3cd3iu6d7pge6eypwhw6mlsa") {
                        print("on tap")
                    }
                    
                    SettingsInfoBlock(
                        title: "Created by",
                        subtitle: "Anton Barulenkov"
                    )
                    
                    SettingsInfoBlock(
                        title: "Creation date",
                        subtitle: "15/12/2023"
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

