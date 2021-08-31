
import BlocksModels
import ProtobufMessages

struct MentionsParser {
        
    func parseMentions(from response: Anytype_Rpc.Navigation.ListObjects.Response) -> [MentionObject] {
        response.objects.map { mentionFrom(middwareMention: $0) }
    }
    
    func mentionFrom(middwareMention: Anytype_Model_ObjectInfo) -> MentionObject {
        let details = middwareMention.details.fields.map(Anytype_Rpc.Block.Set.Details.Detail.init(key:value:))
        let contentList = BlocksModelsDetailsConverter.asModel(details: details)
        let detailsData = DetailsData(details: contentList, parentId: "")
        let type = detailsData.typeUrl.flatMap { ObjectTypeProvider.objectType(url: $0) }
        
        return MentionObject(
            id: middwareMention.id,
            icon: mentionIcon(from: detailsData),
            name: detailsData.name,
            description: detailsData.description,
            type: type
        )
    }
    
    func parseMentions(from searchResults: [SearchResult]) -> [MentionObject] {
        searchResults.map { mention(from: $0) }
    }
    
    func mention(from searchResult: SearchResult) -> MentionObject {
        MentionObject(
            id: searchResult.id,
            icon: mentionIcon(from: searchResult),
            name: searchResult.name,
            description: searchResult.description,
            type: searchResult.type
        )
    }
    
    private func mentionIcon(from details: DetailsDataProtocol) -> MentionIcon? {
        if let objectIcon = details.icon {
            return .objectIcon(objectIcon)
        }
        
        guard case .todo = details.layout else { return nil }
        
        return .checkmark(details.done ?? false)
    }
}
