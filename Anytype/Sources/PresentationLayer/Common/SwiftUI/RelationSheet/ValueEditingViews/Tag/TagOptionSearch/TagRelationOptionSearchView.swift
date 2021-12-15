import SwiftUI

struct TagRelationOptionSearchView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var viewModel: TagRelationOptionSearchViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            SearchBar(text: $searchText, focused: false)
            tagsList
            Spacer.fixedHeight(20)
        }
        .onChange(of: searchText) { viewModel.filterTagSections(text: $0)}
    }
    
    private var tagsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchText.isNotEmpty {
                    RelationValueOptionCreateButton(text: searchText) {
                        viewModel.createOption(text: searchText)
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ForEach(viewModel.sections) { section in
                    Section(
                        header: RelationValueOptionSectionHeaderView(title: section.title)
                    ) {
                        ForEach(section.options) { row($0) }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func row(_ tag: Relation.Tag.Option) -> some View {
        RelationTagOptionSearchRowView(
            tag: tag,
            isSelected: viewModel.selectedTagIds.contains(tag.id)
        ) {
            viewModel.didTapOnTag(tag)
        }
    }
}

struct TagRelationOptionSearchView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationOptionSearchView(
            viewModel: TagRelationOptionSearchViewModel(
                relationKey: "",
                availableTags: [],
                detailsService: DetailsService(objectId: ""),
                relationsService: RelationsService(objectId: "")
            ) { _ in }
        )
    }
}
