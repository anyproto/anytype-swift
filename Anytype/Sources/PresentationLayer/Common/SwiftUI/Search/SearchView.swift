import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let title: String?
    let onSelect: (SearchCellData) -> ()
    
    @State private var searchText = ""
    @State private var data = [SearchCellData]()

    @StateObject private var service = SearchService()
    
    var body: some View {
        VStack() {
            DragIndicator(bottomPadding: 0)
            titleView
            SearchBar(text: $searchText, focused: true)
            content
        }
        .onChange(of: searchText) { search(text: $0) }
        .onAppear { search(text: searchText) }
    }
    
    private var titleView: some View {
        Group {
            if let title = title {
                Spacer.fixedHeight(6)
                AnytypeText(title, style: .uxTitle1Semibold, color: .textPrimary)
                Spacer.fixedHeight(12)
            } else {
                EmptyView()
            }
        }
    }
    
    private var content: some View {
        Group {
            if data.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack {
                ForEach(data) { data in
                    Button(
                        action: {
                            presentationMode.wrappedValue.dismiss()
                            onSelect(data)
                        }
                    ) {
                        SearchCell(data: data)
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
                "Try to create a new one or search for something else".localized,
                style: .uxBodyRegular,
                color: .textSecondary
            )
            .multilineTextAlignment(.center)
            Spacer()
        }.padding(.horizontal)
    }
    
    private func search(text: String) {
        guard let results = service.search(text: text) else { return }
        data = results.map { SearchCellData(searchResult: $0) }
    }
}

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(title: "FOoo") { _ in
            
        }
    }
}
