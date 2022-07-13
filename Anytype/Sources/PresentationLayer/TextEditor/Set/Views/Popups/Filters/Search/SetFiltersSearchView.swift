import SwiftUI

struct SetFiltersSearchView<Content: View>: View {
    @EnvironmentObject var viewModel: SetFiltersSearchViewModel
    
    private let searchView: Content
    
    init(@ViewBuilder searchView: () -> Content) {
        self.searchView = searchView()
    }
    
    var body: some View {
        DragIndicator()
        SetFiltersSearchHeaderView(viewModel: viewModel.headerViewModel)
        switch viewModel.state {
        case .content:
            searchView
            Spacer()
        case .empty:
            Spacer()
            button
        }
       
    }
    
    private var button: some View {
        StandardButton(disabled: false, text: Loc.Set.Filters.Search.Button.title, style: .primary) {
            viewModel.handleSelectedIds([])
        }
        .padding(.horizontal, 20)
    }
}
