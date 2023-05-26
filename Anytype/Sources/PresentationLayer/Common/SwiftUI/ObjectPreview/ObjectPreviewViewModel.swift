import Services
import SwiftUI
import FloatingPanel

final class ObjectPreviewViewModel: ObservableObject {

    @Published private(set) var objectPreviewModel: ObjectPreviewModel

    // MARK: - Private variables

    private let blockLinkState: BlockLinkState
    private let router: ObjectPreviewRouter
    private let onSelect: (BlockLink.Appearance) -> Void

    // MARK: - Initializer

    init(blockLinkState: BlockLinkState,
         router: ObjectPreviewRouter,
         onSelect: @escaping (BlockLink.Appearance) -> Void) {
        self.objectPreviewModel = .init(linkState: blockLinkState)
        self.blockLinkState = blockLinkState
        self.router = router
        self.onSelect = onSelect
    }

    func toggleFeaturedRelation(relation: ObjectPreviewModel.Relation, isEnabled: Bool) {
        var newRelation = relation
        newRelation.isEnabled = isEnabled

        if let index = objectPreviewModel.relations.firstIndex(of: .relation(relation)) {
            objectPreviewModel.relations[index] = .relation(newRelation)
        } else if relation == objectPreviewModel.coverRelation {
            objectPreviewModel.coverRelation?.isEnabled = isEnabled
        }

        self.onSelect(objectPreviewModel.asBlockLinkAppearance)
    }

    func showLayoutMenu() {
        router.showLayoutMenu(cardStyle: objectPreviewModel.cardStyle) { [weak self] cardStyle in
            guard let self = self else { return }

            var iconSize = self.objectPreviewModel.iconSize
            
            if iconSize.hasIcon {
                switch cardStyle {
                case .card:
                    iconSize = iconSize
                case .text:
                    iconSize = .small
                }
            }

            self.objectPreviewModel.iconSize = iconSize
            self.objectPreviewModel.cardStyle = cardStyle
            self.objectPreviewModel.setupCoverRelation()

            self.onSelect(self.objectPreviewModel.asBlockLinkAppearance)
        }
    }

    func showIconMenu() {
        router.showIconMenu(
            objectLayout: blockLinkState.objectLayout,
            iconSize: objectPreviewModel.iconSize,
            cardStyle: objectPreviewModel.cardStyle
        ) { [weak self] iconSize in
            guard let self = self else { return }

            self.objectPreviewModel.iconSize = iconSize

            self.onSelect(self.objectPreviewModel.asBlockLinkAppearance)
        }
    }

    func showDescriptionMenu() {
        router.showDescriptionMenu(currentDescription: objectPreviewModel.description) { [weak self] description in
            guard let self = self else { return }

            self.objectPreviewModel.description = description

            self.onSelect(self.objectPreviewModel.asBlockLinkAppearance)
        }
    }
}
