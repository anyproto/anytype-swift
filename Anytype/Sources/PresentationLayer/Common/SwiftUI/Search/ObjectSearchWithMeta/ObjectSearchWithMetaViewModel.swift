import Services
import Combine
import Foundation
import OrderedCollections
import AnytypeCore

struct ObjectSearchWithMetaModuleData: Identifiable, Hashable {
    let spaceId: String
    let title: String
    let section: ObjectTypeSection
    let excludedObjectIds: [String]
    @EquatableNoop var onSelect: (ObjectDetails) -> Void
    
    var id: Int { hashValue }
}

@MainActor
final class ObjectSearchWithMetaViewModel: ObservableObject {
    
    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @Injected(\.searchWithMetaModelBuilder)
    private var searchWithMetaModelBuilder: any SearchWithMetaModelBuilderProtocol
    
    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    
    @Published var searchText = ""
    @Published var sections = [ListSectionData<String?, SearchWithMetaModel>]()
    @Published var dismiss = false
    
    private var searchResult = [SearchResultWithMeta]()
    
    let moduleData: ObjectSearchWithMetaModuleData
    var isInitial = true
    
    init(data: ObjectSearchWithMetaModuleData) {
        self.moduleData = data
    }
    
    func search() async {
        do {
            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            searchResult = try await searchWithMetaService.search(
                text: searchText,
                spaceId: moduleData.spaceId,
                layouts: moduleData.section.supportedLayouts,
                sorts: buildSorts(),
                excludedObjectIds: moduleData.excludedObjectIds
            )
            
            updateInitialStateIfNeeded()
            updateSections()
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            sections = []
        }
        
        AnytypeAnalytics.instance().logSearchInput(spaceId: moduleData.spaceId)
    }
    
    func onSelect(searchData: SearchWithMetaModel) {
        guard let details = searchResult.first(where: { $0.objectDetails.id == searchData.id} )?.objectDetails else {
            return
        }
        dismiss.toggle()
        moduleData.onSelect(details)
    }
    
    private func updateSections() {
        guard searchResult.isNotEmpty else {
            sections = []
            return
        }
        
        let today = Date()
        let dict = OrderedDictionary(
            grouping: searchResult,
            by: { dateFormatter.localizedString(for: $0.objectDetails.lastOpenedDate ?? today, relativeTo: today) }
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
        !isInitial
    }
    
    private func listSectionData(title: String?, result: [SearchResultWithMeta]) -> ListSectionData<String?, SearchWithMetaModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: result.compactMap { result in
                searchWithMetaModelBuilder.buildModel(
                    with: result,
                    spaceId: moduleData.spaceId,
                    participantCanEdit: false
                )
            }
        )
    }
    
    private func buildSorts() -> [DataviewSort] {
        .builder {
            SearchHelper.sort(
                relation: BundledRelationKey.lastOpenedDate,
                type: .desc
            )
        }
    }
}
