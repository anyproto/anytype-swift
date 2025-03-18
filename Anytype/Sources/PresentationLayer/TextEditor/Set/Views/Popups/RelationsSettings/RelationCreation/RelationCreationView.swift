import SwiftUI

struct RelationCreationView: View {
    @StateObject private var model: RelationCreationViewModel
    
    init(data: RelationsSearchData) {
        _model = StateObject(wrappedValue: RelationCreationViewModel(data: data))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
    }
    
    private var content: some View {
        SearchView(title: Loc.addProperty, placeholder: Loc.searchOrCreateNew, searchData: model.rows) { searchText in
            print(searchText)
        } onSelect: { selectedItem in
            print(selectedItem)
        }
    }

}
