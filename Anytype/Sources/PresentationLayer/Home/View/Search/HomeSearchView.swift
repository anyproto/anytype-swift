import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
        
    var body: some View {
        let searchViewModel = ObjectSearchViewModel(searchKind: .objects) { [weak viewModel] id in
            viewModel?.showPage(pageId: id)
        }
        return SearchView(title: nil, viewModel: searchViewModel)
    }
}
