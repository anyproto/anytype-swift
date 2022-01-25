import SwiftUI

struct StatusRelationDetailsView: View {
    
    @ObservedObject var viewModel: StatusRelationDetailsViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false)
            statusesList
            Spacer.fixedHeight(20)
        }
        .onChange(of: searchText) { viewModel.filterStatuses(text: $0) }
    }
    
    private var statusesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchText.isNotEmpty {
                    RelationOptionCreateButton(text: searchText) {
                        viewModel.addOption(text: searchText)
                    }
                }
                
                ForEach(viewModel.sections) { section in
                    Section(
                        header: RelationOptionsSectionHeaderView(title: section.title)
                    ) {
                        ForEach(section.options) {
                            StatusRelationDetailsRowView(selectedStatus: $viewModel.selectedStatus, status: $0)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
}

//struct StatusRelationEditingView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusRelationDetailsView(
//            viewModel: StatusRelationDetailsViewModel(
//                relationKey: "",
//                relationName: "",
//                relationOptions: [],
//                selectedStatus: nil,
//                relationsService: RelationsService(objectId: "")
//            )
//        )
//    }
//}
