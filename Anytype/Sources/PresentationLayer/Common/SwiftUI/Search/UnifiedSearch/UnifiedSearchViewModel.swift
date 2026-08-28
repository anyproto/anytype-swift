import Services
import Foundation
import AnytypeCore
import UIKit

@MainActor
@Observable
final class UnifiedSearchViewModel {

    private enum Constants {
        static let browseLimit = 20
        static let searchLimit = 100
        static let channelRowsLimit = 3
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
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol

    @ObservationIgnored
    private let moduleData: UnifiedSearchModuleData

    var state = UnifiedSearchState()
    var tokenModels = [UnifiedSearchTokenViewModel]()
    var channelRows = [UnifiedSearchChannelRow]()
    var rows = [SearchWithMetaModel]()
    var dismiss = false
    var isInitial = true

    private var participantCanEdit = false
    @ObservationIgnored
    private var typesById = [String: ObjectDetails]()
    @ObservationIgnored
    private var lastCrossSpaceRecords: [ObjectDetails]?
    @ObservationIgnored
    private var skipDebounceOnce = true

    var isGlobal: Bool { state.spaceScopeId == nil }

    init(data: UnifiedSearchModuleData) {
        self.moduleData = data
        self.restoreState()
        // The entry point always overrides the scope slot on open
        self.state.setSpaceScope(data.currentSpaceId)
        self.updateTokenModels()
    }

    func startTypesSubscription() async {
        // One vault-wide types subscription resolves type captions for cross-space
        // rows - never per-space or per-row fetches
        await crossSpaceTypesStorage.startSubscription()
        for await types in await crossSpaceTypesStorage.allTypesSequence {
            typesById = Dictionary(types.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            rebuildCrossSpaceRows()
        }
        Task { await crossSpaceTypesStorage.stopSubscription() }
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

            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            if let scopeId = state.spaceScopeId, scopeId == moduleData.currentSpaceId {
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
        }
    }

    func onSearchTextChanged() {
        AnytypeAnalytics.instance().logSearchInput()
    }

    func onKeyboardButtonTap() {
        guard let firstRow = rows.first else { return }
        onSelect(searchData: firstRow)
    }

    func onSelect(searchData: SearchWithMetaModel) {
        AnytypeAnalytics.instance().logSearchResult()
        dismiss.toggle()
        moduleData.onSelect(searchData.editorScreenData)
    }

    func onSelectChannel(_ row: UnifiedSearchChannelRow) {
        AnytypeAnalytics.instance().logSearchResult()
        dismiss.toggle()
        moduleData.onOpenSpace(row.spaceId)
    }

    func onScopeToSpace(_ spaceId: String) {
        UISelectionFeedbackGenerator().selectionChanged()
        skipDebounceOnce = true
        state.setSpaceScope(spaceId)
        updateTokenModels()
    }

    func onRemoveToken(_ token: UnifiedSearchToken) {
        UISelectionFeedbackGenerator().selectionChanged()
        skipDebounceOnce = true
        state.removeToken(token)
        updateTokenModels()
    }

    func onRemove(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }

        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - Loaders

    private func searchInCurrentSpace(spaceId: String) async throws {
        let spaceType = spaceViewsStorage.spaceView(spaceId: spaceId)?.spaceType
        let layouts = ObjectTypeSection.all.supportedLayouts(spaceType: spaceType)
            .filter { state.searchText.isEmpty ? $0 != .participant : true }

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
            sorts: sorts,
            excludedObjectIds: []
        )

        lastCrossSpaceRecords = nil
        rows = results.map {
            searchWithMetaModelBuilder.buildModel(with: $0, spaceId: spaceId, participantCanEdit: participantCanEdit)
        }
    }

    private func searchCrossSpace(spaceId: String?) async throws {
        let browse = state.searchText.isEmpty

        // allStoresLoaded == false right after app start - render the partial
        // result as is, every keystroke re-queries and self-heals. No retry loop.
        let result = try await crossSpaceSearchService.search(
            text: state.searchText,
            layouts: [],
            excludedLayouts: browse ? [.objectType, .participant] : [.participant],
            spaceId: spaceId,
            offset: 0,
            limit: browse ? Constants.browseLimit : Constants.searchLimit
        )

        lastCrossSpaceRecords = result.records
        rebuildCrossSpaceRows()
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

    // MARK: - Channels

    private func updateChannelRows() {
        guard isGlobal, state.searchText.isNotEmpty else {
            channelRows = []
            return
        }

        channelRows = spaceViewsStorage.allSpaceViews
            .filter { $0.title.localizedStandardContains(state.searchText) }
            .prefix(Constants.channelRowsLimit)
            .map { UnifiedSearchChannelRow(spaceId: $0.targetSpaceId, title: $0.title, icon: $0.objectIconImage) }
    }

    private func spaceCaption(spaceId: String) -> SearchSpaceCaption? {
        guard let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId) else { return nil }
        return SearchSpaceCaption(spaceId: spaceId, name: spaceView.title)
    }

    // MARK: - State

    private func updateTokenModels() {
        tokenModels = state.tokens.compactMap { token in
            switch token {
            case .space(let spaceId):
                guard let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId) else { return nil }
                return UnifiedSearchTokenViewModel(token: token, title: spaceView.title, icon: spaceView.objectIconImage)
            }
        }
        // An unresolvable token (left space, ...) is dropped silently
        let resolvedTokens = tokenModels.map(\.token)
        if resolvedTokens != state.tokens {
            state.tokens = resolvedTokens
        }
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
