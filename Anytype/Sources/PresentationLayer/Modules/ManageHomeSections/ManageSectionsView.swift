import SwiftUI

struct ManageSectionsView: View {
    @State private var model: ManageSectionsViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String) {
        _model = State(wrappedValue: ManageSectionsViewModel(spaceId: spaceId))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.rows) { row in
                    ManageSectionRowView(row: row) {
                        model.onToggle(section: row.section)
                    }
                    .moveDisabled(row.isLocked)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                .onMove { from, to in
                    model.onMove(from: from, to: to)
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
            .navigationTitle(Loc.manageSections)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) { dismiss() }
                    } else {
                        Button(Loc.done) { dismiss() }
                    }
                }
            }
        }
    }
}
