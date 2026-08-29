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
        // A short query matches half the vault; three letters can usually name
        // a person - then show the full hand
        static let personRowsLimitShort = 3
        static let personRowsLimitFull = 10
        static let personRowsFullQueryLength = 3
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
    var rows = [SearchWithMetaModel]() {
        didSet { updateRowSections() }
    }
    // The empty-query browse groups by day; a text search stays one ranked list
    var rowSections = [ListSectionData<String?, SearchWithMetaModel>]()
    var messageRows = [UnifiedSearchMessageRow]()
    var selectedTokenId: String?
    var showPeoplePicker = false
    var showTypesPicker = false
    var isInitial = true

    private var participantCanEdit = false
    @ObservationIgnored
    private var typesById = [String: ObjectDetails]()
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
    private var lastCrossSpaceRecords: [ObjectDetails]?
    @ObservationIgnored
    private var lastMessageResults: [ChatMessageSearchResult]?
    @ObservationIgnored
    private var skipDebounceOnce = true
    @ObservationIgnored
    private var canLoadMore = false
    @ObservationIgnored
    private var isLoadingMore = false
    // Re-arms the bottom sentinel's onAppear after each applied page
    var loadMoreSentinelId = 0

    var isGlobal: Bool { state.spaceScopeId == nil }
    var animatesBarExpansion: Bool { moduleData.animatesBarExpansion }

    func onCancel() {
        // Resign with the tap so the keyboard drops together with the overlay,
        // not after it (the field only resigns on window removal otherwise)
        UIApplication.shared.hideKeyboard()
        // An explicit close discards the search - reopening starts fresh
        unifiedSearchStateService.clear()
        moduleData.onClose?()
    }

    private var ownIdentity: String? {
        participantsStorage.participants.first?.identity
    }

    init(data: UnifiedSearchModuleData) {
        self.moduleData = data
        self.restoreState()
        // The entry point always overrides the scope slot on open
        self.state.setSpaceScope(data.currentSpaceId)
        self.updateTokenModels()
        self.rebuildChips()
    }

    // The vault-wide types/participants/chats subscriptions live for the account
    // lifetime (started by LoginStateService) - the surface only observes them.
    // Streams replay their latest value, so data is available on open.

    func observeTypes() async {
        for await types in await crossSpaceTypesStorage.allTypesSequence {
            typesById = Dictionary(types.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            updateTokenModels()
            rebuildChips()
            rebuildCrossSpaceRows()
        }
    }

    func observeMembers() async {
        for await participants in await crossSpaceParticipantsStorage.allParticipantsSequence {
            allParticipants = participants
            updateTokenModels()
            rebuildChips()
            updatePersonRows()
            // Author names/avatars on message rows resolve from participants
            rebuildMessageRows()
        }
    }

    // Channel rows and the 1:1 person ordering must match the Space Hub exactly,
    // which sorts with live message recency - same store, same comparator
    func observeSpaces() async {
        for await spaces in await spaceHubSpacesStorage.spacesStream {
            hubSpaceViews = spaces.sortedForSpaceHub().map(\.spaceView)
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

            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            if state.whatBucket == .messages {
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
            rows = []
            messageRows = []
            lastMessageResults = nil
        }
    }

    // The bottom sentinel appeared - fetch the next page of the current search
    func onReachedBottom() {
        guard canLoadMore, !isLoadingMore else { return }
        isLoadingMore = true
        Task {
            defer { isLoadingMore = false }
            do {
                if state.whatBucket == .messages {
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
        selectedTokenId = nil
        AnytypeAnalytics.instance().logSearchInput()
    }

    func onTokenTap(_ token: UnifiedSearchToken) {
        UISelectionFeedbackGenerator().selectionChanged()
        selectedTokenId = selectedTokenId == token.id ? nil : token.id
    }

    // Backspace on an empty field: first press selects the last token,
    // second press (or with a tapped-selected token) removes it
    func onBackspaceWhenEmpty() {
        if let selectedTokenId, let token = state.tokens.first(where: { $0.id == selectedTokenId }) {
            logToken(token, action: .remove, source: .backspace)
            skipDebounceOnce = true
            state.removeToken(token)
            self.selectedTokenId = nil
            updateTokenModels()
            rebuildChips()
        } else if let lastToken = state.tokens.last {
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
        let otherCount = typesById.values.count { $0.uniqueKey == type.uniqueKey && !$0.isHidden } - 1
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
        updateTokenModels()
        rebuildChips()
    }

    func onRemoveToken(_ token: UnifiedSearchToken) {
        UISelectionFeedbackGenerator().selectionChanged()
        logToken(token, action: .remove, source: .token)
        skipDebounceOnce = true
        selectedTokenId = nil
        state.removeToken(token)
        updateTokenModels()
        rebuildChips()
    }

    func onRemove(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }

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
                ObjectSort(relation: .dateUpdated).asDataviewSort()
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
            excludedObjectIds: [],
            offset: offset
        )

        guard requestState == state else { return }
        canLoadMore = results.count >= Constants.searchLimit

        lastCrossSpaceRecords = nil
        messageRows = []
        lastMessageResults = nil
        let newRows = results.map {
            searchWithMetaModelBuilder.buildModel(with: $0, spaceId: spaceId, participantCanEdit: participantCanEdit)
        }
        if offset > 0 {
            let existingIds = Set(rows.map(\.id))
            rows += newRows.filter { !existingIds.contains($0.id) }
        } else {
            rows = newRows
        }
        loadMoreSentinelId += 1
    }

    private func searchCrossSpace(spaceId: String?, offset: Int = 0) async throws {
        let requestState = state
        let browse = state.searchText.isEmpty

        // Type objects are noise in the generic empty browse only - with a what
        // token or a text query they are legitimate results
        var excludedLayouts = creatorChatExclusion()
        if browse, state.whatBucket == nil, state.typeUniqueKey == nil {
            excludedLayouts.append(.objectType)
        }

        // The first browse page is small; every following page is full-size
        let limit = (browse && offset == 0) ? Constants.browseLimit : Constants.searchLimit

        // allStoresLoaded == false right after app start - render the partial
        // result as is, every keystroke re-queries and self-heals. No retry loop.
        let result = try await crossSpaceSearchService.search(
            text: state.searchText,
            layouts: state.whatBucket?.layouts ?? [],
            excludedLayouts: excludedLayouts,
            typeUniqueKey: state.typeUniqueKey,
            creators: creatorFilterIds(scopeSpaceId: spaceId),
            spaceId: spaceId,
            offset: offset,
            limit: limit
        )

        guard requestState == state else { return }
        canLoadMore = result.records.count >= limit

        messageRows = []
        lastMessageResults = nil
        if offset > 0, let existing = lastCrossSpaceRecords {
            let existingIds = Set(existing.map(\.id))
            lastCrossSpaceRecords = existing + result.records.filter { !existingIds.contains($0.id) }
        } else {
            lastCrossSpaceRecords = result.records
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
        let limit = (state.searchText.isEmpty && offset == 0) ? Constants.browseLimit : Constants.searchLimit
        let results = try await chatService.searchMessages(
            spaceId: spaceId ?? "",
            chatObjectId: "",
            query: state.searchText,
            sorts: [ChatMessageSearchSort.with { $0.key = .createdAt; $0.type = .desc }],
            creators: state.creatorIdentity.map { [$0] } ?? [],
            offset: offset,
            limit: limit
        )

        // The page-size contract counts raw results - messageless ones drop after
        let filtered = results.filter(\.hasMessage)
        try await resolveContainers(ids: filtered.map(\.chatID))

        guard requestState == state else { return }
        canLoadMore = results.count >= limit

        rows = []
        lastCrossSpaceRecords = nil
        if offset > 0, let existing = lastMessageResults {
            let existingIds = Set(existing.map(\.messageID))
            lastMessageResults = existing + filtered.filter { !existingIds.contains($0.messageID) }
        } else {
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
        messageRows = results.map { result in
            buildMessageRow(result, spaceCaption: showSpaceCaption ? spaceCaption(spaceId: result.spaceID) : nil)
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
        var unresolved = Set(ids).filter { containersById[$0] == nil }
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
        }
    }

    private func buildMessageRow(_ result: ChatMessageSearchResult, spaceCaption: SearchSpaceCaption?) -> UnifiedSearchMessageRow {
        let message = result.message
        let participant = allParticipants.first { $0.identity == message.creator && $0.spaceId == result.spaceID }
            ?? allParticipants.first { $0.identity == message.creator }

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
                    icon: participant.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder)),
                    sharedChannelCount: sharedSpaceIds.count,
                    hasOneToOne: oneToOneSpaceId != nil
                )
            }
    }

    private func activeSpaceIdsByIdentity() -> [String: Set<String>] {
        var result = [String: Set<String>]()
        for participant in allParticipants where participant.status == .active {
            result[participant.identity, default: []].insert(participant.spaceId)
        }
        return result
    }

    func onSelectPersonRow(_ row: UnifiedSearchPersonRow) {
        AnytypeAnalytics.instance().logSearchResult()
        moduleData.onSelect(.alert(.spaceMember(ObjectInfo(objectId: row.participantObjectId, spaceId: row.spaceId))))
    }

    func onDrillPersonRow(_ row: UnifiedSearchPersonRow) {
        UISelectionFeedbackGenerator().selectionChanged()
        // A drill is about the drilled person - the old query found the row,
        // the new search starts clean
        state.searchText = ""
        addPickedToken(.creator(identity: row.identity), source: .row)
    }

    private func matchingSpaceRows(limit: Int?) -> [UnifiedSearchChannelRow] {
        var spaceViews = orderedSpaceViews
        if state.searchText.isNotEmpty {
            spaceViews = spaceViews.filter { $0.title.localizedStandardContains(state.searchText) }
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

    // Rows arrive date-sorted, so day grouping is an order-preserving pass
    private func updateRowSections() {
        guard rows.isNotEmpty else {
            rowSections = []
            return
        }
        guard state.searchText.isEmpty else {
            rowSections = [ListSectionData(id: "single_section", data: nil, rows: rows)]
            return
        }
        let today = Date()
        let grouped = OrderedDictionary(
            grouping: rows,
            by: { browseDateFormatter.localizedString(for: $0.lastModifiedDate ?? today, relativeTo: today) }
        )
        rowSections = grouped.map { (title, rows) in
            ListSectionData(id: title, data: title, rows: rows)
        }
    }

    // MARK: - Chips

    // The row shows only tokens that could still be added: a filled group's
    // chips disappear and return when its token is removed
    private func rebuildChips() {
        var result = [UnifiedSearchChipModel]()
        let scopeId = state.spaceScopeId
        let whatFilled = state.whatBucket != nil || state.typeUniqueKey != nil

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
        let scopeHasChats = scopeId.map { id in allChats.contains { $0.spaceId == id } } ?? allChats.isNotEmpty
        if !whatFilled, scopeHasChats {
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
                for bucket in [UnifiedSearchKindBucket.pages, .bookmarks, .collections, .queries] {
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
    // and system types excluded.
    private func typesBrowseList(scopeSpaceId: String?) -> [ObjectDetails] {
        let representativeSpaceId = scopeSpaceId ?? moduleData.currentSpaceId
        var byUniqueKey = [String: ObjectDetails]()
        for type in typesById.values {
            guard !type.isHidden, !Constants.excludedTypeChipKeys.contains(type.uniqueKeyValue) else { continue }
            if let scopeSpaceId, type.spaceId != scopeSpaceId { continue }
            if let existing = byUniqueKey[type.uniqueKey] {
                if type.spaceId == representativeSpaceId, existing.spaceId != representativeSpaceId {
                    byUniqueKey[type.uniqueKey] = type
                }
            } else {
                byUniqueKey[type.uniqueKey] = type
            }
        }
        return byUniqueKey.values.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    // "By me" leads the row, member chips close it (desktop order). The >1-member
    // gate covers the whole person section - filtering a solo space by "you" is a no-op.
    private func personChips(scopeSpaceId: String?, byMeOnly: Bool) -> [UnifiedSearchChipModel] {
        guard state.creatorIdentity == nil, let ownIdentity else { return [] }

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
                // An unresolvable scope (left space, ...) is dropped silently below
                guard let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId) else { return nil }
                return UnifiedSearchTokenViewModel(token: token, title: spaceView.title, icon: spaceView.objectIconImage)
            case .kind(let bucket):
                let icon: Icon? = bucket == .messages ? .asset(ImageAsset.CustomIcons.chatbubble) : nil
                return UnifiedSearchTokenViewModel(token: token, title: bucket.title, icon: icon)
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
        unifiedSearchStateService.storeState(state)
    }
}

private extension UnifiedSearchToken {
    var analyticsType: SearchTokenType {
        switch self {
        case .space: .space
        case .kind: .kind
        case .type: .type
        case .creator: .creator
        }
    }
}
