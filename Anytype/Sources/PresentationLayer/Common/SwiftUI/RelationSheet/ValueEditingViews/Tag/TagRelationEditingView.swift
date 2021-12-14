import SwiftUI

// TODO: - add button / edit button

struct TagRelationEditingView: View {
    
    @ObservedObject var viewModel: TagRelationEditingViewModel
    
    @State private var contentHeight: CGFloat = 0.0
    @State private var sheetViewHeight: CGFloat = 0.0
    
    var body: some View {
        content
            .modifier(
                RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.relationName, dismissCallback: viewModel.onDismiss)
            )
            .background(FrameCatcher { sheetViewHeight = $0.height - 100 })
    }
    
    private var content: some View {
        Group {
            if viewModel.selectedTags.isEmpty {
                emptyView
            } else {
                tagsList
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 0) {
            AnytypeText("No related options here. You can add some".localized, style: .uxCalloutRegular, color: .textTertiary)
                .padding(.vertical, 13)
            Spacer.fixedHeight(20)
        }
    }
    
    private var tagsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.selectedTags) { tag in
                    TagRelationRowView(tag: tag) {}
                }
            }
            .padding(.horizontal, 20)
            .background(FrameCatcher { contentHeight = $0.height })
        }
        .padding(.bottom, 20)
        .if(contentHeight.isLessThanOrEqualTo(sheetViewHeight)) {
            $0.frame(height: contentHeight).disabled(true)
        }
    }
}

struct TagRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationEditingView(
            viewModel: TagRelationEditingViewModel(
                relationTag: Relation.Tag(
                    id: "",
                    name: "name",
                    isFeatured: false,
                    isEditable: true,
                    selectedTags: [
                        Relation.Tag.Option(
                            id: "id",
                            text: "text",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        )
                    ],
                    allTags: [
                        Relation.Tag.Option(
                            id: "id",
                            text: "text",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        )
                    ]
                ),
                detailsService: DetailsService(objectId: ""),
                relationsService: RelationsService(objectId: "")
            )
        )
    }
}
