import Foundation
import SwiftUI
import Services
import Combine
import AnytypeCore

@MainActor
@Observable
final class ChatHeaderViewModel {

    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored @Injected(\.syncStatusStorage)
    private var syncStatusStorage: any SyncStatusStorageProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    var title: String?
    var icon: Icon?
    var chatLoading = false
    var spaceLoading = false
    var muted = false
    var showAddMembersButton: Bool = false
    private(set) var isMultiChatSpace: Bool = false

    var showLoading: Bool { chatLoading || spaceLoading }

    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    let chatId: String

    @ObservationIgnored
    private let onTapOpenWidgets: () -> Void
    @ObservationIgnored
    private let onTapOpenSpaceSettings: () -> Void
    @ObservationIgnored
    private let onTapAddMembers: (() -> Void)
    @ObservationIgnored
    private let chatObject: any BaseDocumentProtocol

    @ObservationIgnored
    private var spaceSupportsMultiChats: Bool = false
    @ObservationIgnored
    private var spaceTitle: String?
    @ObservationIgnored
    private var spaceIcon: Icon?
    @ObservationIgnored
    private var chatDetails: ObjectDetails?

    init(
        spaceId: String,
        chatId: String,
        onTapOpenWidgets: @escaping () -> Void,
        onTapOpenSpaceSettings: @escaping () -> Void,
        onTapAddMembers: @escaping (() -> Void)
    ) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.onTapOpenWidgets = onTapOpenWidgets
        self.onTapOpenSpaceSettings = onTapOpenSpaceSettings
        self.onTapAddMembers = onTapAddMembers
        self.chatObject = openDocumentProvider.document(objectId: chatId, spaceId: spaceId)
    }
    
    func startSubscriptions() async {
        async let spaceViewSub: () = subscribeOnSpaceView()
        async let chatDetailsSub: () = subscribeOnChatDetails()
        async let chatSub: () = subscribeOnChatStatus()
        async let spaceStatusSub: () = subscribeOnSpaceStatus()

        _ = await (spaceViewSub, chatDetailsSub, chatSub, spaceStatusSub)
    }
    
    func tapOpenWidgets() { onTapOpenWidgets() }

    func tapOpenSpaceSettings() { onTapOpenSpaceSettings() }

    func tapAddMembers() { onTapAddMembers() }
    
    // MARK: - Private
    
    private func subscribeOnSpaceView() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let spaceView = participantSpaceView.spaceView
            spaceSupportsMultiChats = spaceView.uxType.supportsMultiChats
            isMultiChatSpace = spaceSupportsMultiChats
            spaceTitle = spaceView.title
            spaceIcon = spaceView.objectIconImage
            muted = !spaceView.effectiveNotificationMode(for: chatId).isUnmutedAll
            showAddMembersButton = participantSpaceView.participant?.permission == .owner
            updateHeaderDisplay()
        }
    }

    private func subscribeOnChatDetails() async {
        for await details in chatObject.detailsPublisher.values {
            chatDetails = details
            updateHeaderDisplay()
        }
    }

    private func subscribeOnChatStatus() async {
        let loadingPublisher = chatObject.detailsPublisher
            .map {
                switch $0.syncStatusValue {
                case .synced, .error, .UNRECOGNIZED, .none:
                    return false
                case .syncing, .queued:
                    return true
                }
            }
            .removeDuplicates()
        
        // Add delay for show loading indicator.
        // Don't show, if loading state less a one seconds.
        let stream = loadingPublisher
            .flatMap { value in
                if !value {
                    return Just(false)
                        .eraseToAnyPublisher()
                } else {
                    return Just(true)
                        .delay(for: .seconds(2), scheduler: RunLoop.main)
                        .prefix(untilOutputFrom: loadingPublisher.filter { $0 == false })
                        .eraseToAnyPublisher()
                }
            }
            .values
            .removeDuplicates()
        
        for await loading in stream {
            chatLoading = loading
        }
    }
    
    private func subscribeOnSpaceStatus() async {
        for await spaceStatus in syncStatusStorage.statusPublisher(spaceId: spaceId).values {
            spaceLoading = spaceStatus.status == .error
        }
    }

    private func updateHeaderDisplay() {
        if spaceSupportsMultiChats {
            if let chatDetails {
                title = chatDetails.name.withPlaceholder
                icon = chatDetails.objectIconImage
            } else {
                title = nil
                icon = nil
            }
        } else {
            title = spaceTitle
            icon = spaceIcon
        }
    }
}
