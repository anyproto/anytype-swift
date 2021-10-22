//
//  ObjectDetailDefaultValue.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import AnytypeCore

enum ObjectDetailDefaultValue {
    static let string = ""
    static let type = ObjectTemplateType.note
    static let bool = false
    static let hash: Hash? = nil
    static let coverType: CoverType = .none
    static let layout: DetailsLayout = .note
    static let layoutAlignment: LayoutAlignment = .left
}
