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
        Group {
            if data.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
        .onChange(of: searchText) { search(text: $0) }
        .onAppear { search(text: searchText) }
    }
    
    private var searchResults: some View {
        List(data) { data in
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                viewModel.showPage(pageId: data.id)
            }) {
                HomeSearchCell(data: data)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                "\("There is no object named".localized) \"\(searchText)\"",
                style: .uxBodyRegular
            )
            .foregroundColor(.textPrimary)
            .multilineTextAlignment(.center)
            AnytypeText(
                "Try to create a new one or search for something else",
                style: .uxBodyRegular
            )
            .foregroundColor(.textSecondary)
            .multilineTextAlignment(.center)
            Spacer()
        }.padding(.horizontal)
    }
    
    private func search(text: String) {
        service.search(text: text) { results in
            data = results.map { HomeSearchCellData(searchResult: $0) }
        }
    }
}

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        HomeSearchView()
    }
}
