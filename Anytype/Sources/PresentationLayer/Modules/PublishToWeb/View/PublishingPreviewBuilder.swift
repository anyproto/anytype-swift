import Foundation
import Services
import AnytypeCore

protocol PublishingPreviewBuilderProtocol {
    func buildPreviewData(
        from details: ObjectDetails,
        spaceName: String,
        showJoinButton: Bool
    ) -> PublishingPreviewData
    
    func buildPreviewData(
        from existing: PublishingPreviewData,
        showJoinButton: Bool
    ) -> PublishingPreviewData
}

struct PublishingPreviewData {
    let spaceName: String
    let title: String
    let cover: DocumentCover?
    let icon: ObjectIcon?
    let showJoinButton: Bool
    
    static var empty: PublishingPreviewData {
        PublishingPreviewData(
            spaceName: "",
            title: "",
            cover: nil,
            icon: nil,
            showJoinButton: false
        )
    }
}

struct PublishingPreviewBuilder: PublishingPreviewBuilderProtocol {
    
    func buildPreviewData(
        from details: ObjectDetails,
        spaceName: String,
        showJoinButton: Bool
    ) -> PublishingPreviewData {
        
        let title = details.title
        let icon = details.objectIcon
        
        return PublishingPreviewData(
            spaceName: spaceName,
            title: title.isEmpty ? Loc.untitled : title,
            cover: details.documentCover,
            icon: icon,
            showJoinButton: showJoinButton
        )
    }
    
    func buildPreviewData(
        from existing: PublishingPreviewData,
        showJoinButton: Bool
    ) -> PublishingPreviewData {
        return PublishingPreviewData(
            spaceName: existing.spaceName,
            title: existing.title,
            cover: existing.cover,
            icon: existing.icon,
            showJoinButton: showJoinButton
        )
    }
}

extension Container {
    var publishingPreviewBuilder: Factory<any PublishingPreviewBuilderProtocol> {
        self { PublishingPreviewBuilder() }.shared
    }
}
