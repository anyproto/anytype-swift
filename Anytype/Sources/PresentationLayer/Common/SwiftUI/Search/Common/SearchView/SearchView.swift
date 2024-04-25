import SwiftUI
import Services

struct SearchView<SearchData: SearchDataProtocol>: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    
    let title: String?
    let placeholder: String
    let searchData: [SearchDataSection<SearchData>]
    
    var search: (_ text: String) async -> Void
    var onSelect: (_ searchData: SearchData) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: title)
            SearchBar(text: $searchText, focused: true, placeholder: placeholder)
            content
        }
        .background(Color.Background.secondary)
        .task(id: searchText) {
            await search(searchText)
        }
    }
    
    private var content: some View {
        Group {
            if searchData.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchData) { section in
                    Section(content: {
                        ForEach(section.searchData) { searchData in
                            Button(
                                action: {
                                    dismiss()
                                    onSelect(searchData)
                                }
                            ) {
                                SearchCell(data: searchData)
                            }
                        }
                    }, header: {
                        if section.sectionName.isNotEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                AnytypeText(section.sectionName, style: .caption1Regular)
                                    .foregroundColor(.Text.secondary)
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
        EmptyStateView(
            title: Loc.thereIsNoObjectNamed(searchText),
            subtitle: Loc.createANewOneOrSearchForSomethingElse
        )
    }
}
