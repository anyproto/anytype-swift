//
//  FlowRelationsViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 19.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

class FlowRelationsViewModel: ObservableObject {
    @Published var relations: [Relation]
    @Published var alignment: HorizontalAlignment = .leading
    let onRelationTap: (Relation) -> Void

    init(relations: [Relation], onRelationTap: @escaping (Relation) -> Void) {
        self.relations = relations
        self.onRelationTap = onRelationTap
    }
}
