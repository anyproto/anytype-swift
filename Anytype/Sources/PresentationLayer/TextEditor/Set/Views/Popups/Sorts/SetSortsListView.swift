import SwiftUI
import BlocksModels

struct SetSortsListView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var viewModel: SetSortsListViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("EditSorts.Popup.NavigationView.Title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .sheet(isPresented: $viewModel.isSearchPresented) { viewModel.makeSearchView() }
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
                AnytypeText(
                    "EditSorts.Popup.EmptyView.Title".localized,
                    style: .uxCalloutRegular,
                    color: .textSecondary
                )
                    .frame(height: 68)
            }
        }
// @joe_pusya: will be implement in the next PRs
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                addButton
//            }
//        }
    }
    
    private var sortsList: some View {
        List {
            ForEach(setModel.sorts) {
                row(with: $0)
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
        SetSortRow(sort: sort, onTap: {})
            .environment(\.editMode, $editMode)
            .customDivider()
            .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
}

private extension View {
    func customDivider() -> some View {
        Group {
            if #available(iOS 15.0, *) {
                divider(leadingPadding: 60).listRowSeparator(.hidden)
            }
        }
    }
}
