import SwiftUI
import Services

struct AllContentSettingsMenu: View {
    @Binding var state: AllContentState
    let binTapped: () -> Void
    
    @State private var relation: AllContentSort.Relation
    
    init(state: Binding<AllContentState>, binTapped: @escaping () -> Void) {
        self._state = state
        self.binTapped = binTapped
        self.relation = state.wrappedValue.sort.relation
    }
    
    var body: some View {
        Menu {
            mode
            Divider()
            sortByMenu
            Divider()
            bin
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
        .menuOrder(.fixed)
        .onChange(of: relation) { newValue in
            state.sort = AllContentSort(relation: newValue)
        }
    }
    
    private var mode: some View {
        Picker("", selection: $state.mode) {
            ForEach(AllContentMode.allCases, id: \.self) { mode in
                AnytypeText(mode.title, style: .uxTitle2Medium)
                    .foregroundColor(.Button.button)
            }
        }
    }
    
    private var sortByMenu: some View {
        Menu {
            sortRelation
            Divider()
            sortType
        } label: {
            AnytypeText(Loc.AllContent.Settings.Sort.title, style: .uxTitle2Medium)
                .foregroundColor(.Button.button)
            Text(state.sort.relation.title)
        }
        .menuActionDisableDismissBehavior()
    }
    
    private var sortRelation: some View {
        Picker("", selection: $relation) {
            ForEach(AllContentSort.Relation.allCases, id: \.self) { sortRelation in
                AnytypeText(sortRelation.title, style: .uxTitle2Medium)
                    .foregroundColor(.Button.button)
            }
        }
    }
    
    private var sortType: some View {
        Picker("", selection: $state.sort.type) {
            ForEach(state.sort.relation.availableSortTypes, id: \.self) { type in
                AnytypeText(state.sort.relation.titleFor(sortType: type), style: .uxTitle2Medium)
                    .foregroundColor(.Button.button)
            }
        }
    }
    
    private var bin: some View {
        Button {
            binTapped()
        } label: {
            AnytypeText(
                Loc.AllContent.Settings.viewBin,
                style: .uxTitle2Medium
            )
        }
    }
}
