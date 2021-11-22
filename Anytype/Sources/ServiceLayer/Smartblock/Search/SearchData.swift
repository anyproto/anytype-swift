import Foundation
import SwiftProtobuf
import BlocksModels


struct SearchData: RelationMetadataValuesProvider {
    let id: String
    let values: [String: Google_Protobuf_Value]
}
