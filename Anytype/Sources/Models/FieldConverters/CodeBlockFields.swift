//
//  CodeBlockFields.swift
//  Anytype
//
//  Created by Denis Batvinkin on 27.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

struct CodeBlockFields {

    enum FieldName {
        public static let codeLanguage = "lang"
    }

    let language: CodeLanguage
}
