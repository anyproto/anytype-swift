import SwiftUI
import Services
import Combine

/// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Mobile---main?node-id=6455%3A4097
@MainActor
final class ObjectSearchViewModel: ObservableObject {
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    private let data: ObjectSearchModuleData
    
    @Published var searchData: [SearchDataSection<ObjectSearchData>] = []
    var title: String? { data.title }
    
    init(data: ObjectSearchModuleData) {
        self.data = data
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSearch(spaceId: data.spaceId, type: .empty)
    }
    
    func onSelect(searchData: ObjectSearchData) {
        AnytypeAnalytics.instance().logSearchResult(spaceId: data.spaceId)
        data.onSelect(searchData)
    }
    
    func search(text: String) async {
        do {
            let result: [ObjectDetails]
            
            if data.layoutLimits.isNotEmpty {
                result = try await searchService.searchObjectsWithLayouts(text: text, layouts: data.layoutLimits, excludedIds: [], spaceId: data.spaceId)
            } else {
                result = try await searchService.search(text: text, spaceId: data.spaceId)
            }
            
            let objectsSearchData = result.compactMap { ObjectSearchData(details: $0) }
            
            guard objectsSearchData.isNotEmpty else {
                searchData = []
                return
            }
            
            searchData = [SearchDataSection(searchData: objectsSearchData, sectionName: "")]
            
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            searchData = []
        }
    }
}
