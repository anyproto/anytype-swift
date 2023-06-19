import Services
import Combine

final class ObjectPreviewIconMenuViewModel: CheckPopupViewViewModelProtocol {
    let title = Loc.icon
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables
    private let objectLayout: DetailsLayout
    private let cardStyle: BlockLink.CardStyle
    private let currentIconSize: BlockLink.IconSize
    private let onSelect: (BlockLink.IconSize) -> Void

    // MARK: - Initializer

    init(
        objectLayout: DetailsLayout,
        cardStyle: BlockLink.CardStyle,
        currentIconSize: BlockLink.IconSize,
        onSelect: @escaping (BlockLink.IconSize) -> Void
    ) {
        self.objectLayout = objectLayout
        self.cardStyle = cardStyle
        self.currentIconSize = currentIconSize
        self.onSelect = onSelect

        self.updatePreviewFields(currentIconSize)
    }

    func updatePreviewFields(_ currentIconSize: BlockLink.IconSize) {
        items = buildObjectPreviewPopupItem(currentIconSize: currentIconSize)
    }

    func buildObjectPreviewPopupItem(currentIconSize: BlockLink.IconSize) -> [CheckPopupItem] {
        availableIconSizes().map { iconSize in
             CheckPopupItem(
                id: String(iconSize.rawValue),
                iconAsset: nil,
                title: iconSize.name,
                subtitle: nil,
                isSelected: currentIconSize == iconSize,
                onTap: { [weak self] in self?.onTap(iconSize: iconSize) }
             )
        }
    }

    func availableIconSizes() -> [BlockLink.IconSize] {
        switch (cardStyle, objectLayout) {
        case (_, .todo):
            fallthrough
        case (.text, _):
            return [.small, .none]
        case (.card, _):
            return [.medium, .small, .none]
        }
    }

    private func onTap(iconSize: BlockLink.IconSize) {
        onSelect(iconSize)
        updatePreviewFields(iconSize)
    }
}
