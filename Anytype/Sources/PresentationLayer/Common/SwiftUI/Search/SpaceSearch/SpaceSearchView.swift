import Foundation
import SwiftUI

struct SpaceSearchView: View {
    
    @StateObject private var model: SpaceSearchViewModel
    
    init(data: SpaceSearchData) {
        self._model = StateObject(wrappedValue: SpaceSearchViewModel(data: data))
    }
    
    var body: some View {
        SearchView(
            title: Loc.Spaces.Search.title,
            placeholder: Loc.Spaces.Search.title,
            searchData: model.searchData,
            emptyViewMode: .object,
            search:  { text in
                model.search(text: text)
            },
            onSelect: { data in
                model.onSelect(searchData: data)
            }
        )
        .task {
            await model.startParticipantTask()
        }
    }
}
