import Services
import UIKit

protocol SpaceSettingsInfoBuilderProtocol {
    func build(
        workspaceInfo: AccountInfo,
        details: SpaceView,
        owner: Participant?,
        onCopyToClipboard: @escaping (String) -> Void
    ) -> [SettingsInfoModel]
}

final class SpaceSettingsInfoBuilder: SpaceSettingsInfoBuilderProtocol {
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    private let dateFormatter = DateFormatter.relativeDateFormatter
    
    func build(
        workspaceInfo: AccountInfo,
        details: SpaceView,
        owner: Participant?,
        onCopyToClipboard: @escaping (String) -> Void
    ) -> [SettingsInfoModel] {
        var info = [SettingsInfoModel]()
        
        if let spaceRelationDetails = try? propertyDetailsStorage.relationsDetails(bundledKey: .spaceId, spaceId: workspaceInfo.accountSpaceId) {
            info.append(
                SettingsInfoModel(title: spaceRelationDetails.name, subtitle: details.targetSpaceId, onTap: {
                    UIPasteboard.general.string = details.targetSpaceId
                    onCopyToClipboard(spaceRelationDetails.name)
                })
            )
        }
        
        if let creatorDetails = try? propertyDetailsStorage.relationsDetails(bundledKey: .creator, spaceId: workspaceInfo.accountSpaceId) {
            
            if let owner {
                let displayName = owner.globalName.isNotEmpty ? owner.globalName : owner.identity
                
                info.append(
                    SettingsInfoModel(title: creatorDetails.name, subtitle: displayName, onTap: {
                        UIPasteboard.general.string = displayName
                        onCopyToClipboard(creatorDetails.name)
                    })
                )
            }
        }
        
        info.append(
            SettingsInfoModel(title: Loc.SpaceSettings.networkId, subtitle: workspaceInfo.networkId, onTap: {
                UIPasteboard.general.string = workspaceInfo.networkId
                onCopyToClipboard(Loc.SpaceSettings.networkId)
            })
        )
        
        if let createdDateDetails = try? propertyDetailsStorage.relationsDetails(bundledKey: .createdDate, spaceId: workspaceInfo.accountSpaceId),
           let date = details.createdDate.map({ dateFormatter.string(from: $0) }) {
            info.append(
                SettingsInfoModel(title: createdDateDetails.name, subtitle: date)
            )
        }
        
        return info
    }
}
