import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI
import AsyncAlgorithms

@MainActor
@Observable
final class HomeWidgetsViewModel {

    private enum Constants {
        static let pinnedSectionId = "HomePinnedSection"
        static let objectTypeSectionId = "HomeObjectTypeSection"
        static let unreadSectionId = "HomeUnreadSection"
        static let myFavoritesSectionId = "HomeMyFavoritesSection"
    }
    
    // MARK: - DI

    let info: AccountInfo
    let widgetObject: any BaseDocumentProtocol

    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionService: any ObjectActionsServiceProtocol
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let workspaceStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.participantsStorage) @ObservationIgnored
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.homeWidgetsRecentStateManager) @ObservationIgnored
    private var recentStateManager: any HomeWidgetsRecentStateManagerProtocol
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.expandedService) @ObservationIgnored
    private var expandedService: any ExpandedServiceProtocol
    @Injected(\.chatMessagesPreviewsStorage) @ObservationIgnored
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.objectTypesWithObjectsCreatedService) @ObservationIgnored
    private var objectTypesWithObjectsCreatedService: any ObjectTypesWithObjectsCreatedServiceProtocol
    @Injected(\.chatDetailsStorage) @ObservationIgnored
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?
    
    // MARK: - State
    
    var widgetBlocks: [BlockWidgetInfo] = []
    var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    var homeState: HomeWidgetsState = .readonly
    var widgetsDataLoaded: Bool = false
    var objectTypesDataLoaded: Bool = false
    var wallpaper: SpaceWallpaperType = .default
    var pinnedSectionIsExpanded: Bool = false
    var objectTypeSectionIsExpanded: Bool = false
    var canCreateObjectType: Bool = false
    /// Owner-only predicate for the Pin/Unpin-from-channel menu items. Kept as a
    /// single property so a future Admin role (no plan today) widens it in one spot.
    /// Task 13 will plumb this to additional call sites if needed.
    var canManageChannelPins: Bool = false
    var homeWidgetData: HomepageWidgetViewData?
    var unreadSectionIsExpanded: Bool = false
    var unreadChats: [UnreadChatWidgetData] = []
    var myFavoritesSectionIsExpanded: Bool = false
    var myFavoritesViewModel: MyFavoritesViewModel?
    private var supportsMultiChats: Bool = false

    var spaceId: String { info.accountSpaceId }

    var shouldShowUnreadSection: Bool {
        supportsMultiChats && unreadChats.isNotEmpty
    }

    var shouldHideChatBadges: Bool {
        shouldShowUnreadSection && unreadSectionIsExpanded
    }

    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
        let widgetObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.widgetObject = widgetObject
        if FeatureFlags.personalFavorites {
            let personalWidgetsObject = documentService.document(
                objectId: info.personalWidgetsId,
                spaceId: info.accountSpaceId
            )
            self.myFavoritesViewModel = MyFavoritesViewModel(
                accountInfo: info,
                personalWidgetsObject: personalWidgetsObject,
                channelWidgetsObject: widgetObject,
                onObjectSelected: { [weak output] details in
                    output?.onObjectSelected(screenData: details.screenData())
                }
            )
        } else {
            self.myFavoritesViewModel = nil
        }
        self.pinnedSectionIsExpanded = expandedService.isExpanded(id: Constants.pinnedSectionId, defaultValue: true)
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Constants.objectTypeSectionId, defaultValue: true)
        self.unreadSectionIsExpanded = expandedService.isExpanded(id: Constants.unreadSectionId, defaultValue: true)
        self.myFavoritesSectionIsExpanded = expandedService.isExpanded(id: Constants.myFavoritesSectionId, defaultValue: true)
    }

    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let myFavoritesSub: () = startMyFavoritesTask()
        async let participantTask: () = startParticipantTask()
        async let objectTypesTask: () = startObjectTypesTask()
        async let spaceViewTask: () = startSpaceViewTask()
        async let unreadChatsTask: () = startUnreadChatsTask()

        _ = await (widgetObjectSub, myFavoritesSub, participantTask, objectTypesTask, spaceViewTask, unreadChatsTask)
    }

    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget()
    }

    func widgetsDropUpdate(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        widgetBlocks.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func widgetsDropFinish(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        AnytypeAnalytics.instance().logReorderWidget(source: from.data.source.analyticsSource)
        Task {
            try? await objectActionService.move(
                dashboadId: widgetObject.objectId,
                blockId: from.data.id,
                dropPositionblockId: to.data.id,
                position: to.index > from.index ? .bottom : .top
            )
        }
    }
    
    func onSpaceSelected() {
        output?.onSpaceSelected()
    }

    func onMembersSelected(spaceId: String, route: SettingsSpaceShareRoute) {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: route)
    }

    func onQrCodeSelected(url: URL) {
        output?.onSpaceChatShowQrCodeSelected(url: url)
    }

    func onCreateObjectType() {
        output?.onCreateObjectType()
    }
    
    func onTapPinnedHeader() {
        withAnimation {
            pinnedSectionIsExpanded = !pinnedSectionIsExpanded
        }
        expandedService.setState(id: Constants.pinnedSectionId, isExpanded: pinnedSectionIsExpanded)
    }
    
    func onTapObjectTypeHeader() {
        withAnimation {
            objectTypeSectionIsExpanded = !objectTypeSectionIsExpanded
        }
        expandedService.setState(id: Constants.objectTypeSectionId, isExpanded: objectTypeSectionIsExpanded)
    }

    func onTapUnreadHeader() {
        withAnimation {
            unreadSectionIsExpanded = !unreadSectionIsExpanded
        }
        expandedService.setState(id: Constants.unreadSectionId, isExpanded: unreadSectionIsExpanded)
    }

    func onTapMyFavoritesHeader() {
        withAnimation {
            myFavoritesSectionIsExpanded = !myFavoritesSectionIsExpanded
        }
        expandedService.setState(id: Constants.myFavoritesSectionId, isExpanded: myFavoritesSectionIsExpanded)
    }

    // MARK: - Private
    
    private func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            widgetsDataLoaded = true

            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)

            let newWidgetBlocks = blocks
                .compactMap { widgetObject.widgetInfo(block: $0) }

            guard widgetBlocks != newWidgetBlocks else { continue }

            widgetBlocks = newWidgetBlocks
        }
    }

    private func startMyFavoritesTask() async {
        // Drives the `MyFavoritesViewModel.rows` list — only spins up when the feature flag
        // enabled the sub-viewmodel in `init`.
        guard let myFavoritesViewModel else { return }
        await myFavoritesViewModel.startSubscriptions()
    }

    private func startParticipantTask() async {
        async let editSub: () = startCanEditSubscription()
        async let ownerSub: () = startOwnerSubscription()
        _ = await (editSub, ownerSub)
    }

    private func startCanEditSubscription() async {
        for await canEdit in accountParticipantStorage.canEditSequence(spaceId: info.accountSpaceId) {
            homeState = canEdit ? .readwrite : .readonly
            canCreateObjectType = canEdit
        }
    }

    // Drives `canManageChannelPins` off the current participant's role. The
    // predicate lives on `ParticipantSpaceViewData` so all three widget-screen
    // call sites share one definition.
    private func startOwnerSubscription() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: info.accountSpaceId).values {
            let next = participantSpaceView.canManageChannelPins
            guard canManageChannelPins != next else { continue }
            canManageChannelPins = next
        }
    }
    
    private func startObjectTypesTask() async {
        let spaceId = spaceId
        let allowedLayouts: [DetailsLayout]
        if FeatureFlags.createChannelFlow {
            let spaceType = workspaceStorage.spaceView(spaceId: spaceId)?.spaceType
            allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceType: spaceType)
            await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceType: spaceType)
        } else {
            let spaceUxType = workspaceStorage.spaceView(spaceId: spaceId)?.uxType
            allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceUxType: spaceUxType)
            await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceUxType: spaceUxType)
        }

        let typesPublisher = objectTypeProvider.objectTypesPublisher(spaceId: spaceId)
        let objectsCreatedPublisher = objectTypesWithObjectsCreatedService.typeIdsWithObjectsCreatedPublisher

        let stream = typesPublisher.combineLatest(objectsCreatedPublisher)
            .map { (types, typeIdsWithObjectsCreated) in
                types
                    .filter { ($0.recommendedLayout.map { allowedLayouts.contains($0) } ?? false) && !$0.isTemplateType }
                    .filter { typeIdsWithObjectsCreated.contains($0.id) }
                    .map { ObjectTypeWidgetInfo(objectTypeId: $0.id, spaceId: spaceId) }
            }
            .removeDuplicates()
            .values

        for await objectTypes in stream {
            objectTypesDataLoaded = true
            objectTypeWidgets = objectTypes
        }
    }

    private struct ObservedHomepage: Equatable {
        let objectId: String
        let canSetHomepage: Bool
    }

    private func startSpaceViewTask() async {
        var homepageTask: Task<Void, Never>?
        var lastObserved: ObservedHomepage?
        defer { homepageTask?.cancel() }

        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let spaceView = participantSpaceView.spaceView
            supportsMultiChats = !spaceView.isOneToOne

            // Home widget renders whichever object is set as homepage (Chat / Page / Collection).
            // Treat `.empty` as `.widgets` via `displayValue` — empty homepage must never render the widget.
            guard case let .object(objectId) = spaceView.homepage.displayValue else {
                if lastObserved != nil {
                    homepageTask?.cancel()
                    homepageTask = nil
                    homeWidgetData = nil
                    lastObserved = nil
                }
                continue
            }

            // Only rebuild the observer when the observed tuple actually changes. Unrelated
            // SpaceView emissions (rename, member added, etc.) must not cancel the task or
            // clear homeWidgetData — doing so causes flicker/disappearance of the widget.
            let next = ObservedHomepage(objectId: objectId, canSetHomepage: participantSpaceView.canSetHomepage)
            guard lastObserved != next else { continue }

            // Subscribe to the homepage object's details so the widget hides upstream when the
            // object is archived, deleted, or fails to open. When details change (e.g. ownership
            // via canSetHomepage), re-emitting HomepageWidgetViewData propagates to the child.
            homepageTask?.cancel()
            // Clear stale data synchronously so a slow/failed `document.open()` for the new object
            // doesn't leave the previous homepage's widget visible and tappable.
            homeWidgetData = nil
            lastObserved = next
            homepageTask = Task { [weak self] in
                await self?.observeHomepageObject(objectId: next.objectId, canSetHomepage: next.canSetHomepage)
            }
        }
    }

    private func observeHomepageObject(objectId: String, canSetHomepage: Bool) async {
        let document = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        try? await document.open()
        for await _ in document.syncPublisher.values {
            guard !Task.isCancelled else { return }
            let details = document.details
            if let details, !details.isArchivedOrDeleted {
                homeWidgetData = HomepageWidgetViewData(
                    spaceId: spaceId,
                    objectId: objectId,
                    canSetHomepage: canSetHomepage,
                    document: document,
                    output: output,
                    onChangeHome: { [weak self] in
                        self?.output?.onChangeHome()
                    },
                    onHomeTap: { [weak self] screenData in
                        self?.output?.onHomeObjectSelected(screenData: screenData)
                    }
                )
            } else {
                homeWidgetData = nil
            }
        }
    }

    private func startUnreadChatsTask() async {
        let spaceId = spaceId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        guard !(spaceView?.isOneToOne ?? true) else { return }

        let previewsSequence = await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
        let chatsSequence = await chatDetailsStorage.allChatsSequence
        let spaceViewSequence = workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values

        for await (previews, chatDetails, currentSpaceView) in combineLatest(previewsSequence, chatsSequence, spaceViewSequence) {
            let newUnreadChats = previews
                .filter { preview in
                    guard preview.spaceId == spaceId else { return false }

                    if FeatureFlags.muteAndHide {
                        let mode = currentSpaceView.effectiveNotificationMode(for: preview.chatId)
                        if mode == .nothing {
                            guard preview.mentionCounter > 0 || preview.hasUnreadReactions else { return false }
                        }
                    }

                    guard preview.hasCounters else { return false }
                    guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }) else { return false }
                    return !chatDetail.isArchivedOrDeleted
                }
                .map { UnreadChatWidgetData(id: $0.chatId, spaceId: spaceId, output: output) }

            guard unreadChats != newUnreadChats else { continue }
            unreadChats = newUnreadChats
        }
    }
}
