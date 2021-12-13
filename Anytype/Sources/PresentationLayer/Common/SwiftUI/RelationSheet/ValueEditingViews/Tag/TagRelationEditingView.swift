import SwiftUI

struct TagRelationEditingView: View {
    
    @ObservedObject var viewModel: TagRelationEditingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText("No related options here. You can add some".localized, style: .uxCalloutRegular, color: .textTertiary)
                .padding(.vertical, 13)
            Spacer.fixedHeight(20)
        }
        .modifier(RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.relationName, dismissCallback: viewModel.onDismiss))
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
