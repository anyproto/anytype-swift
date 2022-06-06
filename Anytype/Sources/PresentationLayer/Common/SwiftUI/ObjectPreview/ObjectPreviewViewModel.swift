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

    @Published private(set) var objectPreviewModel: ObjectPreviewModel

    // MARK: - Private variables

    private let router: ObjectPreviewRouter
    private let onSelect: (BlockLink.Appearance) -> Void

    // MARK: - Initializer

    init(objectPreviewModel: ObjectPreviewModel,
         router: ObjectPreviewRouter,
         onSelect: @escaping (BlockLink.Appearance) -> Void) {
        self.router = router
        self.onSelect = onSelect
        self.objectPreviewModel = objectPreviewModel
    }

    func toggleFeaturedRelation(relation: ObjectPreviewModel.Relation, isEnabled: Bool) {
        var updatedRelations = objectPreviewModel.relations

        if isEnabled {
            updatedRelations.insert(relation)
        } else {
            updatedRelations.remove(relation)
        }

        objectPreviewModel = ObjectPreviewModel(iconSize: objectPreviewModel.iconSize,
                                                cardStyle: objectPreviewModel.cardStyle,
                                                description: objectPreviewModel.description,
                                                relations: updatedRelations)

        self.onSelect(objectPreviewModel.asBlockLinkAppearance)
    }

    func showLayoutMenu() {
        router.showLayoutMenu(cardStyle: objectPreviewModel.cardStyle) { [weak self] cardStyle in
            guard let self = self else { return }

            var iconSize = self.objectPreviewModel.iconSize
            
            if iconSize.hasIcon {
                switch cardStyle {
                case .card:
                    iconSize = .medium
                case .text:
                    iconSize = .small
                }
            }

            self.objectPreviewModel = ObjectPreviewModel(iconSize: iconSize,
                                           cardStyle: cardStyle,
                                           description: self.objectPreviewModel.description,
                                           relations: self.objectPreviewModel.relations)
            self.onSelect(self.objectPreviewModel.asBlockLinkAppearance)
        }
    }

    func showIconMenu() {
        router.showIconMenu(iconSize: objectPreviewModel.iconSize, cardStyle: objectPreviewModel.cardStyle) { [weak self] iconSize in
            guard let self = self else { return }

            self.objectPreviewModel = ObjectPreviewModel(iconSize: iconSize,
                                           cardStyle: self.objectPreviewModel.cardStyle,
                                           description: self.objectPreviewModel.description,
                                           relations: self.objectPreviewModel.relations)
            self.onSelect(self.objectPreviewModel.asBlockLinkAppearance)
        }
    }

    func showDescriptionMenu() {
        router.showDescriptionMenu(currentDescription: objectPreviewModel.description) { [weak self] description in
            guard let self = self else { return }

            self.objectPreviewModel = ObjectPreviewModel(iconSize: self.objectPreviewModel.iconSize,
                                           cardStyle: self.objectPreviewModel.cardStyle,
                                           description: description,
                                           relations: self.objectPreviewModel.relations)
            self.onSelect(self.objectPreviewModel.asBlockLinkAppearance)
        }
    }
}
