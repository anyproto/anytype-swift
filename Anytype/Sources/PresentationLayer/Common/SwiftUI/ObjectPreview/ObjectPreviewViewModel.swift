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

    private var appearance: BlockLink.Appearance

    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let router: ObjectPreviewRouter
    private let onSelect: (BlockLink.Appearance) -> Void

    // MARK: - Initializer

    init(appearance: BlockLink.Appearance,
         router: ObjectPreviewRouter,
         onSelect: @escaping (BlockLink.Appearance) -> Void) {
        self.router = router
        self.onSelect = onSelect
        self.appearance = appearance

        updateObjectPreview(appearance: appearance)
    }

    func updateObjectPreview(appearance: BlockLink.Appearance) {
        objectPreviewSections = objectPreviewModelBuilder.build(appearance: appearance)
    }

    func toggleFeaturedRelation(relation: ObjectPreviewViewSection.FeaturedSectionItem.IDs, isEnabled: Bool) {

        switch relation {
        case .name:
            if isEnabled {
                appearance.relations.insert(.name)
            } else {
                appearance.relations.remove(.name)
            }
        case .description:
            if isEnabled {
                appearance.description = .added
            } else {
                appearance.description = .none
            }
        }

        self.onSelect(appearance)
        updateObjectPreview(appearance: appearance)
    }

    func showLayoutMenu() {
        router.showLayoutMenu(cardStyle: .init(appearance.cardStyle)) { [weak self] cardStyle in
            guard let self = self else { return }

            if self.appearance.relations.contains(.icon) {
                switch cardStyle {
                case .card:
                    self.appearance.iconSize = .medium
                case .text:
                    self.appearance.iconSize = .small
                }
            }
            self.appearance.cardStyle = cardStyle.asModel
            self.handleOnMainSelect()
        }
    }

    func showIconMenu(currentIconSize: ObjectPreviewViewSection.MainSectionItem.IconSize) {
        let currentCardStyle = ObjectPreviewViewSection.MainSectionItem.CardStyle(appearance.cardStyle)

        router.showIconMenu(iconSize: currentIconSize, cardStyle: currentCardStyle) { [weak self] iconSize in
            switch iconSize {
            case .none:
                self?.appearance.relations.remove(.icon)
            case .small:
                self?.appearance.relations.insert(.icon)
                self?.appearance.iconSize = .small
            case .medium:
                self?.appearance.relations.insert(.icon)
                self?.appearance.iconSize = .medium
            }
            self?.handleOnMainSelect()
        }
    }

    private func handleOnMainSelect() {
        onSelect(appearance)
        updateObjectPreview(appearance: appearance)
    }
}
