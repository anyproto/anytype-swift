import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewIconMenuViewModel: CheckPopupViewViewModelProtocol {
    let title = Loc.icon
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var iconSize: ObjectPreviewModel.IconSize
    private var cardStyle: ObjectPreviewModel.CardStyle
    private let onSelect: (ObjectPreviewModel.IconSize) -> Void

    // MARK: - Initializer

    init(iconSize: ObjectPreviewModel.IconSize,
         cardStyle: ObjectPreviewModel.CardStyle,
         onSelect: @escaping (ObjectPreviewModel.IconSize) -> Void) {
        self.iconSize = iconSize
        self.cardStyle = cardStyle
        self.onSelect = onSelect
        self.updatePreviewFields(iconSize)
    }

    func updatePreviewFields(_ currentIconSize: ObjectPreviewModel.IconSize) {
        items = buildObjectPreviewPopupItem(currentIconSize: currentIconSize)
    }

    func buildObjectPreviewPopupItem(currentIconSize: ObjectPreviewModel.IconSize) -> [CheckPopupItem] {
        availableIconSizes().map { iconSize in
            let isSelected = currentIconSize == iconSize
            return CheckPopupItem(id: iconSize.rawValue, icon: nil, title: iconSize.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func availableIconSizes() -> [ObjectPreviewModel.IconSize] {
        switch cardStyle {
        case .text:
            return [.small, .none]
        case .card:
            return [.medium, .none]
        }
    }

    func onTap(itemId: String) {
        guard let iconSize = ObjectPreviewModel.IconSize(rawValue: itemId) else { return }

        onSelect(iconSize)
        updatePreviewFields(iconSize)
    }
}
