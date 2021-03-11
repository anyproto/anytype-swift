//
//  DocumentViewModel+New+RowsAndSections.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

struct DocumentSection: Hashable {
    let section: Int
    static var first: Self = .init(section: 0)
}

