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

    @Published var objectPreviewSections = ObjectPreviewViewSection(main: [], featuredRelation: [])

    // MARK: - Private variables

    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let objectPreviewFields: ObjectPreviewFields
    private let router: ObjectPreviewRouter

    // MARK: - Initializer

    init(featuredRelationsByIds: [String: Relation],
         fields: BlockFields,
         router: ObjectPreviewRouter) {
        objectPreviewFields = ObjectPreviewFields.convertToModel(fields: fields)
        self.router = router

        updateObjectPreview(featuredRelationsByIds: featuredRelationsByIds, objectPreviewFields: objectPreviewFields)
    }

    func updateObjectPreview(featuredRelationsByIds: [String: Relation], objectPreviewFields: ObjectPreviewFields) {
        objectPreviewSections = objectPreviewModelBuilder.build(featuredRelationsByIds: featuredRelationsByIds,
                                                                objectPreviewFields: objectPreviewFields)
    }

    func showLayoutMenu() {
        router.showLayoutMenu(objectPreviewFields: objectPreviewFields)
    }

    func showIconMenu() {
        router.showIconMenu(objectPreviewFields: objectPreviewFields)
    }
}
