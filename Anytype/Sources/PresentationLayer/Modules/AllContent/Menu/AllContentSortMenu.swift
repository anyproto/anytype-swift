import SwiftUI
import Services

struct AllContentSortMenu: View {
    @Binding var sort: AllContentSort
    
    @State private var sortRelation: AllContentSort.Relation
    @State private var sortType: DataviewSort.TypeEnum
    
    init(sort: Binding<AllContentSort>) {
        _sort = sort
        sortRelation = sort.wrappedValue.relation
        sortType = sort.wrappedValue.type
    }
    
    var body: some View {
        content
            .onChange(of: sortRelation) { newValue in
                sort = AllContentSort(relation: newValue)
                sortType = sort.type
            }
            .onChange(of: sortType) { newValue in
                sort = AllContentSort(relation: sort.relation, type: newValue)
            }
    }
    
    private var content: some View {
        Menu {
            sortRelationView
            Divider()
            sortTypeView
        } label: {
            AnytypeText(Loc.AllContent.Settings.Sort.title, style: .uxTitle2Medium)
                .foregroundColor(.Control.button)
            Text(sort.relation.title)
        }
        .menuActionDisableDismissBehavior()
    }
    
    private var sortRelationView: some View {
        Picker("", selection: $sortRelation) {
            ForEach(AllContentSort.Relation.allCases, id: \.self) { sortRelation in
                AnytypeText(sortRelation.title, style: .uxTitle2Medium)
                    .foregroundColor(.Control.button)
            }
        }
    }
    
    private var sortTypeView: some View {
        Picker("", selection: $sortType) {
            ForEach(sort.relation.availableSortTypes, id: \.self) { type in
                AnytypeText(sort.relation.titleFor(sortType: type), style: .uxTitle2Medium)
                    .foregroundColor(.Control.button)
            }
        }
    }
}
