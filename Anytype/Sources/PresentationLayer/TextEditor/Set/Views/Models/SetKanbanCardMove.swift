import Services
import SwiftProtobuf
import AnytypeCore

enum SetKanbanCardMoveValue: Equatable {
    case ids([String])
    case checked(Bool)
    case unset

    var protobufValue: Google_Protobuf_Value {
        switch self {
        case .ids(let ids):
            return ids.protobufValue
        case .checked(let checked):
            return checked.protobufValue
        case .unset:
            return Google_Protobuf_Value(nilLiteral: ())
        }
    }
}

enum SetKanbanCardMove: Equatable {
    case write(SetKanbanCardMoveValue)
    case ignore

    static func compute(
        currentValue: [String],
        sourceGroupValue: DataviewGroupValue?,
        targetGroupValue: DataviewGroupValue?,
        groupsLoaded: Bool
    ) -> SetKanbanCardMove {
        guard groupsLoaded, let targetGroupValue else { return .ignore }

        switch targetGroupValue {
        case .status(let status):
            return status.id.isEmpty ? .write(.unset) : .write(.ids([status.id]))
        case .checkbox(let checkbox):
            return .write(.checked(checkbox.checked))
        case .tag(let tag):
            let sourceIds: [String]
            if case let .tag(sourceTag)? = sourceGroupValue {
                sourceIds = sourceTag.ids
            } else if sourceGroupValue == nil {
                // An unresolved source column means the card's real tags couldn't be
                // cross-checked; with an empty current read the write would replace the
                // card's whole tag set blind — the exact loss this type exists to prevent.
                guard currentValue.isNotEmpty, tag.ids.isNotEmpty else { return .ignore }
                sourceIds = []
            } else {
                sourceIds = []
            }
            var newIds = currentValue.filter { !sourceIds.contains($0) }
            for id in tag.ids where !newIds.contains(id) {
                newIds.append(id)
            }
            guard newIds != currentValue else { return .ignore }
            return .write(.ids(newIds))
        default:
            return .ignore
        }
    }

    static func prefilledValue(targetGroupValue: DataviewGroupValue?) -> Google_Protobuf_Value? {
        // No ternaries here: Google_Protobuf_Value is ExpressibleByNilLiteral, so a
        // `nil` branch would silently become an explicit protobuf NULL_VALUE.
        switch targetGroupValue {
        case .status(let status):
            guard status.id.isNotEmpty else { return nil }
            return [status.id].protobufValue
        case .checkbox(let checkbox):
            return checkbox.checked.protobufValue
        case .tag(let tag):
            guard tag.ids.isNotEmpty else { return nil }
            return tag.ids.protobufValue
        default:
            return nil
        }
    }

    static func stringList(from value: Google_Protobuf_Value?) -> [String] {
        guard let value else { return [] }
        if case let .listValue(list) = value.kind {
            return list.values.map(\.stringValue).filter(\.isNotEmpty)
        }
        let single = value.stringValue
        return single.isEmpty ? [] : [single]
    }
}
