import SwiftUI

struct StatusRelationListView: View {
    
    @StateObject var viewModel: StatusRelationListViewModel
    
    var body: some View {
        RelationListContainerView(
            title: viewModel.title,
            isEmpty: true,
            listContent: {
                content
            },
            onCreate: {
                viewModel.create()
            },
            onClear: {
                viewModel.clear()
            },
            onSearchTextChange: { text in
                viewModel.searchTextChanged(text)
            }
        )
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            
        }
    }
}

struct StatusRelationListView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationListView(
            viewModel: StatusRelationListViewModel(
                title: ""
            )
        )
    }
}
