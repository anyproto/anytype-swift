import SwiftUI

struct HomeSearchView: View {
    @State private var searchText = ""
    @State private var data = [HomeSearchCellData]()
    
    private let service = SearchService()
    
    var body: some View {
        DragIndicator(bottomPadding: 0)
        SearchBar(text: $searchText)
        List(data) { data in
            HomeSearchCell(data: data)
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
