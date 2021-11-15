import Foundation
import SwiftProtobuf
import BlocksModels


struct SearchData: RelationValuesProvider {
    let id: String
    let values: [String: Google_Protobuf_Value]
}
