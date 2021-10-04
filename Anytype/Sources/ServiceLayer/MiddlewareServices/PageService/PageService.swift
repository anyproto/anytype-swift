import ProtobufMessages
import SwiftProtobuf
import BlocksModels

final class PageService {
    func createPage(name: String) -> CreatePageResult {
        let nameValue = Google_Protobuf_Value(stringValue: name)
        let details = Google_Protobuf_Struct(
            fields: [
                DetailsKind.name.rawValue: nameValue
            ]
        )
        let result = Anytype_Rpc.Page.Create.Service.invoke(details: details)
        switch result {
        case .success(let response):
            return .response(CreatePageResponse(response))
        case .failure(let error):
            return .error(error)
        }
    }
}
