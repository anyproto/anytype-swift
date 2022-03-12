//
//  NewSearchView+ListModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 12.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

extension NewSearchView {
    
    enum ListModel {
        case plain(rows: [NewSearchRowConfiguration])
        case sectioned
    }
    
}


extension NewSearchView.ListModel {
    
    var isEmpty: Bool {
        switch self {
        case .plain(rows: let rows): return rows.isEmpty
        case .sectioned: return false
        }
    }
    
}
