//
//  RelationFormat+Extensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

extension Relation.Format {
    
    var placeholder: String {
        switch self {
        case .longText:
            return "Enter text".localized
        case .shortText:
            return "Enter text".localized
        case .number:
            return "Enter number".localized
        case .date:
            return "Enter date".localized
        case .url:
            return "Enter URL".localized
        case .email:
            return "Enter e-mail".localized
        case .phone:
            return "Enter phone".localized
        case .status, .file, .checkbox, .emoji, .tag , .object, .relations, .unrecognized:
            return "Enter value".localized
        }
    }
    
}
