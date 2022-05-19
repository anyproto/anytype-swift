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

    private var objectPreviewFields: ObjectPreviewFields
    private var featuredRelationsByIds: [String: Relation]
    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let router: ObjectPreviewRouter
    private let onSelect: (ObjectPreviewFields) -> Void

    // MARK: - Initializer

    init(featuredRelationsByIds: [String: Relation],
         fields: BlockFields,
         router: ObjectPreviewRouter,
         onSelect: @escaping (ObjectPreviewFields) -> Void) {
        self.objectPreviewFields = ObjectPreviewFields.convertToModel(fields: fields)
        self.router = router
        self.onSelect = onSelect
        self.featuredRelationsByIds = featuredRelationsByIds

        updateObjectPreview(featuredRelationsByIds: featuredRelationsByIds, objectPreviewFields: objectPreviewFields)
    }

    func updateObjectPreview(featuredRelationsByIds: [String: Relation], objectPreviewFields: ObjectPreviewFields) {
        objectPreviewSections = objectPreviewModelBuilder.build(featuredRelationsByIds: featuredRelationsByIds,
                                                                objectPreviewFields: objectPreviewFields)
    }

    func toggleFeaturedRelation(id: String, isEnabled: Bool) {
        var withName = objectPreviewFields.withName
        if id == BundledRelationKey.name.rawValue {
            withName = isEnabled
        }

        var newFeaturedRelationsIds = Set(objectPreviewFields.featuredRelationsIds)

        if isEnabled {
            newFeaturedRelationsIds.insert(id)
        } else {
            newFeaturedRelationsIds.remove(id)
        }

        objectPreviewFields = ObjectPreviewFields(
            icon: objectPreviewFields.icon,
            layout: objectPreviewFields.layout,
            withName: withName,
            featuredRelationsIds: newFeaturedRelationsIds
        )

        self.onSelect(objectPreviewFields)
    }

    func showLayoutMenu() {
        router.showLayoutMenu(objectPreviewFields: objectPreviewFields) { [weak self] newObjectPreviewFields in
            self?.handleOnSelect(newObjectPreviewFields: newObjectPreviewFields)
        }
    }

    func showIconMenu() {
        router.showIconMenu(objectPreviewFields: objectPreviewFields) { [weak self] newObjectPreviewFields in
            self?.handleOnSelect(newObjectPreviewFields: newObjectPreviewFields)
        }
    }

    private func handleOnSelect(newObjectPreviewFields: ObjectPreviewFields) {
        objectPreviewFields = newObjectPreviewFields
        onSelect(newObjectPreviewFields)
        updateObjectPreview(featuredRelationsByIds: featuredRelationsByIds, objectPreviewFields: newObjectPreviewFields)
    }
}
