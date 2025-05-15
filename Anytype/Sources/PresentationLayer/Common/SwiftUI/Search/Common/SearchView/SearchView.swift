import SwiftUI
import Services

enum SearchViewEmptyViewMode {
    case object
    case property
    
    func title(_ searchText: String) -> String {
        switch self {
        case .object:
            Loc.thereIsNoObjectNamed(searchText)
        case .property:
            Loc.thereIsNoPropertyNamed(searchText)
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .object:
            Loc.newObject
        case .property:
            Loc.newProperty
        }
    }
}

struct SearchView<SearchData: SearchDataProtocol>: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    
    let title: String?
    let placeholder: String
    let searchData: [SearchDataSection<SearchData>]
    let emptyViewMode: SearchViewEmptyViewMode
    
    var dismissOnSelect = true
    
    var search: (_ text: String) async -> Void
    var onSelect: (_ searchData: SearchData) -> Void
    var onCreateNew: ((_ name: String) -> Void)?
    
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
                                    if dismissOnSelect { dismiss() }
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
        if let onCreateNew {
            EmptyStateView(
                title: emptyViewMode.title(searchText),
                subtitle: "",
                style: .plain,
                buttonData: EmptyStateView.ButtonData(
                    title: emptyViewMode.buttonTitle,
                    action: { onCreateNew(searchText) }
                )
            )
        } else {
            EmptyStateView(
                title: emptyViewMode.title(searchText),
                subtitle: Loc.createANewOneOrSearchForSomethingElse,
                style: .plain
            )
        }
    }
}
