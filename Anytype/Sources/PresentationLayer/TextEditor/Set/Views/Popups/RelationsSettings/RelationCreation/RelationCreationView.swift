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
        SearchView(title: Loc.addProperty, placeholder: Loc.searchOrCreateNew, searchData: model.rows, emptyViewMode: .property) { searchText in
            await model.search(text: searchText)
        } onSelect: { selectedItem in
            model.onRelationTap(selectedItem)
        }
    }

}
