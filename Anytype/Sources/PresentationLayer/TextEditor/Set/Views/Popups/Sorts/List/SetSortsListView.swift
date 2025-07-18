import SwiftUI

struct SetSortsListView: View {
    @StateObject private var viewModel: SetSortsListViewModel
    
    @State private var editMode = EditMode.inactive
    
    init(setDocument: some SetDocumentProtocol, viewId: String, output: (any SetSortsListCoordinatorOutput)?) {
        _viewModel = StateObject(wrappedValue: SetSortsListViewModel(setDocument: setDocument, viewId: viewId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            NavigationView {
                content
                    .navigationTitle(Loc.EditSet.Popup.Sorts.NavigationView.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .environment(\.editMode, $editMode)
                    .onChange(of: viewModel.rows) { newValue in
                        if editMode == .active && viewModel.rows.count == 0 {
                            editMode = .inactive
                        }
                    }
            }
            .navigationViewStyle(.stack)
        }
        .background(Color.Background.secondary)
    }
    
    private var addButton: some View {
        Group {
            if editMode == .inactive {
                Button {
                    viewModel.addButtonTapped()
                } label: {
                    Image(asset: .X32.plus)
                        .foregroundColor(.Control.secondary)
                }
            }
        }
    }
    
    private var content: some View {
        Group {
            if viewModel.rows.isNotEmpty {
                sortsList
            } else {
                emptyState
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            AnytypeText(
                Loc.EditSet.Popup.Sorts.EmptyView.title,
                style: .uxCalloutRegular
            )
                .foregroundColor(.Text.secondary)
                .frame(height: 68)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.Background.secondary)
    }
    
    private var sortsList: some View {
        List {
            ForEach(viewModel.rows) {
                row(with: $0)
                    .divider(leadingPadding: 60)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            .onMove { from, to in
                viewModel.move(from: from, to: to)
            }
            .onDelete {
                viewModel.delete($0)
            }
            .listRowBackground(Color.Background.secondary)
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.Control.secondary)
            }
        }
        .background(Color.Background.secondary)
    }
    
    private func row(with configuration: SetSortRowConfiguration) -> some View {
        SetSortRow(configuration: configuration)
            .environment(\.editMode, $editMode)
    }
    
}
