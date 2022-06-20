import SwiftUI
import BlocksModels

struct SetSortsListView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var viewModel: SetSortsListViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
                .navigationTitle("EditSorts.Popup.NavigationView.Title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .onChange(of: setModel.sorts) { newValue in
                    if editMode == .active && setModel.sorts.count == 0 {
                        editMode = .inactive
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private var addButton: some View {
        Group {
            if editMode == .inactive {
                Button {
                    viewModel.addButtonTapped()
                } label: {
                    Image.Relations.createOption.frame(width: 24, height: 24)
                }
            }
        }
    }
    
    private var content: some View {
        Group {
            if setModel.sorts.isNotEmpty {
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
            Spacer.fixedHeight(20)
            AnytypeText(
                "EditSorts.Popup.EmptyView.Title".localized,
                style: .uxCalloutRegular,
                color: .textSecondary
            )
                .frame(height: 68)
            Spacer()
        }
    }
    
    private var sortsList: some View {
        List {
            ForEach(setModel.sorts) {
                if #available(iOS 15.0, *) {
                    row(with: $0)
                        .divider(leadingPadding: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                } else {
                    row(with: $0)
                }
            }
            .onMove { from, to in
                viewModel.move(from: from, to: to)
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
    
    private func row(with sort: SetSort) -> some View {
        SetSortRow(sort: sort, onTap: { viewModel.sortRowTapped(sort) })
            .environment(\.editMode, $editMode)
    }
    
}
