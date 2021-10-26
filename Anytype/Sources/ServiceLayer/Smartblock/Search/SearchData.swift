import Foundation
import SwiftProtobuf
import BlocksModels

struct SearchData: RelationValuesProtocol {
    
    let id: String
    let values: [String: Google_Protobuf_Value]
    
}
