import Foundation
import Services
import AnytypeCore

@MainActor
final class MyFavoritesRowContextMenuViewModel {

    let objectId: String
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol

    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var provider: any WidgetActionsViewCommonMenuProviderProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    init(
        objectId: String,
        spaceId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
    }

    func onFavoriteTap() {
        provider.onFavoriteTap(
            targetObjectId: objectId,
            personalWidgetsObject: personalWidgetsObject
        )
    }

    func onChannelPinTap() {
        provider.onChannelPinTap(
            targetObjectId: objectId,
            channelWidgetsObject: channelWidgetsObject
        )
    }

    func canManageChannelPins() -> Bool {
        participantSpacesStorage
            .participantSpaceView(spaceId: spaceId)?
            .canManageChannelPins ?? false
    }

    func isPinnedToChannel() -> Bool {
        for block in channelWidgetsObject.children where block.isWidget {
            guard let info = channelWidgetsObject.widgetInfo(block: block),
                  case let .object(details) = info.source else { continue }
            if details.id == objectId { return true }
        }
        return false
    }
}
