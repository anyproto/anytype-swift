import Foundation
import SwiftUI
import Services
import Combine
import AnytypeCore

@MainActor
final class ChatHeaderViewModel: ObservableObject {
    
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: any SyncStatusStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    @Published var title: String?
    @Published var icon: Icon?
    @Published var showWidgetsButton: Bool = false
    @Published var chatLoading = false
    @Published var spaceLoading = false
    @Published var muted = false
    @Published var showAddMembersButton: Bool = false

    var showLoading: Bool { chatLoading || spaceLoading }

    private let spaceId: String
    private let chatId: String
    private let onTapOpenWidgets: () -> Void
    private let onTapAddMembers: (() -> Void)
    private let chatObject: any BaseDocumentProtocol

    private var spaceSupportsMultiChats: Bool = false
    private var spaceTitle: String?
    private var spaceIcon: Icon?
    private var chatDetails: ObjectDetails?

    init(
        spaceId: String,
        chatId: String,
        onTapOpenWidgets: @escaping () -> Void,
        onTapAddMembers: @escaping (() -> Void)
    ) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.onTapOpenWidgets = onTapOpenWidgets
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

    func tapAddMembers() { onTapAddMembers() }
    
    // MARK: - Private
    
    private func subscribeOnSpaceView() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let spaceView = participantSpaceView.spaceView
            spaceSupportsMultiChats = spaceView.uxType.supportsMultiChats
            spaceTitle = spaceView.title
            spaceIcon = spaceView.objectIconImage
            showWidgetsButton = spaceView.chatId == chatId && spaceView.initialScreenIsChat
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
