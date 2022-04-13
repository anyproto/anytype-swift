import SwiftUI
import Amplitude

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
        
    var body: some View {
        let searchViewModel = ObjectSearchViewModel { [weak viewModel] data in
            viewModel?.showPage(pageId: data.blockId, viewType: data.viewType)
        }
        return SearchView(title: nil, context: .general, viewModel: searchViewModel)
    }
}
