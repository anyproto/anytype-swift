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
                ForEach(model.lockedSections, id: \.self) { section in
                    ManageSectionRowView(
                        title: section.localizedTitle,
                        isLocked: true,
                        visible: true,
                        onToggle: {}
                    )
                    .moveDisabled(true)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                ForEach(model.rows) { row in
                    ManageSectionRowView(
                        title: row.section.localizedTitle,
                        isLocked: false,
                        visible: row.visible,
                        onToggle: { model.onToggle(section: row.section) }
                    )
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
            .onAppear {
                AnytypeAnalytics.instance().logScreenManageSections()
            }
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
