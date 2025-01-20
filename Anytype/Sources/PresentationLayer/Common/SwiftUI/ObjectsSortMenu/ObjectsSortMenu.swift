import SwiftUI
import Services

struct ObjectsSortMenu<Label> : View where Label : View {
    
    private let label: Label
    
    @Binding var sort: ObjectSort
    
    @State private var sortRelation: ObjectSortRelation
    @State private var sortType: DataviewSort.TypeEnum
    
    init(
        sort: Binding<ObjectSort>,
        @ViewBuilder label: () -> Label
    ) {
        _sort = sort
        sortRelation = sort.wrappedValue.relation
        sortType = sort.wrappedValue.type
        self.label = label()
    }
    
    var body: some View {
        Menu {
            sortRelationView
            Divider()
            sortTypeView
        } label: {
            label
        }
        .menuOrder(.fixed)
    }
    
    private var sortRelationView: some View {
        Picker("", selection: $sortRelation) {
            ForEach(ObjectSortRelation.allCases, id: \.self) { sortRelation in
                AnytypeText(sortRelation.title, style: .uxTitle2Medium)
                    .foregroundColor(.Control.button)
            }
        }
        .onChange(of: sortRelation) { newValue in
            sort = ObjectSort(relation: newValue)
            sortType = sort.type
        }
    }
    
    private var sortTypeView: some View {
        Picker("", selection: $sortType) {
            ForEach(sortRelation.availableSortTypes, id: \.self) { type in
                AnytypeText(sortRelation.titleFor(sortType: type), style: .uxTitle2Medium)
                    .foregroundColor(.Control.button)
            }
        }
        .onChange(of: sortType) { newValue in
            sort = ObjectSort(relation: sort.relation, type: newValue)
        }
    }
}
