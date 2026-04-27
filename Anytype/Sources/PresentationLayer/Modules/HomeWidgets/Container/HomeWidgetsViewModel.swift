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
    let channelWidgetsObject: any BaseDocumentProtocol

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
    @Injected(\.objectsWithUnreadDiscussionsSubscription) @ObservationIgnored
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol

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
    var homeWidgetData: HomepageWidgetViewData?
    var unreadSectionIsExpanded: Bool = false
    var unreadItems: [UnreadSectionItem] = []
    var myFavoritesSectionIsExpanded: Bool = false
    var myFavoritesListViewModel: MyFavoritesListViewModel?
    private var supportsMultiChats: Bool = false

    var spaceId: String { info.accountSpaceId }

    var shouldShowUnreadSection: Bool {
        supportsMultiChats && unreadItems.isNotEmpty
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
        let channelWidgetsObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.channelWidgetsObject = channelWidgetsObject
        if FeatureFlags.personalFavorites {
            let personalWidgetsObject = documentService.document(
                objectId: info.personalWidgetsId,
                spaceId: info.accountSpaceId
            )
            self.myFavoritesListViewModel = MyFavoritesListViewModel(
                spaceId: info.accountSpaceId,
                personalWidgetsObject: personalWidgetsObject,
                channelWidgetsObject: channelWidgetsObject,
                onObjectSelected: { [weak output] details in
                    output?.onObjectSelected(screenData: details.screenData())
                }
            )
        } else {
            self.myFavoritesListViewModel = nil
        }
        self.pinnedSectionIsExpanded = expandedService.isExpanded(id: Constants.pinnedSectionId, defaultValue: true)
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Constants.objectTypeSectionId, defaultValue: true)
        self.unreadSectionIsExpanded = expandedService.isExpanded(id: Constants.unreadSectionId, defaultValue: true)
        self.myFavoritesSectionIsExpanded = expandedService.isExpanded(id: Constants.myFavoritesSectionId, defaultValue: true)
    }

    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let myFavoritesSub: () = startMyFavoritesTask()
        async let canEditSub: () = startCanEditSubscription()
        async let objectTypesTask: () = startObjectTypesTask()
        async let spaceViewTask: () = startSpaceViewTask()
        async let unreadItemsTask: () = startUnreadItemsTask()

        _ = await (widgetObjectSub, myFavoritesSub, canEditSub, objectTypesTask, spaceViewTask, unreadItemsTask)
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
                dashboadId: channelWidgetsObject.objectId,
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
        for await _ in channelWidgetsObject.syncPublisher.values {
            widgetsDataLoaded = true

            let blocks = channelWidgetsObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: channelWidgetsObject)

            let newWidgetBlocks = blocks
                .compactMap { channelWidgetsObject.widgetInfo(block: $0) }

            guard widgetBlocks != newWidgetBlocks else { continue }

            widgetBlocks = newWidgetBlocks
        }
    }

    private func startMyFavoritesTask() async {
        // Drives the `MyFavoritesListViewModel.rows` list — only spins up when the feature flag
        // enabled the sub-viewmodel in `init`.
        guard let myFavoritesListViewModel else { return }
        await myFavoritesListViewModel.startSubscriptions()
    }

    private func startCanEditSubscription() async {
        for await canEdit in accountParticipantStorage.canEditSequence(spaceId: info.accountSpaceId) {
            homeState = canEdit ? .readwrite : .readonly
            canCreateObjectType = canEdit
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
            // 1-on-1 channels always home on Chat; `SpaceView.homepage` is unreliable there
            // (middleware may not populate it), so fall back to `info.spaceChatId`.
            let effectiveHomepage: SpaceHomepage = spaceView.isOneToOne && !info.spaceChatId.isEmpty
                ? .object(objectId: info.spaceChatId)
                : spaceView.homepage
            guard case let .object(objectId) = effectiveHomepage else {
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

    private func startUnreadItemsTask() async {
        let spaceId = spaceId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        guard !(spaceView?.isOneToOne ?? true) else { return }

        let previewsSequence = await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
        let chatsSequence = await chatDetailsStorage.allChatsSequence
        let spaceViewSequence = workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values
        let unreadDiscussionsSequence = await unreadDiscussionsSubscription.unreadBySpaceSequence

        // combineLatest is max-arity 3 — nest two pairs.
        let chatTriple = combineLatest(previewsSequence, chatsSequence, spaceViewSequence)
        for await (triple, unreadBySpace) in combineLatest(chatTriple, unreadDiscussionsSequence) {
            let (previews, chatDetails, currentSpaceView) = triple

            let chatItems: [UnreadSectionItem] = previews.compactMap { preview in
                guard preview.spaceId == spaceId else { return nil }

                if FeatureFlags.muteAndHide {
                    let mode = currentSpaceView.effectiveNotificationMode(for: preview.chatId)
                    if mode == .nothing {
                        guard preview.mentionCounter > 0 || preview.hasUnreadReactions else { return nil }
                    }
                }

                guard preview.hasCounters else { return nil }
                guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }), !chatDetail.isArchivedOrDeleted else {
                    return nil
                }
                return .chat(
                    UnreadChatWidgetData(id: preview.chatId, spaceId: spaceId, output: output),
                    lastMessageDate: preview.lastMessage?.createdAt
                )
            }

            let parentSource = FeatureFlags.discussionButton ? (unreadBySpace[spaceId]?.parents ?? []) : []
            let parentItems: [UnreadSectionItem] = parentSource.compactMap { parent in
                if FeatureFlags.muteAndHide && currentSpaceView.pushNotificationMode == .nothing {
                    guard parent.hasUnreadMention else { return nil }
                }
                // Aggregator admits any subscribed parent; drop fully-caught-up rows here so the section
                // never shows a name with no badge. Mirrors the chat path's `hasCounters` guard.
                guard parent.unreadMessageCount > 0 || parent.hasUnreadMention else { return nil }
                return .discussionParent(
                    UnreadDiscussionParentWidgetData(id: parent.id, spaceId: spaceId, output: output),
                    lastMessageDate: parent.lastMessageDate
                )
            }

            let merged = (chatItems + parentItems).sorted { $0.sortDate > $1.sortDate }
            guard unreadItems != merged else { continue }
            unreadItems = merged
        }
    }
}
