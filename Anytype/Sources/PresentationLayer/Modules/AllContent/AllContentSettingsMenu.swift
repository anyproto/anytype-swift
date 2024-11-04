import SwiftUI
import Services
import AnytypeCore

struct AllContentSettingsMenu: View {
    @Binding var state: AllContentState
    let binTapped: () -> Void
    
    @State private var sortRelation: AllContentSort.Relation
    @State private var sortType: DataviewSort.TypeEnum
    
    init(state: Binding<AllContentState>, binTapped: @escaping () -> Void) {
        self._state = state
        self.binTapped = binTapped
        self.sortRelation = state.wrappedValue.sort.relation
        self.sortType = state.wrappedValue.sort.type
    }
    
    var body: some View {
        Menu {
            mode
            Divider()
            sortByMenu
            if !FeatureFlags.showBinWidgetIfNotEmpty {
                Divider()
                bin
            }
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
        .menuOrder(.fixed)
        .onChange(of: sortRelation) { newValue in
            state.sort = AllContentSort(relation: newValue)
            sortType = state.sort.type
        }
        .onChange(of: sortType) { newValue in
            state.sort = AllContentSort(relation: state.sort.relation, type: newValue)
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
            sortRelationView
            Divider()
            sortTypeView
        } label: {
            AnytypeText(Loc.AllContent.Settings.Sort.title, style: .uxTitle2Medium)
                .foregroundColor(.Button.button)
            Text(state.sort.relation.title)
        }
        .menuActionDisableDismissBehavior()
    }
    
    private var sortRelationView: some View {
        Picker("", selection: $sortRelation) {
            ForEach(AllContentSort.Relation.allCases, id: \.self) { sortRelation in
                AnytypeText(sortRelation.title, style: .uxTitle2Medium)
                    .foregroundColor(.Button.button)
            }
        }
    }
    
    private var sortTypeView: some View {
        Picker("", selection: $sortType) {
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
