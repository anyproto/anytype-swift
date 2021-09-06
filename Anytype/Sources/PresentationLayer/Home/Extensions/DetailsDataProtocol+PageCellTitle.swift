//
//  DetailsDataProtocol+PageCellTitle.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

extension DetailsDataProtocol {
    
    var pageCellTitle: HomeCellData.Title {
        let title = name ?? ""
        
        guard case .todo = layout else {
            return .default(title: title)
        }
        
        return .todo(
            title: title,
            isChecked: done ?? false
        )
    }
    
}
