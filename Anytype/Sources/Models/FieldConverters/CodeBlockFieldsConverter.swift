//
//  CodeBlockFieldsConverter.swift
//  Anytype
//
//  Created by Denis Batvinkin on 27.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import ProtobufMessages
import SwiftProtobuf
import BlocksModels

extension CodeBlockFields: FieldsConvertibleProtocol {

    func asMiddleware() -> BlockFields {
        var protoFields: [String: Google_Protobuf_Value] = [:]

        protoFields[FieldName.codeLanguage] = language.toMiddleware().protobufValue

        return protoFields
    }
}
