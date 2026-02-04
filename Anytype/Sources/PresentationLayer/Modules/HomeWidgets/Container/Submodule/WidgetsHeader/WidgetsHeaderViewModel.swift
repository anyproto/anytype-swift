import Foundation
import Services

@MainActor
@Observable
final class WidgetsHeaderViewModel {

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private let onSpaceSelected: () -> Void

    @ObservationIgnored
    private let accountSpaceId: String

    // MARK: - State

    var canEdit = false

    init(spaceId: String, onSpaceSelected: @escaping () -> Void) {
        self.accountSpaceId = spaceId
        self.onSpaceSelected = onSpaceSelected
    }

    func startSubscriptions() async {
        await startParticipantSpaceViewTask()
    }

    private func startParticipantSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: accountSpaceId).values {
            canEdit = participantSpaceView.canEdit
        }
    }

    func onTapSpaceSettings() {
        onSpaceSelected()
    }
}
