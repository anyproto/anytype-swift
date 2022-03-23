import BlocksModels

final class SetTableViewRowDataBuilder {
    private let relationsBuilder = RelationsBuilder(scope: [.object, .type])
    
    func build(
        _ datails: [ObjectDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        colums: [RelationMetadata]
    ) -> [SetTableViewRowData] {
        datails.map { details in
            let parsedRelations = relationsBuilder.parsedRelations(
                relationMetadatas: dataView.relationsMetadataForView(activeView),
                objectId: details.id
            ).all
            
            let sortedRelations = colums.compactMap { colum in
                parsedRelations.first { $0.id == colum.key }
            }
            
            let relations: [Relation] = colums.map { colum in
                let relation = sortedRelations.first { $0.id == colum.key }
                guard let relation = relation else {
                    return .unknown(.empty(id: colum.id, name: colum.name))
                }
                
                return relation
            }
            
            let screenData = EditorScreenData(pageId: details.id, type: details.editorViewType)
            
            return SetTableViewRowData(
                id: details.id,
                title: details.title,
                icon: details.objectIconImage,
                relations: relations,
                screenData: screenData,
                showIcon: !activeView.hideIcon
            )
        }
    }
}
