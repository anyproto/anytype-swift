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

        if let withIcon = fields[FieldsName.withIcon] {
            switch withIcon {
            case .boolType(let value):
                if value {
                    icon = .medium
                }
            default:
                break
            }
        }

        if let style = fields[FieldsName.style] {
            switch style {
            case .doubleType(let value):
                if value == 1 {
                    layout = .card
                }
            default:
                break
            }
        }

        if let withName = fields[FieldsName.withName] {
            switch withName {
            case .boolType(let value):
                name = value
            default:
                break
            }
        }

        if let withDescription = fields[FieldsName.withDescription] {
            switch withDescription {
            case .boolType(let value):
                if value {
                    featuredRelationsIds.insert(BundledRelationKey.description.rawValue)
                }
            default:
                break
            }
        }

        return .init(icon: icon, layout: layout, withName: name, featuredRelationsIds: featuredRelationsIds)
    }
}
