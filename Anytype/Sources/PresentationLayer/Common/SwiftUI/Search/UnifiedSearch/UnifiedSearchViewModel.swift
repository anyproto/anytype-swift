import Services
import Foundation
import AnytypeCore
import SwiftUI
import UIKit

@MainActor
@Observable
final class UnifiedSearchViewModel {

    private enum Constants {
        static let browseLimit = 20
        static let searchLimit = 100
        static let channelRowsLimit = 3
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
    private let moduleData: UnifiedSearchModuleData
    @ObservationIgnored
    private let messageDateFormatter = HistoryDateFormatter()

    var state = UnifiedSearchState()
    var tokenModels = [UnifiedSearchTokenViewModel]()
    var chips = [UnifiedSearchChipModel]()
    var channelRows = [UnifiedSearchChannelRow]()
    var rows = [SearchWithMetaModel]()
    var messageRows = [UnifiedSearchMessageRow]()
    var selectedTokenId: String?
    var showPeoplePicker = false
    var isInitial = true

    private var participantCanEdit = false
    @ObservationIgnored
    private var typesById = [String: ObjectDetails]()
    @ObservationIgnored
    private var allParticipants = [Participant]()
    @ObservationIgnored
    private var allChats = [ObjectDetails]()
    // Resolved message containers (chats + thread-parent pages), accumulated
    @ObservationIgnored
    private var containersById = [String: ObjectDetails]()
    @ObservationIgnored
    private var lastCrossSpaceRecords: [ObjectDetails]?
    @ObservationIgnored
    private var lastMessageResults: [ChatMessageSearchResult]?
    @ObservationIgnored
    private var skipDebounceOnce = true

    var isGlobal: Bool { state.spaceScopeId == nil }
    var animatesBarExpansion: Bool { moduleData.animatesBarExpansion }

    func onCancel() {
        // Resign with the tap so the keyboard drops together with the overlay,
        // not after it (the field only resigns on window removal otherwise)
        UIApplication.shared.hideKeyboard()
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
            // Author names/avatars on message rows resolve from participants
            rebuildMessageRows()
        }
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
        moduleData.onOpenMessage(row.chatObjectId, row.spaceId, row.messageId)
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
        }
    }

    var peoplePickerRows: [UnifiedSearchPersonRow] {
        personBrowseList(scopeSpaceId: state.spaceScopeId)
            .filter { $0.identity != ownIdentity }
            .map { UnifiedSearchPersonRow(identity: $0.identity, title: $0.title, icon: $0.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))) }
    }

    func onSelectPerson(_ person: UnifiedSearchPersonRow) {
        let token = UnifiedSearchToken.creator(identity: person.identity)
        logToken(token, action: replacesInGroup(token) ? .replace : .add, source: .chip)
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

    private func searchInCurrentSpace(spaceId: String) async throws {
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
            excludedObjectIds: []
        )

        lastCrossSpaceRecords = nil
        messageRows = []
        lastMessageResults = nil
        rows = results.map {
            searchWithMetaModelBuilder.buildModel(with: $0, spaceId: spaceId, participantCanEdit: participantCanEdit)
        }
    }

    private func searchCrossSpace(spaceId: String?) async throws {
        let browse = state.searchText.isEmpty

        // Type objects are noise in the generic empty browse only - with a what
        // token or a text query they are legitimate results
        var excludedLayouts = creatorChatExclusion()
        if browse, state.whatBucket == nil, state.typeUniqueKey == nil {
            excludedLayouts.append(.objectType)
        }

        // allStoresLoaded == false right after app start - render the partial
        // result as is, every keystroke re-queries and self-heals. No retry loop.
        let result = try await crossSpaceSearchService.search(
            text: state.searchText,
            layouts: state.whatBucket?.layouts ?? [],
            excludedLayouts: excludedLayouts,
            typeUniqueKey: state.typeUniqueKey,
            creators: creatorFilterIds(scopeSpaceId: spaceId),
            spaceId: spaceId,
            offset: 0,
            limit: browse ? Constants.browseLimit : Constants.searchLimit
        )

        lastCrossSpaceRecords = result.records
        messageRows = []
        lastMessageResults = nil
        rebuildCrossSpaceRows()
    }

    // Message search covers all chats and discussion threads at once: empty
    // chatObjectId = all chats in the space, empty spaceId too = all spaces.
    // Always newest-first - relevance order groups hits per chat and reads as
    // arbitrary (the client overrides the backend's score-first default).
    private func searchMessages(spaceId: String?) async throws {
        let results = try await chatService.searchMessages(
            spaceId: spaceId ?? "",
            chatObjectId: "",
            query: state.searchText,
            sorts: [ChatMessageSearchSort.with { $0.key = .createdAt; $0.type = .desc }],
            creators: state.creatorIdentity.map { [$0] } ?? [],
            offset: 0,
            limit: state.searchText.isEmpty ? Constants.browseLimit : Constants.searchLimit
        ).filter(\.hasMessage)

        try await resolveContainers(ids: results.map(\.chatID))

        rows = []
        lastCrossSpaceRecords = nil
        lastMessageResults = results
        rebuildMessageRows()
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

    // Chats come from the vault-wide storage; thread-parent pages are batch-fetched
    // once per result page. Unresolvable containers degrade to no caption.
    private func resolveContainers(ids: [String]) async throws {
        for chat in allChats {
            containersById[chat.id] = chat
        }
        let unresolved = Set(ids).filter { containersById[$0] == nil }
        guard unresolved.isNotEmpty else { return }
        let fetched = (try? await crossSpaceSearchService.objects(ids: Array(unresolved))) ?? []
        for details in fetched {
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
            snippet = AttributedString(messageTextBuilder.makeMessaeWithoutStyle(content: message.message))
        }

        return UnifiedSearchMessageRow(
            messageId: message.id,
            chatObjectId: result.chatID,
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

    // MARK: - Channels

    private func updateChannelRows() {
        if isGlobal, state.whatBucket == .channels {
            // Bucket browse: the whole space list, filtered by the query
            channelRows = matchingSpaceRows(limit: nil)
        } else if isGlobal, state.searchText.isNotEmpty, state.whatBucket == nil, state.typeUniqueKey == nil {
            // Plain text query: up to 3 channel-name matches lead the results
            channelRows = matchingSpaceRows(limit: Constants.channelRowsLimit)
        } else {
            channelRows = []
        }
    }

    private func matchingSpaceRows(limit: Int?) -> [UnifiedSearchChannelRow] {
        var spaceViews = spaceViewsStorage.allSpaceViews
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
            if let scopeId {
                result.append(UnifiedSearchChipModel(token: .kind(.media), title: UnifiedSearchKindBucket.media.title))
                result.append(contentsOf: typeChips(spaceId: scopeId))
            } else {
                for bucket in [UnifiedSearchKindBucket.media, .pages, .bookmarks, .collections, .queries] {
                    result.append(UnifiedSearchChipModel(token: .kind(bucket), title: bucket.title))
                }
            }
        }

        result.append(contentsOf: personChips(scopeSpaceId: scopeId, byMeOnly: false))

        chips = result
    }

    private func typeChips(spaceId: String) -> [UnifiedSearchChipModel] {
        typesById.values
            .filter { $0.spaceId == spaceId && !$0.isHidden && !Constants.excludedTypeChipKeys.contains($0.uniqueKeyValue) }
            .sorted { $0.title < $1.title }
            .prefix(Constants.typeChipsLimit)
            .map { UnifiedSearchChipModel(token: .type(uniqueKey: $0.uniqueKey), title: $0.title) }
    }

    // "By me" leads the row, member chips close it (desktop order). The >1-member
    // gate covers the whole person section - filtering a solo space by "you" is a no-op.
    private func personChips(scopeSpaceId: String?, byMeOnly: Bool) -> [UnifiedSearchChipModel] {
        guard state.creatorIdentity == nil, let ownIdentity else { return [] }

        let people = personBrowseList(scopeSpaceId: scopeSpaceId)
        guard people.count > 1 else { return [] }

        if byMeOnly {
            let own = people.first { $0.identity == ownIdentity }
            return [UnifiedSearchChipModel(
                token: .creator(identity: ownIdentity),
                title: Loc.UnifiedSearch.Chip.byMe,
                icon: own?.icon.map { Icon.object($0) }
            )]
        }

        var members = people
            .filter { $0.identity != ownIdentity }
            .prefix(Constants.memberChipsLimit)
            .map { participant in
                UnifiedSearchChipModel(
                    token: .creator(identity: participant.identity),
                    title: Loc.UnifiedSearch.Chip.by(participant.title),
                    icon: participant.icon.map { Icon.object($0) } ?? .object(.profile(.placeholder))
                )
            }
        // The full browse behind the inline cap
        if people.count - 1 > Constants.memberChipsLimit {
            members.append(UnifiedSearchChipModel(
                action: .openPeoplePicker,
                title: Loc.UnifiedSearch.Chip.people,
                icon: .asset(ImageAsset.CustomIcons.people)
            ))
        }
        return Array(members)
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
        for spaceView in spaceViewsStorage.allSpaceViews where spaceView.isOneToOne {
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
                if identity == ownIdentity {
                    return UnifiedSearchTokenViewModel(token: token, title: Loc.UnifiedSearch.Chip.byMe, icon: nil)
                }
                let participant = allParticipants.first { $0.identity == identity }
                let title = participant.map { Loc.UnifiedSearch.Chip.by($0.title) } ?? "…"
                return UnifiedSearchTokenViewModel(token: token, title: title, icon: participant?.icon.map { Icon.object($0) })
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
