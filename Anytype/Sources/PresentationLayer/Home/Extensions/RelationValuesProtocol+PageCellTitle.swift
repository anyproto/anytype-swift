//
//  DetailsDataProtocol+PageCellTitle.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

extension RelationValuesProvider {
    
    var pageCellTitle: HomeCellData.Title {
        switch layout {
        case .note:
            return .default(title: snippet)
        case .todo:
            return .todo(title: name, isChecked: isDone)
        default:
            return .default(title: name)
        }
    }

    var pageTitle: String {
        let title: String

        switch layout {
        case .note:
            title =  snippet
        default:
            title = name
        }

        return title.isEmpty ? "Untitled".localized : title
    }
}
