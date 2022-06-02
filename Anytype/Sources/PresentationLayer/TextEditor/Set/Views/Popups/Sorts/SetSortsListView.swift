import SwiftUI
import BlocksModels

struct SetSortsListView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var viewModel: SetSortsListViewModel
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("EditSorts.Popup.NavigationView.Title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $viewModel.isSearchPresented) { viewModel.makeSearchView() }
        }
        .navigationViewStyle(.stack)
    }
    
    private var addButton: some View {
        Button {
            viewModel.addButtonTapped()
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
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
// @joe_pusya: will be implement in the next PRs
//            .onMove { from, to in
//
//            }
//            .onDelete { _ in
//
//            }
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .padding(.horizontal, 20)
// @joe_pusya: will be implement in the next PRs
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                EditButton()
//                    .foregroundColor(Color.buttonActive)
//            }
//        }
    }
    
    private func row(with sort: SetSort) -> some View {
        SetSortRow(sort: sort, onTap: {})
            .customDivider()
            .listRowInsets(EdgeInsets())
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
