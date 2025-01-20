import Foundation
import Services
import OrderedCollections
import UIKit

@MainActor
protocol AllContentModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
}

@MainActor
final class AllContentViewModel: ObservableObject {
    
    private var details = [ObjectDetails]()
    private var objectsToLoad = 0
    var firstOpen = true
    
    @Published var sections = [ListSectionData<String?, WidgetObjectListRowModel>]()
    @Published var state = AllContentState()
    @Published var searchText = ""
    @Published private var participantCanEdit = false
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.allContentStateStorageService)
    private var allContentStateStorageService: any AllContentStateStorageServiceProtocol
    
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    private let spaceId: String
    private weak var output: (any AllContentModuleOutput)?
    
    init(spaceId: String, output: (any AllContentModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.restoreSort()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenLibrary()
    }
    
    func startParticipantTask() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: spaceId).values {
            participantCanEdit = participant.canEdit
            updateRows()
        }
    }
    
    func restartSubscription() async {
        await allContentSubscriptionService.startSubscription(
            spaceId: spaceId,
            section: state.section,
            sort: state.sort,
            onlyUnlinked: state.mode == .unlinked,
            limitedObjectsIds: state.limitedObjectsIds,
            limit: state.limit,
            update: { [weak self] details, objectsToLoad in
                self?.updateFirstOpenIfNeeded()
                self?.details = details
                self?.objectsToLoad = objectsToLoad
                self?.updateRows()
            }
        )
    }
    
    func search() async {
        do {
            guard searchText.isNotEmpty else {
                state.limitedObjectsIds = nil
                return
            }
            
            try await Task.sleep(seconds: 0.3)
            
            state.limitedObjectsIds = try await searchService.searchAll(text: searchText, spaceId: spaceId).map { $0.id }
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            state.limitedObjectsIds = nil
        }
        
        AnytypeAnalytics.instance().logSearchInput(spaceId: spaceId, route: .library)
    }
    
    func sectionChanged(_ section: ObjectTypeSection) {
        state.section = section
        AnytypeAnalytics.instance().logChangeLibraryType(type: section.analyticsValue)
    }
    
    func binTapped() {
        output?.onObjectSelected(screenData: .editor(.bin(spaceId: spaceId)))
    }
    
    func onDisappear() {
        stopSubscription()
    }
    
    func onAppearLastRow(_ id: String) {
        guard objectsToLoad > 0, details.last?.id == id else { return }
        objectsToLoad = 0
        state.updateLimit()
    }
    
    func onDelete(objectId: String) {
        setArchive(objectId: objectId)
    }
    
    func onChangeSort() {
        storeSort()
        AnytypeAnalytics.instance().logChangeLibrarySort(
            type: state.sort.relation.analyticsValue,
            sort: state.sort.type.analyticValue
        )
    }
    
    func onChangeMode() {
        AnytypeAnalytics.instance().logChangeLibraryTypeLink(type: state.mode.analyticsValue)
    }
    
    private func setArchive(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    private func stopSubscription() {
        Task {
            await allContentSubscriptionService.stopSubscription()
        }
    }
    
    private func updateRows() {
        guard state.sort.relation.canGroupByDate else  {
            sections = [listSectionData(title: nil, details: details)]
            return
        }
        
        let today = Date()
        let dict = OrderedDictionary(
            grouping: details,
            by: { dateFormatter.localizedString(for: sortValue(for: $0) ?? today, relativeTo: today) }
        )
        
        if dict.count == 1 {
            sections = [listSectionData(title: nil, details: details)]
        } else {
            sections = dict.map { (key, details) in
                listSectionData(title: key, details: details)
            }
        }
    }
    
    private func listSectionData(title: String?, details: [ObjectDetails]) -> ListSectionData<String?, WidgetObjectListRowModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: details.map { details in
                WidgetObjectListRowModel(
                    details: details,
                    canArchive: details.permissions(participantCanEdit: participantCanEdit).canArchive,
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: details.screenData())
                        AnytypeAnalytics.instance().logLibraryResult()
                    }
                )
            }
        )
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
    
    private func updateFirstOpenIfNeeded() {
        guard firstOpen else { return }
        firstOpen = false
    }
    
    // MARK: - Save states
    
    private func storeSort() {
        allContentStateStorageService.storeSort(state.sort, spaceId: spaceId)
    }
    
    private func restoreSort() {
        guard let sort = allContentStateStorageService.restoreSort(for: spaceId) else { return }
        state.sort = sort
    }
}
