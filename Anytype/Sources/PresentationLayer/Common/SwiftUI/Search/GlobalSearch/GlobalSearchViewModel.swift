import Services
import Combine
import Foundation
import OrderedCollections
import AnytypeCore
import UIKit

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @Injected(\.searchWithMetaModelBuilder)
    private var searchWithMetaModelBuilder: any SearchWithMetaModelBuilderProtocol
    @Injected(\.globalSearchSavedStatesService)
    private var globalSearchSavedStatesService: any GlobalSearchSavedStatesServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    
    private let moduleData: GlobalSearchModuleData
    
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    @Published var state = GlobalSearchState()
    @Published var sections = [ListSectionData<String?, SearchWithMetaModel>]()
    @Published var dismiss = false
    @Published private var participantCanEdit = false
    
    private var searchResult = [SearchResultWithMeta]()
    private var sectionChanged = false
    var isInitial = true
    
    init(data: GlobalSearchModuleData) {
        self.moduleData = data
        self.restoreState()
    }
    
    func startParticipantTask() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: moduleData.spaceId).values {
            participantCanEdit = participant.canEdit
            updateSections()
        }
    }
    
    func search() async {
        do {
            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            searchResult = try await searchWithMetaService.search(
                text: state.searchText,
                spaceId: moduleData.spaceId,
                layouts: buildLayouts(),
                sorts: buildSorts(),
                excludedObjectIds: []
            )
            
            updateInitialStateIfNeeded()
            updateSections()
            storeState()
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            sections = []
        }
    }
    
    func onSectionChanged(_ section: ObjectTypeSection) {
        sectionChanged = true
        state.section = section
        AnytypeAnalytics.instance().logChangeLibraryType(type: section.analyticsValue)
    }
    
    func onSearchTextChanged() {
        AnytypeAnalytics.instance().logSearchInput(spaceId: moduleData.spaceId)
    }
    
    func onKeyboardButtonTap() {
        guard let firstObject = sections.first?.rows.first else { return }
        onSelect(searchData: firstObject)
    }
    
    func onSelect(searchData: SearchWithMetaModel) {
        AnytypeAnalytics.instance().logSearchResult(spaceId: moduleData.spaceId, objectType: state.section.analyticsValue)
        dismiss.toggle()
        moduleData.onSelect(searchData.editorScreenData)
    }
    
    func onRemove(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func updateSections() {
        guard searchResult.isNotEmpty else {
            sections = []
            return
        }
        
        guard state.shouldGroupResults else {
            sections = [listSectionData(title: nil, result: searchResult)]
            return
        }
        
        let today = Date()
        let dict = OrderedDictionary(
            grouping: searchResult,
            by: { dateFormatter.localizedString(for: sortValue(for: $0.objectDetails) ?? today, relativeTo: today) }
        )
        
        sections = dict.map { (key, result) in
            listSectionData(title: key, result: result)
        }
    }
    
    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
    
    private func needDelay() -> Bool {
        guard sectionChanged || isInitial else { return true }
        sectionChanged = false
        return false
    }
    
    private func restoreState() {
        let restoredState = globalSearchSavedStatesService.restoreState(for: moduleData.spaceId)
        guard let restoredState else {
            AnytypeAnalytics.instance().logScreenSearch(spaceId: moduleData.spaceId, type: .empty)
            return
        }
        state = restoredState
        if restoredState.searchText.isNotEmpty {
            AnytypeAnalytics.instance().logScreenSearch(spaceId: moduleData.spaceId, type: .saved)
        }
    }
    
    private func storeState() {
        globalSearchSavedStatesService.storeState(state, spaceId: moduleData.spaceId)
    }
    
    private func listSectionData(title: String?, result: [SearchResultWithMeta]) -> ListSectionData<String?, SearchWithMetaModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: result.compactMap { result in
                searchWithMetaModelBuilder.buildModel(
                    with: result,
                    spaceId: moduleData.spaceId,
                    participantCanEdit: participantCanEdit
                )
            }
        )
    }
    
    private func buildLayouts() -> [DetailsLayout] {
        .builder {
            if state.searchText.isEmpty {
                state.section.supportedLayouts.filter { $0 != .participant }
            } else {
                state.section.supportedLayouts
            }
        }
    }
    
    private func buildSorts() -> [DataviewSort] {
        .builder {
            if state.searchText.isEmpty {
                state.sort.asDataviewSort()
            } else {
                SearchHelper.sort(
                    relation: BundledPropertyKey.lastOpenedDate,
                    type: .desc
                )
            }
        }
    }
    
    private func sortValue(for details: ObjectDetails) -> Date? {
        switch state.sort.relation {
        case .dateUpdated:
            return details.lastModifiedDate
        case .dateCreated:
            return details.createdDate
        case .name:
            return nil
        }
    }
}
