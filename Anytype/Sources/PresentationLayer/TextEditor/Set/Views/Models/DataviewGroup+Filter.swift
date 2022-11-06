import BlocksModels
import SwiftProtobuf

extension DataviewGroup {

    var protobufValue: Google_Protobuf_Value? {
        switch value {
        case .tag(let tag):
            return tag.ids.protobufValue
        case .status(let status):
            return status.id.protobufValue
        case .checkbox(let checkbox):
            return checkbox.checked.protobufValue
        default:
            return nil
        }
    }
    
    func filter(with relationKey: String) -> DataviewFilter? {
        switch value {
        case .tag(let tag):
            return DataviewFilter(
                relationKey: relationKey,
                condition: tag.ids.isEmpty ? .empty : .exactIn,
                value: tag.ids.protobufValue
            )
        case .status(let status):
            return DataviewFilter(
                relationKey: relationKey,
                condition: status.id.isEmpty ? .empty : .equal,
                value: status.id.protobufValue
            )
        case .checkbox(let checkbox):
            return DataviewFilter(
                relationKey: relationKey,
                condition: .equal,
                value: checkbox.checked.protobufValue
            )
        default:
            return nil
        }
    }
}
