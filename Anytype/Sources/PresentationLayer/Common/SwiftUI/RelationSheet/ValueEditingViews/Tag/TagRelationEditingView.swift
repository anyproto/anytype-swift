import SwiftUI

struct TagRelationEditingView: View {
    
    @ObservedObject var viewModel: TagRelationEditingViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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
