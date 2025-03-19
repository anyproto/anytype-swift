import Foundation
import SwiftUI

struct ObjectSearchView: View {
    
    @StateObject private var model: ObjectSearchViewModel
    
    init(data: ObjectSearchModuleData) {
        self._model = StateObject(wrappedValue: ObjectSearchViewModel(data: data))
    }
    
    var body: some View {
        SearchView(
            title: model.title,
            placeholder: Loc.search,
            searchData: model.searchData,
            emptyViewMode: .object,
            search:  { text in
                await model.search(text: text)
            },
            onSelect: { data in
                model.onSelect(searchData: data)
            }
        )
        .onAppear {
            model.onAppear()
        }
    }
}
