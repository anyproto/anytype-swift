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

final class ObjectPreviewFieldsConverter {

    enum FieldsName {
        static let withName = "withName"
        static let withIcon = "withIcon"
        static let style = "style"
        static let withDescription = "withDescription"
    }

    static func convertToMiddle(fields: ObjectPreviewFields) -> Google_Protobuf_Struct {
        typealias ProtobufDictionary = [String: Google_Protobuf_Value]

        var protoFields: [String: Google_Protobuf_Value] = [:]

        protoFields[FieldsName.withName] = fields.withName.protobufValue

        switch fields.icon {
        case .none:
            protoFields[FieldsName.withIcon] = false
        case .medium:
            protoFields[FieldsName.withIcon] = true
        }

        switch fields.layout {
        case .text:
            protoFields[FieldsName.style] = ""
        case .card:
            protoFields[FieldsName.style] = 1
        }

        let withDescription = fields.featuredRelationsIds.contains {
            $0 == BundledRelationKey.description.rawValue
        }

        protoFields[FieldsName.withDescription] = withDescription.protobufValue
        return .init(fields: protoFields)
    }

    static func convertToModel(fields: MiddleBlockFields) -> ObjectPreviewFields {
        var icon: ObjectPreviewFields.Icon = .none
        var layout: ObjectPreviewFields.Layout = .text
        var name: Bool = false
        var featuredRelationsIds: Set<String> = []

        if case let .boolType(value) = fields[FieldsName.withIcon], value {
            icon = .medium
        }

        if case let .doubleType(value) = fields[FieldsName.style], value == 1 {
            layout = .card
        }

        if case let .boolType(value) = fields[FieldsName.withName] {
            name = value
        }

        if case let .boolType(value) = fields[FieldsName.withDescription], value {
            featuredRelationsIds.insert(BundledRelationKey.description.rawValue)
        }

        return .init(icon: icon, layout: layout, withName: name, featuredRelationsIds: featuredRelationsIds)
    }
}
