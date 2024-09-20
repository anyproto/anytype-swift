import SwiftUI
import Services

struct AllContentSettingsMenu: View {
    
    let state: AllContentState
    let modeChanged: (AllContentMode) -> Void
    let sortRelationChanged: (AllContentSort.Relation) -> Void
    let sortTypeChanged: (DataviewSort.TypeEnum) -> Void
    let binTapped: () -> Void
    
    var body: some View {
        Menu {
            mode
            sortByMenu
            bin
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
        .menuOrder(.fixed)
    }
    
    private var mode: some View {
        Section {
            ForEach(AllContentMode.allCases, id: \.self) { mode in
                row(title: mode.title, selected: state.mode == mode) {
                    modeChanged(mode)
                }
            }
        }
    }
    
    private var sortByMenu: some View {
        Menu {
            Section {
                ForEach(AllContentSort.Relation.allCases, id: \.self) { sortRelation in
                    row(title: sortRelation.title, selected: state.sort.relation == sortRelation) {
                        sortRelationChanged(sortRelation)
                    }
                }
            }
            Section {
                ForEach(state.sort.relation.availableSortTypes, id: \.self) { type in
                    row(title: state.sort.relation.titleFor(sortType: type), selected: state.sort.type == type) {
                        sortTypeChanged(type)
                    }
                }
            }
        } label: {
            Label(Loc.AllContent.Settings.Sort.title, systemImage: "arrow.up.arrow.down")
            Text(state.sort.relation.title)
        }
        .menuActionDisableDismissBehavior()
    }
    
    private func row(title: String, selected: Bool, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            AnytypeText(
                title,
                style: .uxTitle2Medium
            )
            .foregroundColor(.Button.button)
            
            if selected {
                Image(asset: .X24.tick)
                    .foregroundColor(.Text.primary)
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
