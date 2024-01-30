import SwiftUI
import Services


struct ObjectTypeSearchView: View {
    
    @StateObject var viewModel: ObjectTypeSearchViewModel

    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.createNewObject)
            SearchBar(text: $searchText, focused: true, placeholder: Loc.search)
            content
        }
        .background(Color.Background.secondary)
        
        .onChange(of: searchText) { viewModel.search(text: $0) }
        .onAppear { viewModel.search(text: searchText) }
    }
    
    private var content: some View {
        Group {
            switch viewModel.state {
            case .showTypes(let types):
                searchResults(types: types)
            case .emptyScreen:
                NewSearchErrorView(error: .noTypeError(searchText: searchText))
            }
        }
    }
    
    private func searchResults(types: [ObjectType]) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                typesView(types: types)
            }
            .padding(.bottom, 10)
        }
    }
    
    private func typesView(types: [ObjectType]) -> some View {
        ForEach(types) { type in
            Button {
                viewModel.didSelectType(type)
            } label: {
                HStack {
                    AnytypeText("\(type.iconEmoji.value) \(type.name)", style: .uxTitle2Medium, color: .Text.primary)
                }
                .padding(.vertical, 15)
                .padding(.leading, 14)
                .padding(.trailing, 16)
            }
            .border(12, color: .Stroke.primary)
        }
    }
}
