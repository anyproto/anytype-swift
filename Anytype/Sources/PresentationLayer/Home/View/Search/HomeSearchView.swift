import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
        
    var body: some View {
        SearchView(title: nil) { data in
            viewModel.showPage(pageId: data.id)
        }
    }
}
