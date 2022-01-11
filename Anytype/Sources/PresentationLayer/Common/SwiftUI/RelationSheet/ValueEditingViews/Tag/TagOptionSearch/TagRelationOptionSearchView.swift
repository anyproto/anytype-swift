import SwiftUI

struct TagRelationOptionSearchView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var viewModel: TagRelationOptionSearchViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            SearchBar(text: $searchText, focused: false)
                .padding(.vertical, 4)
                .modifier(DividerModifier(spacing: 0))
            tagsList
            addButton
        }
        .onChange(of: searchText) { viewModel.filterTagSections(text: $0)}
    }
    
    private var tagsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchText.isNotEmpty {
                    RelationOptionCreateButton(text: searchText) {
                        viewModel.createOption(text: searchText)
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ForEach(viewModel.sections) { section in
                    Section(
                        header: RelationOptionsSectionHeaderView(title: section.title)
                    ) {
                        ForEach(section.options) { row($0) }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .modifier(DividerModifier(spacing: 0))
    }

    private func row(_ tag: Relation.Tag.Option) -> some View {
        RelationTagOptionSearchRowView(
            tag: tag,
            isSelected: viewModel.selectedTagIds.contains(tag.id)
        ) {
            viewModel.didTapOnTag(tag)
        }
    }
    
    private var addButton: some View {
        StandardButton(disabled: viewModel.selectedTagIds.isEmpty, text: "Add".localized, style: .primary) {
            viewModel.didTapAddSelectedTags()
            presentationMode.wrappedValue.dismiss()
        }
        .if(viewModel.selectedTagIds.isNotEmpty) {
            $0.overlay(
                HStack(spacing: 0) {
                    Spacer()
                    AnytypeText("\(viewModel.selectedTagIds.count)", style: .relation1Regular, color: .grayscaleWhite)
                        .frame(minWidth: 15, minHeight: 15)
                        .padding(5)
                        .background(Color.System.amber)
                        .clipShape(
                            Circle()
                        )
                    Spacer.fixedWidth(12)
                }
            )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
}

struct TagRelationOptionSearchView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationOptionSearchView(
            viewModel: TagRelationOptionSearchViewModel(
                relationKey: "",
                availableTags: [
                    Relation.Tag.Option(
                        id: "id",
                        text: "text",
                        textColor: UIColor.Text.amber,
                        backgroundColor: UIColor.Background.amber,
                        scope: .local
                    ),
                    Relation.Tag.Option(
                        id: "id3",
                        text: "text3",
                        textColor: UIColor.Text.amber,
                        backgroundColor: UIColor.Background.amber,
                        scope: .local
                    ),
                    Relation.Tag.Option(
                        id: "id2",
                        text: "text2",
                        textColor: UIColor.Text.amber,
                        backgroundColor: UIColor.Background.amber,
                        scope: .local
                    )
                ],
                relationsService: RelationsService(objectId: "")
            ) { _ in }
        )
    }
}
