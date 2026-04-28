import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesRowContextMenuViewModel {

    @ObservationIgnored
    let objectId: String
    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    let channelWidgetsObject: any BaseDocumentProtocol
    @ObservationIgnored
    let personalWidgetsObject: any BaseDocumentProtocol

    @ObservationIgnored
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var provider: any WidgetActionsViewCommonMenuProviderProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    private(set) var isPinnedToChannel: Bool

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
        self.isPinnedToChannel = channelWidgetsObject.containsWidgetFor(objectId: objectId)
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

    func startChannelSubscription() async {
        for await _ in channelWidgetsObject.syncPublisher.values {
            let next = channelWidgetsObject.containsWidgetFor(objectId: objectId)
            guard isPinnedToChannel != next else { continue }
            isPinnedToChannel = next
        }
    }
}
