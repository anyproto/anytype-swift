//
//  RelationValueStatusSection.swift
//  Anytype
//
//  Created by Konstantin Mordan on 02.12.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct RelationValueStatusSection: Identifiable {
    let id: String
    let title: String
    let statuses: [RelationValue.Status]
}
