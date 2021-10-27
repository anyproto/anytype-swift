import SwiftUI
import BlocksModels

enum SearchKind {
    case objects
    case objectTypes(currentObjectTypeUrl: String)
}

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let kind: SearchKind
    let title: String?
    let onSelect: (BlockId) -> ()
    
    @State private var searchText = ""
    @State private var data = [SearchData]()

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
                ForEach(data, id: \.id) { data in
                    Button(
                        action: {
                            presentationMode.wrappedValue.dismiss()
                            onSelect(data.id)
                        }
                    ) {
                        SearchCell(searchKind: kind, data: data)
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
        let result: [SearchData]? = {
            switch kind {
            case .objects:
                return service.search(text: text)
            case .objectTypes(let currentObjectTypeUrl):
                return service.searchObjectTypes(
                    text: text,
                    currentObjectTypeUrl: currentObjectTypeUrl
                )
            }
        }()
        
        guard let results = result else { return }
        data = results
    }
}

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(kind: .objects, title: "FOoo") { _ in
            
        }
    }
}
