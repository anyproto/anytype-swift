import SwiftUI
import BlocksModels

struct SetFiltersListView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var viewModel: SetFiltersListViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
                .navigationTitle(Loc.EditFilters.Popup.NavigationView.title)
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
        }
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        Group {
            if viewModel.rows.isNotEmpty {
                filtersList
            } else {
                emptyState
            }
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer.fixedHeight(20)
            AnytypeText(
                Loc.EditFilters.Popup.EmptyView.title,
                style: .uxCalloutRegular,
                color: .textSecondary
            )
                .frame(height: 68)
            Spacer()
        }
    }
    
    private var filtersList: some View {
        List {
            ForEach(viewModel.rows) {
                if #available(iOS 15.0, *) {
                    row(with: $0)
                        .divider(leadingPadding: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                } else {
                    row(with: $0)
                }
            }
            .onDelete {
                viewModel.delete($0)
            }
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.buttonActive)
            }
        }
    }
    
    private func row(with configuration: SetFilterRowConfiguration) -> some View {
        SetFilterRow(configuration: configuration, onTap: { })
            .environment(\.editMode, $editMode)
    }
    
}
