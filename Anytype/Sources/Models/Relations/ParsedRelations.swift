//
//  ParsedRelations.swift
//  Anytype
//
//  Created by Denis Batvinkin on 16.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore


struct ParsedRelations {

    private(set) var featuredRelations: [Relation]
    private(set) var otherRelations: [Relation]

    public init(otherRelations: [Relation], featuredRelations: [Relation]) {
        self.otherRelations = otherRelations
        self.featuredRelations = featuredRelations
    }
}
