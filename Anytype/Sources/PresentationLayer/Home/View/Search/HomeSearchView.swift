import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var data = [HomeSearchCellData]()
    
    private let service = SearchService()
    
    var body: some View {
        DragIndicator(bottomPadding: 0)
        SearchBar(text: $searchText)
        List(data) { data in
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                viewModel.showPage(pageId: data.id)
            }) {
                HomeSearchCell(data: data)
            }
        }
        .onChange(of: searchText) { text in
            service.search(text: text) { results in
                data = results.map { HomeSearchCellData(searchResult: $0) }
            }
        }
    }
}

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        HomeSearchView()
    }
}
