import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesRowViewModel {

    // MARK: - DI

    @ObservationIgnored
    private let objectId: String
    @ObservationIgnored
    private let spaceId: String

    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.widgetChatPreviewBuilder)
    private var chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol

    // MARK: - State

    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []

    private(set) var badgeModel: MessagePreviewModel?

    init(objectId: String, spaceId: String) {
        self.objectId = objectId
        self.spaceId = spaceId
    }

    func startSubscriptions() async {
        await startChatPreviewsSubscription()
    }

    // MARK: - Private

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            updateBadgeModel()
        }
    }

    private func updateBadgeModel() {
        let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId)
        badgeModel = chatPreviews.first(where: { $0.chatId == objectId }).flatMap {
            chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
        }
    }
}
