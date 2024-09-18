import SwiftUI
import Services

struct AllContentSettingsMenu: View {
    
    let state: AllContentState
    let sortRelationChanged: (AllContentSort.Relation) -> Void
    let sortTypeChanged: (DataviewSort.TypeEnum) -> Void
    let binTapped: () -> Void
    
    var body: some View {
        Menu {
            sortByMenu
            viewOptions
            bin
        } label: {
            IconView(icon: .asset(.X24.more))
                .frame(width: 24, height: 24)
        }
        .menuOrder(.fixed)
    }
    
    private var sortByMenu: some View {
        Menu {
            Section {
                ForEach(AllContentSort.Relation.allCases, id: \.self) { sortRelation in
                    sortRow(title: sortRelation.title, selected: state.sort.relation == sortRelation) {
                        sortRelationChanged(sortRelation)
                    }
                }
            }
            Section {
                ForEach(state.sort.relation.availableSortTypes, id: \.self) { type in
                    sortRow(title: state.sort.relation.titleFor(sortType: type), selected: state.sort.type == type) {
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
    
    private func sortRow(title: String, selected: Bool, onTap: @escaping () -> Void) -> some View {
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
    
    private var viewOptions: some View {
        Button {
            // TODO
        } label: {
            AnytypeText(
                Loc.AllContent.Settings.ViewOprions.title,
                style: .uxTitle2Medium
            )
            .foregroundColor(.Button.button)
        }
    }
    
    private var bin: some View {
        Button(role: .destructive) {
            binTapped()
        } label: {
            AnytypeText(
                Loc.bin,
                style: .uxTitle2Medium
            )
        }
    }
}
