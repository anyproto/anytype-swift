import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var data = [HomeSearchCellData]()
    
    private let service = SearchService()
    
    var body: some View {
        VStack() {
            DragIndicator(bottomPadding: 0)
            SearchBar(text: $searchText)
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
        ScrollView {
            LazyVStack {
                ForEach(data) { data in
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        viewModel.showPage(pageId: data.id)
                    }) {
                        HomeSearchCell(data: data)
                    }
                    .frame(maxWidth: .infinity)
                    .modifier(DividerModifier(spacing: 0, leadingPadding: 72, trailingPadding: 12, alignment: .leading))
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                "\("There is no object named".localized) \"\(searchText)\"",
                style: .uxBodyRegular,
                color: .textPrimary
            )
            .multilineTextAlignment(.center)
            AnytypeText(
                "Try to create a new one or search for something else",
                style: .uxBodyRegular,
                color: .textSecondary
            )
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
