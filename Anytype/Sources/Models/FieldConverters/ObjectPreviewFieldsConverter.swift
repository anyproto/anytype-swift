//
//  ObjectPreviewFieldsConverter.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import ProtobufMessages
import SwiftProtobuf
import BlocksModels

extension ObjectPreviewFields: FieldsConvertibleProtocol {

    func asMiddleware() -> BlockFields {
        typealias ProtobufDictionary = [String: Google_Protobuf_Value]

        var protoFields: [String: Google_Protobuf_Value] = [:]

        protoFields[FieldName.withName] = withName.protobufValue

        switch icon {
        case .none:
            protoFields[FieldName.withIcon] = false
        case .medium:
            protoFields[FieldName.withIcon] = true
        }

        switch layout {
        case .text:
            protoFields[FieldName.style] = ""
        case .card:
            protoFields[FieldName.style] = 1
        }

        let withDescription = featuredRelationsIds.contains {
            $0 == BundledRelationKey.description.rawValue
        }
        protoFields[FieldName.withDescription] = withDescription.protobufValue

        return protoFields
    }

    static func convertToModel(fields: BlockFields) -> ObjectPreviewFields {
        var icon: ObjectPreviewFields.Icon = .medium
        var layout: ObjectPreviewFields.Layout = .text
        var name: Bool = true
        var featuredRelationsIds: Set<String> = []

        if case let .boolValue(value) = fields[FieldName.withIcon]?.kind, !value {
            icon = .none
        }

        if case let .numberValue(value) = fields[FieldName.style]?.kind, value == 1 {
            layout = .card
        }

        if case let .boolValue(value) = fields[FieldName.withName]?.kind {
            name = value
        }

        if case let .boolValue(value) = fields[FieldName.withDescription]?.kind, value {
            featuredRelationsIds.insert(BundledRelationKey.description.rawValue)
        }

        return .init(icon: icon, layout: layout, withName: name, featuredRelationsIds: featuredRelationsIds)
    }
}
