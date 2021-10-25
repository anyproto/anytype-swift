import ProtobufMessages
import SwiftProtobuf
import BlocksModels

final class PageService {
    func createPage(name: String) -> CreatePageResponse? {
        let nameValue = Google_Protobuf_Value(stringValue: name)
        let details = Google_Protobuf_Struct(
            fields: [ RelationKey.name.rawValue: nameValue ]
        )
        
        return Anytype_Rpc.Page.Create.Service.invoke(details: details)
            .map { CreatePageResponse($0) }
            .getValue()
    }
}
