//
//  ObjectPreviewViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewViewModel: ObservableObject {
    
    // MARK: - Private variables

    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    @Published var objectPreviewSections = ObjectPreviewViewSection(main: [], featuredRelation: [])

    // MARK: - Initializer

    init(featuredRelations: [Relation], fields: MiddleBlockFields) {
        let featuredRelationsByIds = Dictionary(
            uniqueKeysWithValues: featuredRelations.map { ($0.id, $0) }
        )
        updateObjectPreview(featuredRelationsByIds: featuredRelationsByIds, fields: fields)
    }

    func updateObjectPreview(featuredRelationsByIds: [String: Relation], fields: MiddleBlockFields) {
        objectPreviewSections = objectPreviewModelBuilder.build(featuredRelationsByIds: featuredRelationsByIds,
                                                                fields: fields)
    }
}
