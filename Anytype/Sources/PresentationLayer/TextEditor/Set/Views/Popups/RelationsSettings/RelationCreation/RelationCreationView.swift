import SwiftUI

struct RelationCreationView: View {
    @StateObject private var model: RelationCreationViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: RelationsSearchData) {
        _model = StateObject(wrappedValue: RelationCreationViewModel(data: data))
    }
    
    var body: some View {
        content
            .onAppear { model.dismiss = dismiss }
            .sheet(item: $model.newRelationData) {
                RelationInfoCoordinatorView(data: $0, output: model)
                    .mediumPresentationDetents()
            }
    }
    
    private var content: some View {
        SearchView(title: Loc.addProperty, placeholder: Loc.searchOrCreateNew, searchData: model.rows, emptyViewMode: .property, dismissOnSelect: false) { searchText in
            await model.search(text: searchText)
        } onSelect: { selectedItem in
            model.onRowTap(selectedItem)
        }
    }

}
