
import BlocksModels
import ProtobufMessages

struct MentionsParser {
        
    func parseMentions(from response: Anytype_Rpc.Navigation.ListObjects.Response) -> [MentionObject] {
        response.objects.map { self.mentionFrom(middwareMention: $0) }
    }
    
    func mentionFrom(middwareMention: Anytype_Model_ObjectInfo) -> MentionObject {
        let details = middwareMention.details.fields.map(Anytype_Rpc.Block.Set.Details.Detail.init(key:value:))
        let contentList = BlocksModelsDetailsConverter.asModel(details: details)
        let detailsData = DetailsData(details: contentList, parentId: "")
        let icon = detailsData.icon ?? DocumentIconType.profile(.placeholder(detailsData.name?.first ?? Character("")))
        
        return MentionObject(id: middwareMention.id,
                             name: detailsData.name,
                             description: detailsData.description,
                             iconData: icon)
    }
}
