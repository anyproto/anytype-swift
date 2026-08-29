import Services
import Foundation
import AnytypeCore
import OrderedCollections
import SwiftUI
import UIKit

@MainActor
@Observable
final class UnifiedSearchViewModel {

    private enum Constants {
        static let browseLimit = 20
        static let searchLimit = 100
        static let channelRowsLimit = 3
        // A short query (up to three letters) matches half the vault - keep the
        // injected groups to a taste; from four letters show the full hand
        static let personRowsLimitShort = 3
        static let personRowsLimitFull = 10
        static let personRowsFullQueryLength = 4
        static let typeChipsLimit = 8
        static let memberChipsLimit = 3
        // Covered by other chips (Media) or never useful as a type filter
        static let excludedTypeChipKeys: Set<ObjectTypeUniqueKey> = [
            .template, .participant, .objectType, .file, .image, .video, .audio, .chatDerived, .discussion, .date
        ]
    }

    @ObservationIgnored
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @ObservationIgnored
    @Injected(\.crossSpaceSearchService)
    private var crossSpaceSearchService: any CrossSpaceSearchServiceProtocol
    @ObservationIgnored
    @Injected(\.searchWithMetaModelBuilder)
    private var searchWithMetaModelBuilder: any SearchWithMetaModelBuilderProtocol
    @ObservationIgnored
    @Injected(\.unifiedSearchStateService)
    private var unifiedSearchStateService: any UnifiedSearchStateServiceProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantsStorage)
    private var participantsStorage: any ParticipantsStorageProtocol
    @ObservationIgnored
    @Injected(\.crossSpaceTypesStorage)
    private var crossSpaceTypesStorage: any CrossSpaceTypesStorageProtocol
    @ObservationIgnored
    @Injected(\.crossSpaceParticipantsStorage)
    private var crossSpaceParticipantsStorage: any CrossSpaceParticipantsStorageProtocol
    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @ObservationIgnored
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol
    @ObservationIgnored
    @Injected(\.messageTextBuilder)
    private var messageTextBuilder: any MessageTextBuilderProtocol
    @ObservationIgnored
    @Injected(\.spaceHubSpacesStorage)
    private var spaceHubSpacesStorage: any SpaceHubSpacesStorageProtocol

    @ObservationIgnored
    private let moduleData: UnifiedSearchModuleData
    @ObservationIgnored
    private let messageDateFormatter = HistoryDateFormatter()
    @ObservationIgnored
    private let browseDateFormatter = AnytypeRelativeDateTimeFormatter()

    var state = UnifiedSearchState()
    var tokenModels = [UnifiedSearchTokenViewModel]()
    var chips = [UnifiedSearchChipModel]()
    var channelRows = [UnifiedSearchChannelRow]()
    var personRows = [UnifiedSearchPersonRow]()
    var typeRows = [UnifiedSearchPickerRow]()
    // Focused listing (a grouped row was tapped): per-space instances of the
    // focused type/person, served synchronously from the vault-wide stores
    var focusRows = [UnifiedSearchFocusRow]()
    var focusSuggestions = [UnifiedSearchFocusSuggestion]()
    var focusSectionTitle: String?
    @ObservationIgnored
    private var snapshots = [UnifiedSearchSnapshot]()
    var rows = [SearchWithMetaModel]() {
        didSet {
            guard rows != oldValue else { return }
            updateRowSections()
        }
    }
    // The empty-query browse groups by day; a text search stays one ranked list
    var rowSections = [ListSectionData<String?, SearchWithMetaModel>]()
    var messageRows = [UnifiedSearchMessageRow]()
    var selectedTokenId: String?
    var showPeoplePicker = false
    var showTypesPicker = false
    var showOnboarding = false
    var isInitial = true

    @ObservationIgnored
    @UserDefault("UserData.UnifiedSearchOnboardingSeen", defaultValue: false)
    private var onboardingSeen: Bool

    private var participantCanEdit = false
    @ObservationIgnored
    private var typesById = [String: ObjectDetails]()
    // Derived indexes, rebuilt once per types tick (see rebuildTypeIndexes)
    @ObservationIgnored
    private var typesByUniqueKeyAndSpace = [String: [String: ObjectDetails]]()
    @ObservationIgnored
    private var typeCountByUniqueKey = [String: Int]()
    @ObservationIgnored
    private var sortedGlobalTypes = [ObjectDetails]()
    @ObservationIgnored
    private var allParticipants = [Participant]()
    @ObservationIgnored
    private var allChats = [ObjectDetails]()
    @ObservationIgnored
    private var hubSpaceViews = [SpaceView]()
    // Resolved message containers (chats + thread-parent pages), accumulated
    @ObservationIgnored
    private var containersById = [String: ObjectDetails]()
    @ObservationIgnored
    private var unresolvableContainerIds = Set<String>()
    @ObservationIgnored
    private var lastCrossSpaceRecords: [ObjectDetails]?
    @ObservationIgnored
    private var lastMessageResults: [ChatMessageSearchResult]?
    @ObservationIgnored
    private var skipDebounceOnce = true
    @ObservationIgnored
    private var canLoadMore = false
    @ObservationIgnored
    private var isLoadingMore = false
    @ObservationIgnored
    private var isClosed = false
    // attachToMessage: details of the listed objects, keyed by id
    @ObservationIgnored
    private var attachDetailsById = [String: ObjectDetails]()
    // Re-arms the bottom sentinel's onAppear after each applied page
    var loadMoreSentinelId = 0
    // Bumped to summon the keyboard: a token selected by tap is removed with
    // backspace, which needs the field focused even after a scroll dismissed it
    var fieldFocusRequestId = 0

    var isGlobal: Bool { state.spaceScopeId == nil }
    var animatesBarExpansion: Bool { moduleData.animatesBarExpansion }
    // Create Channel is the Channels bucket's one action
    var showsCreateChannelAction: Bool { isGlobal && state.whatBucket == .channels }

    func onCreatePersonalChannel() {
        moduleData.onCreatePersonalChannel()
    }

    func onCreateGroupChannel() {
        moduleData.onCreateGroupChannel()
    }

    func onJoinQrCode() {
        moduleData.onJoinQrCode()
    }

    func onCancel() {
        // Resign with the tap so the keyboard drops together with the overlay,
        // not after it (the field only resigns on window removal otherwise)
        UIApplication.shared.hideKeyboard()
        // An explicit close discards the search - reopening starts fresh; the
        // flag keeps an in-flight search() from re-persisting what x discarded
        isClosed = true
        if moduleData.purpose == .navigation {
            unifiedSearchStateService.clear()
        }
        moduleData.onClose?()
    }

    // The attach picker's scope is fixed - its token is invisible and untouchable
    private var removableTokens: [UnifiedSearchToken] {
        moduleData.purpose == .attachToMessage
            ? state.tokens.filter { $0.group != .scope }
            : state.tokens
    }

    private var ownIdentity: String? {
        participantsStorage.participants.first?.identity
    }

    init(data: UnifiedSearchModuleData) {
        self.moduleData = data
        // The picker is a one-off session - never continues or pollutes the
        // navigation search's persisted state
        if data.purpose == .navigation {
            self.restoreState()
        }
        // The entry point always overrides the scope slot on open
        self.state.setSpaceScope(data.currentSpaceId)
        if let chatId = data.initialChatId, let spaceId = data.currentSpaceId {
            self.state.addToken(.chat(chatId: chatId, spaceId: spaceId))
        }
        self.updateTokenModels()
        self.rebuildChips()
        self.showOnboarding = data.purpose == .navigation && !onboardingSeen
    }

    // Any tap or keypress counts as seen
    func dismissOnboarding() {
        guard showOnboarding else { return }
        onboardingSeen = true
        showOnboarding = false
    }

    // The vault-wide types/participants/chats subscriptions live for the account
    // lifetime (started by LoginStateService) - the surface only observes them.
    // Streams replay their latest value, so data is available on open.

    func observeTypes() async {
        for await types in await crossSpaceTypesStorage.allTypesSequence {
            typesById = Dictionary(types.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            rebuildTypeIndexes()
            updateTokenModels()
            rebuildChips()
            updateTypeRows()
            updateFocusListing()
            rebuildCrossSpaceRows()
        }
    }

    // One pass per types tick replaces the O(spaces x types) scans on the
    // keystroke/chip/picker paths
    private func rebuildTypeIndexes() {
        var bySpace = [String: [String: ObjectDetails]]()
        var counts = [String: Int]()
        for type in typesById.values where !type.isHidden {
            bySpace[type.uniqueKey, default: [:]][type.spaceId] = type
            counts[type.uniqueKey, default: 0] += 1
        }
        typesByUniqueKeyAndSpace = bySpace
        typeCountByUniqueKey = counts

        // Deduped by uniqueKey, representative = current space when available,
        // name-sorted once (decorated - the title accessor allocates)
        var byUniqueKey = [String: ObjectDetails]()
        let representativeSpaceId = moduleData.currentSpaceId
        for type in typesById.values {
            guard !type.isHidden, !Constants.excludedTypeChipKeys.contains(type.uniqueKeyValue) else { continue }
            if let existing = byUniqueKey[type.uniqueKey] {
                if type.spaceId == representativeSpaceId, existing.spaceId != representativeSpaceId {
                    byUniqueKey[type.uniqueKey] = type
                }
            } else {
                byUniqueKey[type.uniqueKey] = type
            }
        }
        sortedGlobalTypes = byUniqueKey.values
            .map { ($0.title, $0) }
            .sorted { $0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending }
            .map(\.1)
    }

    func observeMembers() async {
        for await participants in await crossSpaceParticipantsStorage.allParticipantsSequence {
            allParticipants = participants
            updateTokenModels()
            rebuildChips()
            updatePersonRows()
            updateFocusListing()
            // Author names/avatars on message rows resolve from participants
            rebuildMessageRows()
        }
    }

    // Channel rows and the 1:1 person ordering must match the Space Hub exactly,
    // which sorts with live message recency - same store, same comparator
    func observeSpaces() async {
        for await spaces in await spaceHubSpacesStorage.spacesStream {
            // The stream ticks on every incoming message anywhere (previews are
            // part of its value) - rebuild only when the order actually changed
            let views = spaces.sortedForSpaceHub().map(\.spaceView)
            guard views != hubSpaceViews else { continue }
            hubSpaceViews = views
            updateChannelRows()
            rebuildChips()
        }
    }

    // The hub-ordered list once the stream delivers; the plain store as a cold-start fallback
    private var orderedSpaceViews: [SpaceView] {
        hubSpaceViews.isNotEmpty ? hubSpaceViews : spaceViewsStorage.allSpaceViews
    }

    // Chat containers gate the Messages chip and caption message results
    func observeChats() async {
        for await chats in await chatDetailsStorage.allChatsSequence {
            allChats = chats
            rebuildChips()
            rebuildMessageRows()
        }
    }

    func startParticipantTask() async {
        guard let spaceId = moduleData.currentSpaceId else { return }
        for await participant in participantsStorage.participantSequence(spaceId: spaceId) {
            guard participant.canEdit != participantCanEdit else { continue }
            participantCanEdit = participant.canEdit
            // canArchive on scoped rows depends on the permission - rebuild
            await search()
        }
    }

    func search() async {
        do {
            // Channel rows come from the in-memory space store - update them
            // instantly on every keystroke, before the debounce
            updateChannelRows()
            // Don't hold the whole screen for the first RPC when the instant
            // lead rows already have something to show
            if isInitial, channelRows.isNotEmpty || personRows.isNotEmpty || typeRows.isNotEmpty {
                isInitial = false
            }

            if isGlobal, state.whatBucket == .channels {
                // The Channels bucket browses the space list itself - no RPC
                lastCrossSpaceRecords = nil
                rows = []
                messageRows = []
                lastMessageResults = nil
                canLoadMore = false
                isInitial = false
                storeState()
                return
            }

            if state.focusedTypeKey != nil || state.focusedPersonIdentity != nil {
                // Focused listings are local - no RPC, no debounce
                updateFocusListing()
                rows = []
                messageRows = []
                lastCrossSpaceRecords = nil
                lastMessageResults = nil
                canLoadMore = false
                isInitial = false
                storeState()
                return
            }
            focusRows = []
            focusSuggestions = []
            focusSectionTitle = nil

            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            if state.whatBucket == .messages || state.chatFilterId != nil {
                try await searchMessages(spaceId: state.spaceScopeId)
            } else if let scopeId = state.spaceScopeId, scopeId == moduleData.currentSpaceId {
                try await searchInCurrentSpace(spaceId: scopeId)
            } else {
                try await searchCrossSpace(spaceId: state.spaceScopeId)
            }

            isInitial = false
            storeState()
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            // Degrade to the empty state - never a blank surface, and never
            // stale rows resurrected by a later stream tick
            rows = []
            messageRows = []
            lastMessageResults = nil
            lastCrossSpaceRecords = nil
            canLoadMore = false
            isInitial = false
        }
    }

    // The bottom sentinel appeared - fetch the next page of the current search
    func onReachedBottom() {
        guard canLoadMore, !isLoadingMore else { return }
        isLoadingMore = true
        Task { [weak self] in
            guard let self else { return }
            defer { isLoadingMore = false }
            do {
                if state.whatBucket == .messages || state.chatFilterId != nil {
                    try await searchMessages(spaceId: state.spaceScopeId, offset: lastMessageResults?.count ?? 0)
                } else if let scopeId = state.spaceScopeId, scopeId == moduleData.currentSpaceId {
                    try await searchInCurrentSpace(spaceId: scopeId, offset: rows.count)
                } else {
                    try await searchCrossSpace(spaceId: state.spaceScopeId, offset: lastCrossSpaceRecords?.count ?? 0)
                }
            } catch {
                // The next sentinel appearance retries
            }
        }
    }

    func onSearchTextChanged() {
        // Typing deselects a selected token
        if selectedTokenId != nil {
            selectedTokenId = nil
        }
        // Clearing the field (x button or backspacing out) returns to the
        // browse without paying the debounce
        if state.searchText.isEmpty {
            skipDebounceOnce = true
        }
        AnytypeAnalytics.instance().logSearchInput(route: moduleData.currentSpaceId == nil ? .vault : .space)
    }

    func onTokenTap(_ token: UnifiedSearchToken) {
        UISelectionFeedbackGenerator().selectionChanged()
        selectedTokenId = selectedTokenId == token.id ? nil : token.id
        if selectedTokenId != nil {
            fieldFocusRequestId += 1
        }
    }

    // Backspace on an empty field: first press selects the last token,
    // second press (or with a tapped-selected token) removes it
    func onBackspaceWhenEmpty() {
        if let selectedTokenId, let token = state.tokens.first(where: { $0.id == selectedTokenId }) {
            logToken(token, action: .remove, source: .backspace)
            skipDebounceOnce = true
            removeTokenOrRestore(token)
            self.selectedTokenId = nil
            updateTokenModels()
            rebuildChips()
        } else if let lastToken = removableTokens.last {
            UISelectionFeedbackGenerator().selectionChanged()
            selectedTokenId = lastToken.id
        }
    }

    func onKeyboardButtonTap() {
        guard let firstRow = rows.first else { return }
        onSelect(searchData: firstRow)
    }

    func onSelect(searchData: SearchWithMetaModel) {
        AnytypeAnalytics.instance().logSearchResult()
        if moduleData.purpose == .attachToMessage {
            guard let details = attachDetailsById[searchData.id] else { return }
            moduleData.onSelectDetails(details)
            return
        }
        moduleData.onSelect(searchData.editorScreenData)
    }

    func onSelectChannel(_ row: UnifiedSearchChannelRow) {
        AnytypeAnalytics.instance().logSearchResult()
        moduleData.onOpenSpace(row.spaceId)
    }

    func onSelectMessage(_ row: UnifiedSearchMessageRow) {
        AnytypeAnalytics.instance().logSearchResult()
        moduleData.onOpenMessage(row.openObjectId, row.spaceId, row.messageId)
    }

    func onChipTap(_ chip: UnifiedSearchChipModel) {
        switch chip.action {
        case .addToken(let token):
            logToken(token, action: replacesInGroup(token) ? .replace : .add, source: .chip)
            skipDebounceOnce = true
            selectedTokenId = nil
            state.addToken(token)
            updateTokenModels()
            rebuildChips()
        case .openPeoplePicker:
            showPeoplePicker = true
        case .openTypesPicker:
            showTypesPicker = true
        }
    }

    var peoplePickerRows: [UnifiedSearchPickerRow] {
        personBrowseList(scopeSpaceId: state.spaceScopeId)
            .filter { $0.identity != ownIdentity }
            .map { UnifiedSearchPickerRow(id: $0.identity, title: $0.title, icon: $0.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))) }
    }

    func onSelectPerson(_ person: UnifiedSearchPickerRow) {
        addPickedToken(.creator(identity: person.id))
    }

    var typesPickerRows: [UnifiedSearchPickerRow] {
        let scopeId = state.spaceScopeId
        return typesBrowseList(scopeSpaceId: scopeId).map { type in
            UnifiedSearchPickerRow(
                id: type.uniqueKey,
                title: type.title,
                icon: type.objectIconImage,
                // "in <Channel> + N other Channels" - global mode only; in a scope
                // every type is from the scope space
                subtitle: scopeId == nil ? typeChannelsCaption(type) : nil
            )
        }
    }

    private func typeChannelsCaption(_ type: ObjectDetails) -> String? {
        guard let spaceName = spaceViewsStorage.spaceView(spaceId: type.spaceId)?.title else { return nil }
        let otherCount = (typeCountByUniqueKey[type.uniqueKey] ?? 1) - 1
        switch otherCount {
        case ..<1:
            return Loc.UnifiedSearch.inSpace(spaceName)
        case 1:
            return Loc.UnifiedSearch.inSpacePlusOne(spaceName)
        default:
            return Loc.UnifiedSearch.inSpacePlusMany(spaceName, otherCount)
        }
    }

    func onSelectType(_ type: UnifiedSearchPickerRow) {
        addPickedToken(.type(uniqueKey: type.id))
    }

    private func addPickedToken(_ token: UnifiedSearchToken, source: SearchTokenSource = .chip) {
        logToken(token, action: replacesInGroup(token) ? .replace : .add, source: source)
        skipDebounceOnce = true
        selectedTokenId = nil
        state.addToken(token)
        pruneOrphanedSnapshots()
        updateTokenModels()
        rebuildChips()
    }

    func onScopeToSpace(_ spaceId: String, source: SearchTokenSource) {
        UISelectionFeedbackGenerator().selectionChanged()
        let token = UnifiedSearchToken.space(spaceId: spaceId)
        logToken(token, action: replacesInGroup(token) ? .replace : .add, source: source)
        skipDebounceOnce = true
        selectedTokenId = nil
        state.setSpaceScope(spaceId)
        pruneOrphanedSnapshots()
        updateTokenModels()
        rebuildChips()
    }

    func onRemoveToken(_ token: UnifiedSearchToken) {
        UISelectionFeedbackGenerator().selectionChanged()
        logToken(token, action: .remove, source: .token)
        skipDebounceOnce = true
        selectedTokenId = nil
        removeTokenOrRestore(token)
        updateTokenModels()
        rebuildChips()
    }

    // Removal is an undo when a snapshot owns the token; a removed chat filter
    // widens one step to the space's messages instead of vanishing
    private func removeTokenOrRestore(_ token: UnifiedSearchToken) {
        guard !restoreSnapshotIfOwned(removedToken: token) else { return }
        state.removeToken(token)
        if case .chat = token {
            state.addToken(.kind(.messages))
        }
    }

    func onRemove(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }

        // A destructive swipe action removes the row from the list
        // optimistically - the data must follow in the same update, or the
        // List's counts diverge and the next update crashes UIKit
        rows.removeAll { $0.id == objectId }
        lastCrossSpaceRecords?.removeAll { $0.id == objectId }

        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - Loaders

    private func searchInCurrentSpace(spaceId: String, offset: Int = 0) async throws {
        let requestState = state
        let spaceType = spaceViewsStorage.spaceView(spaceId: spaceId)?.spaceType
        let layouts = state.whatBucket?.layouts
            ?? ObjectTypeSection.all.supportedLayouts(spaceType: spaceType).filter { $0 != .participant }

        let sorts: [DataviewSort] = .builder {
            if state.searchText.isEmpty {
                ObjectSort(relation: state.browseSort == .created ? .dateCreated : .dateUpdated).asDataviewSort()
            } else {
                SearchHelper.sort(relation: BundledPropertyKey.lastOpenedDate, type: .desc)
            }
        }

        let results = try await searchWithMetaService.search(
            text: state.searchText,
            spaceId: spaceId,
            layouts: layouts,
            excludedLayouts: creatorChatExclusion(),
            typeUniqueKey: state.typeUniqueKey,
            creators: creatorFilterIds(scopeSpaceId: spaceId),
            sorts: sorts,
            excludedObjectIds: moduleData.excludedObjectIds,
            offset: offset
        )

        guard requestState == state else { return }

        if moduleData.purpose == .attachToMessage {
            // Selection hands ObjectDetails back - keep them reachable by row id
            for result in results {
                attachDetailsById[result.objectDetails.id] = result.objectDetails
            }
        }

        lastCrossSpaceRecords = nil
        messageRows = []
        lastMessageResults = nil
        let newRows = results.map {
            searchWithMetaModelBuilder.buildModel(with: $0, spaceId: spaceId, participantCanEdit: participantCanEdit)
        }.uniqued(by: \.id)
        if offset > 0 {
            let existingIds = Set(rows.map(\.id))
            let added = newRows.filter { !existingIds.contains($0.id) }
            // A full page of duplicates must not re-arm the sentinel at the
            // same offset - progress is the loop condition
            canLoadMore = results.count >= Constants.searchLimit && added.isNotEmpty
            rows += added
        } else {
            canLoadMore = results.count >= Constants.searchLimit
            rows = newRows
        }
        loadMoreSentinelId += 1
    }

    private func searchCrossSpace(spaceId: String?, offset: Int = 0) async throws {
        if state.whatBucket == .chats {
            try await searchChats(spaceId: spaceId, offset: offset)
            return
        }
        let requestState = state
        let browse = state.searchText.trimmed.isEmpty

        // Type objects are excluded from the generic empty browse (noise) and
        // from a plain text query while the Types lead group is injected (the
        // group replaces per-space type rows); tokened searches keep them
        var excludedLayouts = creatorChatExclusion()
        if state.whatBucket == nil, state.typeUniqueKey == nil, browse || showsLeadRows {
            excludedLayouts.append(.objectType)
        }

        // The first browse page is small; every following page is full-size
        let limit = (browse && offset == 0) ? Constants.browseLimit : Constants.searchLimit

        // allStoresLoaded == false right after app start - render the partial
        // result as is, every keystroke re-queries and self-heals. No retry loop.
        // The browse follows the recency toggle - explicit on both orders so the
        // server's sort field always matches the client's day-grouping field;
        // text queries trust the backend's relevance
        let sorts: [DataviewSort] = .builder {
            if browse {
                SearchHelper.sort(relation: state.browseSort == .created ? .createdDate : .lastModifiedDate, type: .desc)
            }
        }

        let result = try await crossSpaceSearchService.search(
            text: state.searchText,
            // No bucket = the visible-object allowlist (the old search's "All"):
            // keeps relations, relation options, dates etc. out of the results
            layouts: state.whatBucket?.layouts ?? DetailsLayout.visibleLayoutsWithFiles(spaceType: nil),
            excludedLayouts: excludedLayouts,
            typeUniqueKey: state.typeUniqueKey,
            creators: creatorFilterIds(scopeSpaceId: spaceId),
            sorts: sorts,
            spaceId: spaceId,
            offset: offset,
            limit: limit
        )

        guard requestState == state else { return }

        let records = result.records.uniqued(by: \.id)
        messageRows = []
        lastMessageResults = nil
        if offset > 0, let existing = lastCrossSpaceRecords {
            let existingIds = Set(existing.map(\.id))
            let added = records.filter { !existingIds.contains($0.id) }
            canLoadMore = result.records.count >= limit && added.isNotEmpty
            lastCrossSpaceRecords = existing + added
        } else {
            canLoadMore = result.records.count >= limit
            lastCrossSpaceRecords = records
        }
        rebuildCrossSpaceRows()
        loadMoreSentinelId += 1
    }

    // Message search covers all chats and discussion threads at once: empty
    // chatObjectId = all chats in the space, empty spaceId too = all spaces.
    // Always newest-first - relevance order groups hits per chat and reads as
    // arbitrary (the client overrides the backend's score-first default).
    private func searchMessages(spaceId: String?, offset: Int = 0) async throws {
        let requestState = state
        // The first browse page is small; every following page is full-size
        let limit = (state.searchText.trimmed.isEmpty && offset == 0) ? Constants.browseLimit : Constants.searchLimit
        let results = try await chatService.searchMessages(
            // The chat filter pins its own space even after the scope token is gone
            spaceId: spaceId ?? state.chatFilterSpaceId ?? "",
            chatObjectId: state.chatFilterId ?? "",
            query: state.searchText,
            sorts: [ChatMessageSearchSort.with { $0.key = .createdAt; $0.type = .desc }],
            creators: state.creatorIdentity.map { [$0] } ?? [],
            offset: offset,
            limit: limit
        )

        // The page-size contract counts raw results - messageless ones drop after
        let filtered = results.filter(\.hasMessage).uniqued(by: \.messageID)
        try await resolveContainers(ids: filtered.map(\.chatID))

        guard requestState == state else { return }

        rows = []
        lastCrossSpaceRecords = nil
        if offset > 0, let existing = lastMessageResults {
            let existingIds = Set(existing.map(\.messageID))
            let added = filtered.filter { !existingIds.contains($0.messageID) }
            canLoadMore = results.count >= limit && added.isNotEmpty
            lastMessageResults = existing + added
        } else {
            canLoadMore = results.count >= limit
            lastMessageResults = filtered
        }
        rebuildMessageRows()
        loadMoreSentinelId += 1
    }

    // Re-run when participants or containers arrive after the search itself
    // (e.g. a saved search restored right on open)
    private func rebuildMessageRows() {
        guard let results = lastMessageResults else { return }
        for chat in allChats {
            containersById[chat.id] = chat
        }
        let showSpaceCaption = isGlobal
        // One pass over the participants store per rebuild, not per row
        var participantBySpacedIdentity = [String: Participant]()
        var participantByIdentity = [String: Participant]()
        for participant in allParticipants {
            participantBySpacedIdentity["\(participant.identity)|\(participant.spaceId)"] = participant
            if participantByIdentity[participant.identity] == nil {
                participantByIdentity[participant.identity] = participant
            }
        }
        messageRows = results.map { result in
            let participant = participantBySpacedIdentity["\(result.message.creator)|\(result.spaceID)"]
                ?? participantByIdentity[result.message.creator]
            return buildMessageRow(
                result,
                participant: participant,
                spaceCaption: showSpaceCaption ? spaceCaption(spaceId: result.spaceID) : nil
            )
        }
    }

    // Container resolution, one batch per result page:
    // 1. real chats from the vault-wide chats storage;
    // 2. discussion ids resolve to the PARENT object carrying the discussionId
    //    relation - the row captions with the attached object's name;
    // 3. leftovers get one by-id fetch, accepted only when a real chat comes
    //    back - a bare Discussion object deliberately renders no caption.
    private func resolveContainers(ids: [String]) async throws {
        for chat in allChats {
            containersById[chat.id] = chat
        }
        var unresolved = Set(ids).filter { containersById[$0] == nil && !unresolvableContainerIds.contains($0) }
        guard unresolved.isNotEmpty else { return }

        let parents = (try? await crossSpaceSearchService.discussionParents(discussionIds: Array(unresolved))) ?? []
        for parent in parents where parent.discussionId.isNotEmpty {
            containersById[parent.discussionId] = parent
            unresolved.remove(parent.discussionId)
        }
        guard unresolved.isNotEmpty else { return }

        let fetched = (try? await crossSpaceSearchService.objects(ids: Array(unresolved))) ?? []
        for details in fetched where details.resolvedLayoutValue == .chatDerived {
            containersById[details.id] = details
            unresolved.remove(details.id)
        }
        // What neither step resolved never will - don't re-query it every page
        unresolvableContainerIds.formUnion(unresolved)
    }

    private func buildMessageRow(_ result: ChatMessageSearchResult, participant: Participant?, spaceCaption: SearchSpaceCaption?) -> UnifiedSearchMessageRow {
        let message = result.message

        let snippet: AttributedString
        if result.highlight.isNotEmpty {
            var highlighted = AttributedString(result.highlight)
            // Ranges are utf-16 offsets valid only against the highlight string
            for range in result.highlightRanges where range.from < range.to {
                let nsRange = NSRange(location: Int(range.from), length: Int(range.to - range.from))
                if let attrRange = Range<AttributedString.Index>(nsRange, in: highlighted) {
                    highlighted[attrRange].foregroundColor = Color.Pure.blue
                }
            }
            snippet = highlighted
        } else {
            let plainText = messageTextBuilder.makeMessaeWithoutStyle(content: message.message)
            if plainText.isNotEmpty {
                snippet = AttributedString(plainText)
            } else {
                // Discussion messages carry their text in content blocks, not in
                // the plain message field
                let blocksText = message.blocks
                    .compactMap { block -> String? in
                        guard case .text(let textBlock) = block.content else { return nil }
                        return textBlock.text
                    }
                    .joined(separator: " ")
                snippet = AttributedString(blocksText)
            }
        }

        // A discussion parent is keyed by the discussion's id but carries its own -
        // opening it lands on the parent editor with the thread at the message
        let container = containersById[result.chatID]
        let openObjectId = (container?.id).flatMap { $0 != result.chatID ? $0 : nil } ?? result.chatID

        return UnifiedSearchMessageRow(
            messageId: message.id,
            chatObjectId: result.chatID,
            openObjectId: openObjectId,
            spaceId: result.spaceID,
            authorIcon: participant?.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder)),
            authorName: participant?.title ?? "",
            snippet: snippet,
            dateText: messageDateFormatter.localizedDateString(for: message.createdAtDate),
            containerName: containersById[result.chatID]?.title,
            spaceCaption: spaceCaption
        )
    }

    private func searchChats(spaceId: String?, offset: Int) async throws {
        let requestState = state
        let query = state.searchText.trimmed
        let limit = (query.isEmpty && offset == 0) ? Constants.browseLimit : Constants.searchLimit

        let result = try await crossSpaceSearchService.searchChats(
            nameQuery: query.isNotEmpty ? query : nil,
            creators: creatorFilterIds(scopeSpaceId: spaceId),
            spaceId: spaceId,
            offset: offset,
            limit: limit
        )

        guard requestState == state else { return }

        let records = result.records.uniqued(by: \.id)
        messageRows = []
        lastMessageResults = nil
        if offset > 0, let existing = lastCrossSpaceRecords {
            let existingIds = Set(existing.map(\.id))
            let added = records.filter { !existingIds.contains($0.id) }
            canLoadMore = result.records.count >= limit && added.isNotEmpty
            lastCrossSpaceRecords = existing + added
        } else {
            canLoadMore = result.records.count >= limit
            lastCrossSpaceRecords = records
        }
        rebuildCrossSpaceRows()
        loadMoreSentinelId += 1
    }

    private func rebuildCrossSpaceRows() {
        guard let records = lastCrossSpaceRecords else { return }
        let showSpaceCaption = isGlobal
        rows = records.map { details in
            searchWithMetaModelBuilder.buildCrossSpaceModel(
                details: details,
                typeName: typesById[details.type]?.title ?? "",
                spaceCaption: showSpaceCaption ? spaceCaption(spaceId: details.spaceId) : nil
            )
        }
    }

    // A creator token narrows to the person's per-space participant ids plus the
    // raw identity (covers legacy records). Chat containers all carry the space
    // creator - noise for every "who" filter, so they are excluded.
    private func creatorFilterIds(scopeSpaceId: String?) -> [String] {
        guard let identity = state.creatorIdentity else { return [] }
        let participantIds = allParticipants
            .filter { $0.identity == identity && (scopeSpaceId == nil || $0.spaceId == scopeSpaceId) }
            .map(\.id)
        return participantIds + [identity]
    }

    private func creatorChatExclusion() -> [DetailsLayout] {
        state.creatorIdentity != nil ? [.chatDerived] : []
    }

    // MARK: - Channels & People

    // Channel and person rows lead only a plain global text query: any filter
    // token means the query is already about something narrower
    private var showsLeadRows: Bool {
        isGlobal
            && state.searchText.trimmed.isNotEmpty
            && state.tokens.allSatisfy { $0.group == .scope }
    }

    private func updateChannelRows() {
        if isGlobal, state.whatBucket == .channels {
            // Bucket browse: the whole space list, filtered by the query
            channelRows = matchingSpaceRows(limit: nil)
        } else if showsLeadRows {
            // Plain text query: up to 3 channel-name matches lead the results
            channelRows = matchingSpaceRows(limit: Constants.channelRowsLimit)
        } else {
            channelRows = []
        }
        updatePersonRows()
    }

    // Person rows follow the channel matches: typing a person's name should
    // reach the person, not only the objects they created
    private func updatePersonRows() {
        defer { updateTypeRows() }
        guard showsLeadRows, state.whatBucket != .channels else {
            personRows = []
            return
        }

        let query = state.searchText.trimmed
        let limit = query.count >= Constants.personRowsFullQueryLength ? Constants.personRowsLimitFull : Constants.personRowsLimitShort

        var oneToOneSpaceIds = [String: String]()
        for spaceView in orderedSpaceViews where spaceView.isOneToOne && spaceView.oneToOneIdentity.isNotEmpty {
            if oneToOneSpaceIds[spaceView.oneToOneIdentity] == nil {
                oneToOneSpaceIds[spaceView.oneToOneIdentity] = spaceView.targetSpaceId
            }
        }
        let spaceIdsByIdentity = activeSpaceIdsByIdentity()

        personRows = personBrowseList(scopeSpaceId: nil)
            .filter { participant in
                guard participant.identity != ownIdentity else { return false }
                return [participant.localName, participant.globalName].contains { $0.localizedStandardContains(query) }
            }
            .prefix(limit)
            .map { participant in
                let oneToOneSpaceId = oneToOneSpaceIds[participant.identity]
                var sharedSpaceIds = spaceIdsByIdentity[participant.identity] ?? []
                // The person's own 1:1 is its own row among the channel matches -
                // the count answers "how many other channels we share"
                if let oneToOneSpaceId {
                    sharedSpaceIds.remove(oneToOneSpaceId)
                }
                return UnifiedSearchPersonRow(
                    identity: participant.identity,
                    participantObjectId: participant.id,
                    spaceId: participant.spaceId,
                    title: participant.title,
                    globalName: participant.globalName,
                    icon: participant.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder)),
                    sharedChannelCount: sharedSpaceIds.count,
                    hasOneToOne: oneToOneSpaceId != nil
                )
            }
    }

    // The Types group follows People: typing a type's name should reach the
    // type itself. Same cap rule as People; deduped by uniqueKey.
    private func updateTypeRows() {
        guard showsLeadRows, state.whatBucket != .channels else {
            typeRows = []
            return
        }
        let query = state.searchText.trimmed
        let limit = query.count >= Constants.personRowsFullQueryLength ? Constants.personRowsLimitFull : Constants.personRowsLimitShort

        typeRows = typesBrowseList(scopeSpaceId: nil)
            .filter { $0.title.localizedStandardContains(query) }
            .prefix(limit)
            .map { type in
                UnifiedSearchPickerRow(
                    id: type.uniqueKey,
                    title: type.title,
                    icon: type.objectIconImage,
                    subtitle: typeChannelsCaption(type)
                )
            }
    }

    // A grouped type row expands into the focused per-space listing; the drill
    // filters objects by the type across every channel
    func onSelectTypeRow(_ row: UnifiedSearchPickerRow) {
        addFocusToken(.typeFocus(uniqueKey: row.id))
    }

    func onDrillTypeRow(_ row: UnifiedSearchPickerRow) {
        UISelectionFeedbackGenerator().selectionChanged()
        addDrillToken(.type(uniqueKey: row.id))
    }

    private func activeSpaceIdsByIdentity() -> [String: Set<String>] {
        var result = [String: Set<String>]()
        for participant in allParticipants where participant.status == .active {
            result[participant.identity, default: []].insert(participant.spaceId)
        }
        return result
    }

    // A grouped person row expands into the focused per-space listing; the
    // participant profile stays one level deeper (rows outside the listing,
    // or the create suggestion inside it)
    func onSelectPersonRow(_ row: UnifiedSearchPersonRow) {
        addFocusToken(.personFocus(identity: row.identity))
    }

    func onDrillPersonRow(_ row: UnifiedSearchPersonRow) {
        UISelectionFeedbackGenerator().selectionChanged()
        addDrillToken(.creator(identity: row.identity))
    }

    // MARK: - Focus

    private func addFocusToken(_ token: UnifiedSearchToken) {
        UISelectionFeedbackGenerator().selectionChanged()
        logToken(token, action: replacesInGroup(token) ? .replace : .add, source: .group)
        pushSnapshot(ownerTokenId: token.id)
        skipDebounceOnce = true
        selectedTokenId = nil
        state.searchText = ""
        state.addToken(token)
        updateTokenModels()
        rebuildChips()
    }

    // A drill is about the drilled thing - the old query found the row, the new
    // search starts clean; removing the token restores it
    private func addDrillToken(_ token: UnifiedSearchToken) {
        pushSnapshot(ownerTokenId: token.id)
        state.searchText = ""
        addPickedToken(token, source: .row)
    }

    private func updateFocusListing() {
        if let uniqueKey = state.focusedTypeKey {
            updateTypeFocusListing(uniqueKey: uniqueKey)
        } else if let identity = state.focusedPersonIdentity {
            updatePersonFocusListing(identity: identity)
        }
    }

    // Every space's instance of the focused type, vault order. Typing filters by
    // type or channel name - "which space's Tasks" is the question being answered.
    private func updateTypeFocusListing(uniqueKey: String) {
        let query = state.searchText.trimmed
        focusSectionTitle = nil
        focusSuggestions = []

        let instancesBySpace = typesByUniqueKeyAndSpace[uniqueKey] ?? [:]
        let instances = orderedSpaceViews.compactMap { spaceView -> UnifiedSearchFocusRow? in
            guard let type = instancesBySpace[spaceView.targetSpaceId] else { return nil }
            let spaceName = spaceView.title
            if query.isNotEmpty, !type.title.localizedStandardContains(query), !spaceName.localizedStandardContains(query) {
                return nil
            }
            return UnifiedSearchFocusRow(
                kind: .typeInstance,
                objectId: type.id,
                spaceId: type.spaceId,
                title: type.title,
                icon: type.objectIconImage,
                caption: Loc.UnifiedSearch.inSpace(spaceName)
            )
        }
        focusRows = instances

        if let name = typesById.values.first(where: { $0.uniqueKey == uniqueKey })?.title {
            focusSectionTitle = name
            focusSuggestions = [.searchTypeEverywhere(uniqueKey: uniqueKey, name: name)]
        }
    }

    // The focused person's membership in every shared space, the 1:1 channel
    // hoisted to the top. Rows filter ("pick the Channel to filter their
    // objects in"), the top suggestion covers all Channels.
    private func updatePersonFocusListing(identity: String) {
        let query = state.searchText.trimmed
        focusSectionTitle = Loc.UnifiedSearch.Focus.personSection

        let oneToOneSpaceView = orderedSpaceViews.first { $0.isOneToOne && $0.oneToOneIdentity == identity }
        let participantsBySpace = Dictionary(
            allParticipants.filter { $0.identity == identity && $0.status == .active }.map { ($0.spaceId, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let personName = participantsBySpace.values.first?.title ?? ""

        // Every row is the person; the caption says which membership it is -
        // the listing answers "pick the Channel to filter their objects in"
        let personIcon = participantsBySpace.values.first?.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))
        var rows = [UnifiedSearchFocusRow]()
        if let oneToOneSpaceView {
            rows.append(UnifiedSearchFocusRow(
                kind: .oneToOneChannel,
                objectId: oneToOneSpaceView.id,
                spaceId: oneToOneSpaceView.targetSpaceId,
                title: personName,
                icon: personIcon,
                caption: Loc.UnifiedSearch.Person.oneToOneChannel
            ))
        }
        for spaceView in orderedSpaceViews where spaceView.targetSpaceId != oneToOneSpaceView?.targetSpaceId {
            guard let participant = participantsBySpace[spaceView.targetSpaceId] else { continue }
            rows.append(UnifiedSearchFocusRow(
                kind: .personInstance,
                objectId: participant.id,
                spaceId: participant.spaceId,
                title: personName,
                icon: participant.icon.map { Icon.object($0) } ?? personIcon,
                caption: Loc.UnifiedSearch.inSpace(spaceView.title)
            ))
        }
        if query.isNotEmpty {
            // The person is constant - typing narrows by channel (title covers
            // the 1:1 row, whose caption is the static "1-1 Channel")
            rows = rows.filter {
                $0.title.localizedStandardContains(query) || $0.caption?.localizedStandardContains(query) == true
            }
        }
        focusRows = rows

        var suggestions: [UnifiedSearchFocusSuggestion] = [.searchCreatorEverywhere(identity: identity, name: personName)]
        if oneToOneSpaceView == nil {
            suggestions.append(.createOneToOne(identity: identity))
        }
        focusSuggestions = suggestions
    }

    func onSelectFocusRow(_ row: UnifiedSearchFocusRow) {
        switch row.kind {
        case .typeInstance:
            // A type instance opens
            AnytypeAnalytics.instance().logSearchResult()
            guard let details = typesById[row.objectId] else { return }
            moduleData.onSelect(ScreenData(details: details))
        case .personInstance, .oneToOneChannel:
            // A person's rows filter, never open: creator + that row's channel
            // scope in one gesture, one undo (the snapshot rides the newest token
            // and removes the whole gesture)
            guard let identity = state.focusedPersonIdentity else { return }
            UISelectionFeedbackGenerator().selectionChanged()
            let creatorToken = UnifiedSearchToken.creator(identity: identity)
            let scopeToken = UnifiedSearchToken.space(spaceId: row.spaceId)
            pushSnapshot(ownerTokenId: scopeToken.id, gestureTokenIds: [scopeToken.id, creatorToken.id])
            skipDebounceOnce = true
            selectedTokenId = nil
            state.searchText = ""
            state.addToken(creatorToken)
            state.setSpaceScope(row.spaceId)
            pruneOrphanedSnapshots()
            logToken(scopeToken, action: .add, source: .focus)
            updateTokenModels()
            rebuildChips()
        }
    }

    func onSelectFocusSuggestion(_ suggestion: UnifiedSearchFocusSuggestion) {
        switch suggestion {
        case .searchTypeEverywhere(let uniqueKey, _):
            // Snapshot before the swap - Back returns to the focused view
            let token = UnifiedSearchToken.type(uniqueKey: uniqueKey)
            pushSnapshot(ownerTokenId: token.id)
            state.searchText = ""
            state.removeToken(.typeFocus(uniqueKey: uniqueKey))
            addPickedToken(token, source: .focus)
        case .searchCreatorEverywhere(let identity, _):
            let token = UnifiedSearchToken.creator(identity: identity)
            pushSnapshot(ownerTokenId: token.id)
            state.searchText = ""
            state.removeToken(.personFocus(identity: identity))
            addPickedToken(token, source: .focus)
        case .createOneToOne(let identity):
            // Opens the profile - the 1:1 is created only from its own button
            guard let participant = allParticipants.first(where: { $0.identity == identity }) else { return }
            moduleData.onSelect(.alert(.spaceMember(ObjectInfo(objectId: participant.id, spaceId: participant.spaceId))))
        }
    }

    // MARK: - Snapshots

    private func pushSnapshot(ownerTokenId: String, gestureTokenIds: Set<String>? = nil) {
        snapshots.append(UnifiedSearchSnapshot(
            tokens: state.tokens,
            searchText: state.searchText,
            ownerTokenId: ownerTokenId,
            gestureTokenIds: gestureTokenIds ?? [ownerTokenId]
        ))
        // Unmatched snapshots accumulate across repeated drills - keep a sane depth
        if snapshots.count > 20 {
            snapshots.removeFirst(snapshots.count - 20)
        }
    }

    // Removing a row-added token restores the pre-drill search; an explicit
    // removal of any other token also strips it from remaining snapshots - an
    // undo must not resurrect what was removed by hand
    private func restoreSnapshotIfOwned(removedToken: UnifiedSearchToken) -> Bool {
        guard let index = snapshots.lastIndex(where: { $0.ownerTokenId == removedToken.id }) else {
            for i in snapshots.indices {
                snapshots[i].tokens.removeAll { $0 == removedToken }
            }
            return false
        }
        let snapshot = snapshots[index]
        snapshots.removeSubrange(index...)
        // Merge, don't overwrite: the undo removes everything its gesture added,
        // tokens from later separate gestures survive, and snapshot tokens
        // return into the freed groups
        var restored = state.tokens.filter { !snapshot.gestureTokenIds.contains($0.id) && $0 != removedToken }
        for token in snapshot.tokens where !restored.contains(where: { $0.group == token.group }) {
            restored.append(token)
        }
        state.tokens = restored
        state.searchText = snapshot.searchText
        return true
    }

    // A yield rule can remove a token another snapshot rides on - the snapshot
    // is then unreachable and must not linger
    private func pruneOrphanedSnapshots() {
        snapshots.removeAll { snapshot in
            !state.tokens.contains { $0.id == snapshot.ownerTokenId }
        }
    }

    private func matchingSpaceRows(limit: Int?) -> [UnifiedSearchChannelRow] {
        var spaceViews = orderedSpaceViews
        let query = state.searchText.trimmed
        if query.isNotEmpty {
            spaceViews = spaceViews.filter { $0.title.localizedStandardContains(query) }
        }
        if let limit {
            spaceViews = Array(spaceViews.prefix(limit))
        }
        return spaceViews.map { UnifiedSearchChannelRow(spaceId: $0.targetSpaceId, title: $0.title, icon: $0.objectIconImage) }
    }

    private func spaceCaption(spaceId: String) -> SearchSpaceCaption? {
        guard let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId) else { return nil }
        return SearchSpaceCaption(spaceId: spaceId, name: spaceView.title)
    }

    // Rows arrive date-sorted, so day grouping is an order-preserving pass on
    // the active recency order's own field. The Chats bucket sorts by last
    // message - a foreign field would interleave its buckets - so it stays flat.
    private func updateRowSections() {
        guard rows.isNotEmpty else {
            rowSections = []
            return
        }
        guard state.searchText.trimmed.isEmpty, state.whatBucket != .chats else {
            rowSections = [ListSectionData(id: "single_section", data: nil, rows: rows)]
            return
        }
        let today = Date()
        let calendar = Calendar.current
        // Paging regroups the whole accumulated list - memoize the bucket per
        // day (the formatter re-templates internally, tens of us per call)
        var titleByDay = [Date: String]()
        let grouped = OrderedDictionary(
            grouping: rows,
            by: { row in
                let date = (state.browseSort == .created ? row.createdDate : row.lastModifiedDate) ?? today
                let day = calendar.startOfDay(for: date)
                if let cached = titleByDay[day] { return cached }
                let title = browseDateFormatter.localizedString(for: date, relativeTo: today)
                titleByDay[day] = title
                return title
            }
        )
        rowSections = grouped.map { (title, rows) in
            ListSectionData(id: title, data: title, rows: rows)
        }
    }

    // The recency toggle on the browse's first day header (persisted with the state)
    func onToggleBrowseSort(_ sort: UnifiedSearchBrowseSort) {
        guard sort != state.browseSort else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        skipDebounceOnce = true
        state.browseSort = sort
    }

    // MARK: - Chips

    // The row shows only tokens that could still be added: a filled group's
    // chips disappear and return when its token is removed
    private func rebuildChips() {
        var result = [UnifiedSearchChipModel]()
        let scopeId = state.spaceScopeId
        let whatFilled = state.tokens.contains { $0.group == .what }

        // Scope suggestion (global mode only): re-add the entry space.
        // Hidden under the Channels bucket - scoping cannot answer there.
        if scopeId == nil,
           let currentSpaceId = moduleData.currentSpaceId,
           state.whatBucket != .channels,
           spaceViewsStorage.spaceView(spaceId: currentSpaceId) != nil {
            result.append(UnifiedSearchChipModel(token: .space(spaceId: currentSpaceId), title: Loc.UnifiedSearch.Chip.inThisChannel))
        }

        if scopeId == nil, !whatFilled {
            result.append(UnifiedSearchChipModel(token: .kind(.channels), title: UnifiedSearchKindBucket.channels.title))
        }

        // Messages chip only when the scope actually contains chat containers
        // (and never in the attach picker - it searches objects only)
        let scopeHasChats = scopeId.map { id in allChats.contains { $0.spaceId == id } } ?? allChats.isNotEmpty
        if !whatFilled, scopeHasChats, moduleData.purpose == .navigation {
            result.append(UnifiedSearchChipModel(
                token: .kind(.messages),
                title: UnifiedSearchKindBucket.messages.title,
                icon: .asset(ImageAsset.CustomIcons.chatbubble)
            ))
        }

        result.append(contentsOf: personChips(scopeSpaceId: scopeId, byMeOnly: true))

        if !whatFilled {
            let typesChip = UnifiedSearchChipModel(
                action: .openTypesPicker,
                title: Loc.UnifiedSearch.Chip.types,
                icon: .asset(ImageAsset.CustomIcons.shapes)
            )
            if let scopeId {
                result.append(UnifiedSearchChipModel(token: .kind(.media), title: UnifiedSearchKindBucket.media.title))
                result.append(typesChip)
                result.append(contentsOf: typeChips(spaceId: scopeId))
            } else {
                result.append(UnifiedSearchChipModel(token: .kind(.media), title: UnifiedSearchKindBucket.media.title))
                result.append(typesChip)
                for bucket in [UnifiedSearchKindBucket.pages, .bookmarks, .collections, .queries, .chats] {
                    result.append(UnifiedSearchChipModel(token: .kind(bucket), title: bucket.title))
                }
            }
        }

        result.append(contentsOf: personChips(scopeSpaceId: scopeId, byMeOnly: false))

        chips = result
    }

    private func typeChips(spaceId: String) -> [UnifiedSearchChipModel] {
        typesBrowseList(scopeSpaceId: spaceId)
            .prefix(Constants.typeChipsLimit)
            .map { UnifiedSearchChipModel(token: .type(uniqueKey: $0.uniqueKey), title: $0.title) }
    }

    // Types deduped by uniqueKey (stable across spaces), name order. The scope
    // space's instance represents the type when available - templates, hidden
    // and system types excluded. Global list is precomputed per types tick.
    private func typesBrowseList(scopeSpaceId: String?) -> [ObjectDetails] {
        guard let scopeSpaceId else { return sortedGlobalTypes }
        return typesById.values
            .filter { $0.spaceId == scopeSpaceId && !$0.isHidden && !Constants.excludedTypeChipKeys.contains($0.uniqueKeyValue) }
            .map { ($0.title, $0) }
            .sorted { $0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending }
            .map(\.1)
    }

    // "By me" leads the row, member chips close it (desktop order). The >1-member
    // gate covers the whole person section - filtering a solo space by "you" is a no-op.
    // A creator filter has no effect on the channel browse or a focused type
    // listing - offering the chips there would add a dead token
    private var whoFilterApplies: Bool {
        state.whatBucket != .channels && state.focusedTypeKey == nil
    }

    private func personChips(scopeSpaceId: String?, byMeOnly: Bool) -> [UnifiedSearchChipModel] {
        // The who group is spoken for by a creator filter or a focused person -
        // no person chips until it frees up
        guard whoFilterApplies, state.creatorIdentity == nil, state.focusedPersonIdentity == nil, let ownIdentity else { return [] }

        let people = personBrowseList(scopeSpaceId: scopeSpaceId)
        guard people.count > 1 else { return [] }

        if byMeOnly {
            let own = people.first { $0.identity == ownIdentity }
            return [
                UnifiedSearchChipModel(
                    token: .creator(identity: ownIdentity),
                    title: Loc.UnifiedSearch.Chip.byMe,
                    icon: own?.icon.map { Icon.object($0) }
                ),
                UnifiedSearchChipModel(
                    action: .openPeoplePicker,
                    title: Loc.UnifiedSearch.Chip.people,
                    icon: .asset(ImageAsset.CustomIcons.people)
                )
            ]
        }

        return people
            .filter { $0.identity != ownIdentity }
            .prefix(Constants.memberChipsLimit)
            .map { participant in
                UnifiedSearchChipModel(
                    token: .creator(identity: participant.identity),
                    title: Loc.UnifiedSearch.Chip.by(participant.title),
                    icon: participant.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))
                )
            }
    }

    // People deduped by identity in the vault's 1:1-first order: partners of 1:1
    // spaces come first, in the space list's own order (the 1:1 space view carries
    // the other person's identity), the rest alphabetically. The scope space's
    // record represents the person when available.
    private func personBrowseList(scopeSpaceId: String?) -> [Participant] {
        let relevant = allParticipants.filter { participant in
            participant.status == .active && (scopeSpaceId == nil || participant.spaceId == scopeSpaceId)
        }

        var byIdentity = [String: Participant]()
        let representativeSpaceId = scopeSpaceId ?? moduleData.currentSpaceId
        for participant in relevant {
            if let existing = byIdentity[participant.identity] {
                if participant.spaceId == representativeSpaceId, existing.spaceId != representativeSpaceId {
                    byIdentity[participant.identity] = participant
                }
            } else {
                byIdentity[participant.identity] = participant
            }
        }

        var oneToOneOrder = [String: Int]()
        for spaceView in orderedSpaceViews where spaceView.isOneToOne {
            let identity = spaceView.oneToOneIdentity
            guard identity.isNotEmpty, oneToOneOrder[identity] == nil else { continue }
            oneToOneOrder[identity] = oneToOneOrder.count
        }

        return byIdentity.values.sorted { a, b in
            let orderA = oneToOneOrder[a.identity] ?? -1
            let orderB = oneToOneOrder[b.identity] ?? -1
            if orderA >= 0 && orderB >= 0 { return orderA < orderB }
            if orderA >= 0 { return true }
            if orderB >= 0 { return false }
            return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        }
    }

    // MARK: - State

    private func updateTokenModels() {
        tokenModels = state.tokens.compactMap { token in
            switch token {
            case .space(let spaceId):
                // The attach picker's fixed scope never renders as a pill
                guard moduleData.purpose == .navigation else { return nil }
                // An unresolvable scope (left space, ...) is dropped silently below
                guard let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId) else { return nil }
                return UnifiedSearchTokenViewModel(token: token, title: spaceView.title, icon: spaceView.objectIconImage)
            case .kind(let bucket):
                let icon: Icon? = bucket == .messages ? .asset(ImageAsset.CustomIcons.chatbubble) : nil
                return UnifiedSearchTokenViewModel(token: token, title: bucket.title, icon: icon)
            case .chat(let chatId, _):
                // The chat's own name when it has one (multi-chat spaces name
                // their channels); unnamed space-level and 1:1 chats read as
                // the space itself, so those pills wear the space's name
                let chat = allChats.first { $0.id == chatId }
                let spaceView = spaceViewsStorage.allSpaceViews.first { $0.chatId == chatId }
                let chatName = chat?.name.trimmed ?? ""
                return UnifiedSearchTokenViewModel(
                    token: token,
                    title: chatName.isNotEmpty ? chatName : (spaceView?.title ?? "…"),
                    icon: chat?.objectIconImage ?? spaceView?.objectIconImage ?? .asset(ImageAsset.CustomIcons.chatbubble)
                )
            case .type(let uniqueKey):
                // The types map is cold right after open - keep the token and let
                // the subscription resolve the title
                let typeDetails = typesById.values.first { $0.uniqueKey == uniqueKey }
                return UnifiedSearchTokenViewModel(token: token, title: typeDetails?.title ?? "…", icon: typeDetails?.objectIconImage)
            case .creator(let identity):
                let participant = allParticipants.first { $0.identity == identity }
                let icon = participant?.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))
                if identity == ownIdentity {
                    return UnifiedSearchTokenViewModel(token: token, title: Loc.UnifiedSearch.Chip.byMe, icon: icon)
                }
                let title = participant.map { Loc.UnifiedSearch.Chip.by($0.title) } ?? "…"
                return UnifiedSearchTokenViewModel(token: token, title: title, icon: icon)
            case .typeFocus(let uniqueKey):
                // The pill names the focused thing - it says what the listing shows
                let typeDetails = typesById.values.first { $0.uniqueKey == uniqueKey }
                return UnifiedSearchTokenViewModel(token: token, title: typeDetails?.title ?? "…", icon: typeDetails?.objectIconImage)
            case .personFocus(let identity):
                let participant = allParticipants.first { $0.identity == identity }
                return UnifiedSearchTokenViewModel(
                    token: token,
                    title: participant?.title ?? "…",
                    icon: participant?.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))
                )
            }
        }
        // Only space tokens drop when unresolvable - the space store is always warm
        let resolvedTokens = state.tokens.filter { token in
            guard case .space(let spaceId) = token else { return true }
            return spaceViewsStorage.spaceView(spaceId: spaceId) != nil
        }
        if resolvedTokens != state.tokens {
            state.tokens = resolvedTokens
        }
    }

    private func replacesInGroup(_ token: UnifiedSearchToken) -> Bool {
        state.tokens.contains { $0.group == token.group }
    }

    private func logToken(_ token: UnifiedSearchToken, action: SearchTokenAction, source: SearchTokenSource) {
        AnytypeAnalytics.instance().logSearchToken(type: token.analyticsType, action: action, source: source, isGlobal: isGlobal)
    }

    private func needDelay() -> Bool {
        guard skipDebounceOnce else { return true }
        skipDebounceOnce = false
        return false
    }

    private func restoreState() {
        let restoredState = unifiedSearchStateService.restoreState()
        guard let restoredState else {
            AnytypeAnalytics.instance().logScreenSearch(type: .empty)
            return
        }
        state = restoredState
        let type: ScreenSearchType = restoredState == UnifiedSearchState() ? .empty : .saved
        AnytypeAnalytics.instance().logScreenSearch(type: type)
    }

    private func storeState() {
        guard !isClosed, moduleData.purpose == .navigation else { return }
        unifiedSearchStateService.storeState(state)
    }
}

private extension Array {
    // A duplicate id inside one applied page corrupts the List's diff
    // (UIKit count-mismatch crash) - never trust a page to be unique
    func uniqued(by id: (Element) -> String) -> [Element] {
        var seen = Set<String>()
        return filter { seen.insert(id($0)).inserted }
    }
}

private extension UnifiedSearchToken {
    var analyticsType: SearchTokenType {
        switch self {
        case .space: .space
        case .kind: .kind
        // The chat filter is a narrowed messages kind
        case .chat: .chat
        // A focus is a what-token variant of the type/member filter
        case .type, .typeFocus, .personFocus: .type
        case .creator: .creator
        }
    }
}
