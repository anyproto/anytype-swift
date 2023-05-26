import SwiftUI
import Services

struct SearchView<SearchViewModel: SearchViewModelProtocol>: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String?

    @State private var searchText = ""
    @StateObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: title)
            SearchBar(text: $searchText, focused: true, placeholder: viewModel.placeholder)
            content
        }
        .background(Color.Background.secondary)
        .onChange(of: searchText) {
            search(text: $0)
        }
        .onAppear { search(text: searchText) }
    }
    
    private var content: some View {
        Group {
            if viewModel.searchData.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchData) { section in
                    Section(content: {
                        ForEach(section.searchData) { searchData in
                            Button(
                                action: {
                                    presentationMode.wrappedValue.dismiss()
                                    viewModel.onDismiss()
                                    viewModel.onSelect(searchData)
                                }
                            ) {
                                SearchCell(data: searchData)
                            }
                        }
                    }, header: {
                        if section.sectionName.isNotEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                AnytypeText(section.sectionName, style: .caption1Regular, color: .Text.secondary)
                                    .divider(spacing: 7, leadingPadding: 0, trailingPadding: 0, alignment: .leading)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 52)
                        } else {
                            EmptyView()
                        }
                    })
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                Loc.thereIsNoObjectNamed(searchText),
                style: .uxBodyRegular,
                color: .Text.primary
            )
            .multilineTextAlignment(.center)
            AnytypeText(
                Loc.createANewOneOrSearchForSomethingElse,
                style: .uxBodyRegular,
                color: .Text.secondary
            )
            .multilineTextAlignment(.center)
            Spacer()
        }.padding(.horizontal)
    }
    
    private func search(text: String) {
        viewModel.search(text: text)
    }
}

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(
            title: "FOoo",
            viewModel: ObjectSearchViewModel(searchService: DI.preview.serviceLocator.searchService()) { _ in }
        )
    }
}
