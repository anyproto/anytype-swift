import ProtobufMessages
import SwiftProtobuf
import BlocksModels

final class PageService {
    func createPage(name: String) -> BlockId? {
        let nameValue = Google_Protobuf_Value(stringValue: name)
        let details = Google_Protobuf_Struct(
            fields: [ RelationKey.name.rawValue: nameValue ]
        )
        
        guard let response = Anytype_Rpc.Page.Create.Service.invoke(details: details).getValue() else {
            return nil
        }
        
        EventsBunch(event: response.event).send()
        return response.pageID
    }
}
