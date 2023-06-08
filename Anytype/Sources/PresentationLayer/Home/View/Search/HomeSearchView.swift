import SwiftUI

struct HomeSearchView: View {
    @ObservedObject var viewModel: HomeViewModel
        
    var body: some View {
        let searchViewModel = ObjectSearchViewModel(
            searchService: ServiceLocator.shared.searchService()
        ) { [weak viewModel] data in
            viewModel?.showPage(id: data.blockId, viewType: data.viewType)
        }
        return SearchView(title: nil, viewModel: searchViewModel)
    }
}
