import SwiftUI

struct RelationObjectsSearchView: View {
    
    @ObservedObject var viewModel: RelationObjectsSearchViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        VStack() {
            DragIndicator(bottomPadding: 0)
            SearchBar(text: $searchText, focused: true)
            content
        }
        .background(Color.backgroundSecondary)
        .onChange(of: searchText) { viewModel.search(text: $0) }
        .onAppear { viewModel.search(text: searchText) }
    }
    
    private var content: some View {
        Group {
            if viewModel.objects.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.objects) { RelationObjectsSearchRowView(data: $0) }
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
}

//struct RelationObjectsSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        RelationObjectsSearchView()
//    }
//}
